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
    int white, black, red, blue, yellow, gray;
    
    /* When an image is created from scratch, the image is
     * automatically filled at the beginning with the first allocated
     * palette color.  */
    white = [image allocatePaletteColorWithName: @"white"];
    black = [image allocatePaletteColorWithName: @"black"];
    red = [image allocatePaletteColorWithName: @"red"];
    blue = [image allocatePaletteColorWithName: @"Blue"];
    yellow = [image allocatePaletteColorWithName: @"yellow"];
    gray = [image allocatePaletteColorWithName: @"Gray"];

    [image arcCenterX: 110
	   y: 110
	   width: 200
	   height: 200
	   startAngle: 0
	   stopAngle: 360
	   color: blue
	   options: GDDrawArcImageArcOption | GDFillArcAreaImageArcOption];

    [image arcCenterX: 110
	   y: 110
	   width: 100
	   height: 100
	   startAngle: 0
	   stopAngle: 360
	   color: red
	   options: GDDrawArcImageArcOption | GDFillArcAreaImageArcOption];

    [image arcCenterX: 110
	   y: 110
	   width: 80
	   height: 80
	   startAngle: 0
	   stopAngle: 90
	   color: yellow
	   options: GDDrawArcImageArcOption | GDFillArcAreaImageArcOption];

    [image arcCenterX: 110
	   y: 110
	   width: 80
	   height: 80
	   startAngle: 90
	   stopAngle: 135
	   color: gray
	   options: GDDrawArcImageArcOption | GDDrawArcEdgesImageArcOption];
  }
	

  NSLog (@"Saving it as pie.png...");
  d = [image pngData];
  [d writeToFile: @"pie.png"  atomically: YES];

  [pool release];

  return 0;
}
