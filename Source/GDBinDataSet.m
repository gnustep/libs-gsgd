/* GDBinDataSet.m - Data set with non-numeric x and numeric y  -*-objc-*-
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

#include <gsgd/GDBinDataSet.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSException.h>
#include <Foundation/NSValue.h>

@implementation GDBinDataSet

- (id) init
{
  _keys = [NSMutableArray new];
  _values = [NSMutableArray new];
  return self;
}

- (void) dealloc
{
  RELEASE (_keys);
  RELEASE (_values);
  [super dealloc];
}

- (void) setDataValue: (double)value  forKey: (NSString *)key
{
  [_keys addObject: key];
  [_values addObject: [NSNumber numberWithDouble: value]];
}

- (NSArray *)keys
{
  return _keys;
}

- (NSArray *)values
{
  return _values;
}

- (NSArray *)fractionsScaledTo: (double)max
{
  int length = [_keys count];
  double *f;
  double total = 0;
  int i;
  NSMutableArray *output = nil;

  if (length == 0)
    {
      return [NSArray array];
    }

  f = objc_malloc (sizeof (double) * length);
  
  NS_DURING
    {
      for (i = 0; i < length; i++)
	{
	  f[i] = [(NSNumber *)[_values objectAtIndex: i] doubleValue];
	  total += f[i];
	}
      
      output = [NSMutableArray array];
      
      total = total / max;
      
      for (i = 0; i < length; i++)
	{
	  [output addObject: [NSNumber numberWithDouble: f[i] / total]];
	}
    }
  NS_HANDLER
    {
      objc_free (f);
      f = NULL;
    }
  NS_ENDHANDLER

  if (f != NULL)
    {
      objc_free (f);
    }

  return output;
}

@end


