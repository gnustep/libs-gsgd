/* Generate a plot, and write it to a file.

   Copyright (C) 2002, 2003 Free Software Foundation, Inc.

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

#ifndef GNUSTEP
#include <GNUstepBase/GNUstep.h>
#endif

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

    [image drawRectangle: NSMakeRect (10, 10, 200, 200)
	   color: black];
    
    [image setLineStyle: [GDLineStyle dottedLineWithColor: gray]];

    for (i = 30; i < 210; i += 20)
      {
	[image drawLine: NSMakePoint (11, i)
	       to: NSMakePoint (209, i)
	       color: [GDImage styledColor]];

	[image drawLine: NSMakePoint (i, 11)
	       to: NSMakePoint (i, 209)
	       color: [GDImage styledColor]];	
      }

    [image drawString: @"y = sin (x)"
	   from: NSMakePoint (70, 30)
	   color: black
	   font: [GDFont mediumBoldFont]];

    /* Here is how on my system I draw a string using a free type
     * font.  Commented out since it depends on you having the
     * appropriate .ttf font.  */
#if 0
    [image stringFreeType: @"y = sin (x)"
	   x: 70
	   y: 170
	   color: black
	   fontPath: @"/usr/share/fonts/truetype/arphic/gbsn00lp.ttf"
	   pointSize: 10
	   angle: 0
	   disableAntiAliasing: NO
	   boundingRect: NULL];
#endif
    

    /* Here is how on my system I get the bounding rect of a string
     * when drawn using a free type font.  Commented out since it
     * depends on you having the appropriate .ttf font.  */
#if 0
    {
      int rect[8];

      [GDImage getBoundingRect: rect
	       stringFreeType: @"y = sin (x)"
	       fontPath: @"/usr/share/fonts/truetype/arphic/gbsn00lp.ttf" 
	       pointSize: 10
	       angle: 0];
      printf ("(%d, %d), (%d, %d), (%d, %d), (%d, %d)\n",
	      rect[0], rect[1],  rect[2], rect[3],
	      rect[4], rect[5],  rect[6], rect[7]);
      
    }
#endif
    
    {
      /* Let's plot a rough  y = sin (x)  */
      int x;
      for (x = 1; x < 200; x++)
	{
	  float x_ = x / 10.;
	  float y_ = sin (x_);
	  
	  [image setPixelColor: black
		 at: NSMakePoint (x + 10, (y_ * 50) + 100)];
	}
    }
  }
	

  NSLog (@"Saving it as plot.png...");
  d = [image pngData];
  [d writeToFile: @"plot.png"  atomically: YES];

  [pool release];

  return 0;
}
