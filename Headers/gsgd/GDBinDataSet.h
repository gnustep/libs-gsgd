/* GDBinDataSet.h - Data set with non-numeric x and numeric y  -*-objc-*-
   Copyright (C) 2002 Free Software Foundation, Inc.
   
   Written by: Nicola Pero <nicola@brainstorm.co.uk>
   July 2002

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

#ifndef _gsgd_GDBinDataSet_h__
#define _gsgd_GDBinDataSet_h__

#include <Foundation/NSObject.h>

@class NSMutableArray;

/* A GDBinDataSet object is used to hold data where the x (the
 * independent variable) is a String, and the y (the dependent
 * variable) is a number (a double).  For example, a typical dataset
 * to be stored in such an object might be
 *
 *  Yes = 1453
 *  No  = 2340
 *  Did not respond = 301
 *
 * Such a dataset is plotted using specific types of plots (a PieChart,
 * a HorizontalBarChart, a BarChart).
 */
@interface GDBinDataSet : NSObject
{
  /* A list of keys (NSStrings).  */
  NSMutableArray *_keys;
  
  /* A list of values (NSNumbers holding doubles).  */
  NSMutableArray *_values;
}

- (id) init;

- (void) setDataValue: (double)value  forKey: (NSString *)key;

- (NSArray *)keys;

- (NSArray *)values;

/* Each item is a NSNumber holding a double between 0 and max
 * representing the fraction of the total taken by that key.  max =
 * 100 gives percentages.  */
- (NSArray *)fractionsScaledTo: (double)max;

@end

#endif /* _gsgd_GDBinDataSet_h__ */

