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
#include <gsgd/GDBinDataSet.h>
#include <gsgd/GDPieChart.h>
#include <gd.h>
#include <math.h>

int main (void)
{
  GDImage *image;
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSData *d;

  NSLog (@"Creating an image...");
  image = [GDImage imageWithWidth: 400  height: 400];
  
  NSLog (@"Drawing into it...");
  {
    int white;
    
    GDBinDataSet *d;
    GDPieChart *p;

    /* Background color.  */
    white = [image allocatePaletteColorWithName: @"white"];

    d = [GDBinDataSet new];
    AUTORELEASE (d);

    /* Example charts.  */
#if 0
    [d setDataValue: 21703  forKey: @"30"];
    [d setDataValue: 61402  forKey: @"Da 25 a 29"];
    [d setDataValue: 13551  forKey: @"Da 19 a 24"];
    [d setDataValue: 1950  forKey: @"Da 3 a 18"];
#else
    [d setDataValue: 1950  forKey: @"Da 3 a 18"];
    [d setDataValue: 13551  forKey: @"Da 19 a 24"];
    [d setDataValue: 61402  forKey: @"Da 25 a 29"];
    [d setDataValue: 21703  forKey: @"30"];
    [d setDataValue: 121252  forKey: @"Da 31 a 35"];
    [d setDataValue: 94939  forKey: @"Da 36 a 40"];
    [d setDataValue: 59593  forKey: @"Da 41 a 45"];
    [d setDataValue: 1950  forKey: @"Da 3 a 18"];
    [d setDataValue: 13551  forKey: @"Da 19 a 24"];
    [d setDataValue: 61402  forKey: @"Da 25 a 29"];
    [d setDataValue: 21703  forKey: @"30"];
    [d setDataValue: 121252  forKey: @"Da 31 a 35"];
    [d setDataValue: 94939  forKey: @"Da 36 a 40"];
    [d setDataValue: 59593  forKey: @"Da 41 a 45"];
#endif
        
    p = [GDPieChart new];
    AUTORELEASE (p);
    [p setDataSet: d];
    [p setTitle: @"A test plot"];
    [p plotInFrame: [GDFrame frameForImage: image]];
  }

  NSLog (@"Saving it as pie.png...");
  d = [image pngData];
  [d writeToFile: @"pie.png"  atomically: YES];

  [pool release];

  return 0;
}
