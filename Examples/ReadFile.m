/* Read an image from a file in a format, and writes it into another
   file in another format

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

int main (void)
{
  GDImage *image;
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSData *d = [NSData dataWithContentsOfFile: @"test.png"];

  NSLog (@"Loading test.png ...");
  image = [GDImage imageWithData: d  format: GDPNGImageDataFormat];

  NSLog (@"Writing it out to test.jpg ...");
  [[image jpegDataWithQuality: -1] writeToFile: @"test.jpg"  atomically: YES];

  NSLog (@"Writing it out to test.wbmp ...");
  [[image wbmpDataWithForegroundColor: -1] writeToFile: @"test.wbmp"  
					   atomically: YES];
  
  [pool release];

  return 0;
}
