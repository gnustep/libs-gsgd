/* GDBarChart.h - A bar chart type  -*-objc-*-
   Copyright (C) 2002 Free Software Foundation, Inc.
   
   Written by: Nicola Pero <nicola@brainstorm.co.uk>
   December 2002

   This file is part of the GNUstep GD Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/ 

#ifndef _gsgd_GDBarChart_h__
#define _gsgd_GDBarChart_h__

#include <Foundation/NSObject.h>
#include <Foundation/NSGeometry.h>

@class GDBinDataSet;
@class GDFrame;

/* A GDBarChart object plots a bar chart (bars are vertical;
 * the name of each bar, which shouldn't be too long, is below
 * each bar(.  */

@interface GDBarChart : NSObject
{
  /* The data set.  */
  GDBinDataSet *_dataSet;

  NSString *_title;

  int _barColor;
  int _barShadeColor;
}

- (id) init;

- (void) setDataSet: (GDBinDataSet *)dataSet;

- (void) setTitle: (NSString *)title;

- (void) setBarColor: (int)color;

- (void) setBarShadeColor: (int)color;

- (NSSize) recommendedSize;

- (void) plotInFrame: (GDFrame *)frame;

@end

#endif /* _gsgd_GDBarChart_h__ */

