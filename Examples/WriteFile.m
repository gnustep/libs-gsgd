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
    int i, white, black, red, blue, yellow;
    
    /* When an image is created from scratch, the image is
     * automatically filled at the beginning with the first allocated
     * palette color.  */
    white = [image allocatePaletteColorWithName: @"white"];
    black = [image allocatePaletteColorWithName: @"black"];
    red = [image allocatePaletteColorWithName: @"red"];
    blue = [image allocatePaletteColorWithName: @"Blue"];
    yellow = [image allocatePaletteColorWithName: @"yellow"];


    for (i = 0; i < 100; i++)
      {
	[image setPixelColor: black
	       at: NSMakePoint (50, i)];
      }

    [image lineFromX: 47
	   y: 0
	   toX: 47
	   y: 100
	   color: red];

    [image rectangleFromX: 20
	   y: 20
	   toX: 40
	   y: 40
	   color: blue];

    [image filledRectangleFromX: 60
	   y: 60
	   toX: 80
	   y: 80
	   color: yellow];

    [image rectangleFromX: 30
	   y: 30
	   toX: 50
	   y: 50
	   color: red];
    
    [image fillFromX: 35
	   y: 35
	   usingColor: black
	   toBorder: red];

  }

  NSLog (@"Saving it as a png file...");
  d = [image pngData];
  [d writeToFile: @"test.png"  atomically: YES];

  [pool release];

  return 0;
}
