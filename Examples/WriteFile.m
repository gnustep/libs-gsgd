/* Generate an image, and write it to a file.

   Copyright (C) 2002 Free Software Foundation, Inc.

   Written by: Nicola Pero <nicola@brainstorm.co.uk>
   Created: July 2002

   This file is part of the GNUstep Project

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   You should have received a copy of the GNU General Public
   License along with this program; see the file COPYING.LIB.
   If not, write to the Free Software Foundation,
   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
   */

#include <Foundation/Foundation.h>

#include <gsgd/GDImage.h>
#include <gd.h>

int main (void)
{
  GDImage *image;
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSData *d;

  NSLog (@"Creating an image...");
  image = [GDImage imageWithWidth: 100  height: 100];
  
  NSLog (@"Drawing into it...");
  /* Temporarirly draw manually in the image.  */
  {
    gdImage *im = [image imagePtr];
    int white, black;
    
    /* Allocate background */
    white = gdImageColorAllocate (im, 255, 255, 255);
    /* Allocate drawing color */
    black = gdImageColorAllocate (im, 0, 0, 0);
    /* Draw rectangle */
    gdImageRectangle (im, 0, 0, 99, 99, black);
  }

  NSLog (@"Saving it as a png file...");
  d = [image pngData];
  [d writeToFile: @"test.png"  atomically: YES];

  [pool release];

  return 0;
}
