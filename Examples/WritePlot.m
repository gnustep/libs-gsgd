/* Generate a plot, and write it to a file.

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
#include <gsgd/GDLineStyle.h>
#include <gsgd/GDFont.h>
#include <gd.h>
#include <math.h>

int main (void)
{
  GDImage *image;
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSData *d;

  NSLog (@"Creating an image...");
  image = [GDImage imageWithWidth: 220  height: 220];
  
  NSLog (@"Drawing into it...");
  {
    int i, white, black, red, blue, yellow, gray;
    
    /* When an image is created from scratch, the image is
     * automatically filled at the beginning with the first allocated
     * palette color.  */
    white = [image allocatePaletteColorWithName: @"white"];
    black = [image allocatePaletteColorWithName: @"black"];
    red = [image allocatePaletteColorWithName: @"red"];
    blue = [image allocatePaletteColorWithName: @"Blue"];
    yellow = [image allocatePaletteColorWithName: @"yellow"];
    gray = [image allocatePaletteColorWithName: @"Gray"];

    [image rectangleFromX: 10
	   y: 10
	   toX: 210
	   y: 210
	   color: black];
    
    [image setLineStyle: [GDLineStyle dottedLineWithColor: gray]];

    for (i = 30; i < 210; i += 20)
      {
	[image lineFromX: 11
	       y: i
	       toX: 209
	       y: i
	       color: [GDImage styledColor]];

	[image lineFromX: i
	       y: 11
	       toX: i
	       y: 209
	       color: [GDImage styledColor]];	
      }

    [image string: @"y = sin (x)"
	   x: 70
	   y: 30
	   color: black
	   font: [GDFont mediumBoldFont]];

    {
      /* Let's plot a rough  y = sin (x)  */
      int x;
      for (x = 1; x < 200; x++)
	{
	  float x_ = x / 10.;
	  float y_ = sin (x_);
	  
	  [image setPixelColor: black
		 x: x + 10
		 y: (y_ * 50) + 100];
	}
    }
  }
	

  NSLog (@"Saving it as plot.png...");
  d = [image pngData];
  [d writeToFile: @"plot.png"  atomically: YES];

  [pool release];

  return 0;
}
