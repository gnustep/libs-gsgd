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
  {
    int i, white, black, red, blue;
    
    /* When an image is created from scratch, the image is
     * automatically filled at the beginning with the first allocated
     * palette color.  */
    white = [image allocatePaletteColorWithRed: 255
		   green: 255
		   blue: 255];
    black = [image allocatePaletteColorWithRed: 0
		   green: 0
		   blue: 0];
    red = [image allocatePaletteColorWithRed: 255
		 green: 0
		 blue: 0];
    blue = [image allocatePaletteColorWithRed: 0
		  green: 0
		  blue: 255];
    /* TODO - shouldn't we have a facility to create colors by name ? */

    for (i = 0; i < 100; i++)
      {
	[image setPixelColor: red
	       x: 50
	       y: i];
	[image setPixelColor: black
	       x: 51
	       y: i];
	[image setPixelColor: blue
	       x: 52
	       y: i];
      }
  }

  NSLog (@"Saving it as a png file...");
  d = [image pngData];
  [d writeToFile: @"test.png"  atomically: YES];

  [pool release];

  return 0;
}
