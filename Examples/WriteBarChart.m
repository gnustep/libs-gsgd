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

#include <gsgd/GDFrame.h>
#include <gsgd/GDImage.h>
#include <gsgd/GDLineStyle.h>
#include <gsgd/GDBinDataSet.h>
#include <gsgd/GDBarChart.h>
#include <gd.h>
#include <math.h>

int main (void)
{
  GDImage *image;
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  int white;
  GDBinDataSet *d;
  GDBarChart *p;
  
  d = [GDBinDataSet new];
  AUTORELEASE (d);
  
  /* Example chart.  */
  [d setDataValue: 12  forKey: @"Database"];
  [d setDataValue: 18  forKey: @"SMS"];
  [d setDataValue: 0  forKey: @"Web"];
  [d setDataValue: 11  forKey: @"Wap"];
  [d setDataValue: 4   forKey: @"Unknown"];
  
  
  p = [GDBarChart new];
  AUTORELEASE (p);
  [p setDataSet: d];
  [p setTitle: @"A test plot"];
  
  {
    NSSize size = [p recommendedSize];
    image = [GDImage imageWithWidth: size.width  height: size.height];
    
    /* Background color.  */
    white = [image allocatePaletteColorWithName: @"white"];
    
    /*
     * [p setBarColor: [image allocatePaletteColorWithName: @"red"]];
     * [p setBarShadeColor: [image allocatePaletteColorWithName: @"yellow"]];
     */
    
    [p plotInFrame: [GDFrame frameForImage: image]];
  }
  
  NSLog (@"Saving it as barchart.png...");
  [[image pngData] writeToFile: @"barchart.png"  atomically: YES];

  [pool release];

  return 0;
}
