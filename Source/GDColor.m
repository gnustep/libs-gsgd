/* GDColor.m - Implementation of GDColor
   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:  Manuel Guesdon <mguesdon@orange-concept.com>
   Created: Dec 1999
   
   Modified by: Nicola Pero <n.pero@mi.flashnet.it>
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

#include <gsgd/GDCom.h>
#include <gsgd/GDColor.h>
#include <Foundation/NSString.h>
#include <Foundation/NSArchiver.h>

@implementation GDColor

+ (GDColor*) colorWithRed: (int)red
		    green: (int)green
		     blue: (int)blue
{
  GDColor* color = [[[self alloc] initWithRed: red
				  green: green
				  blue: blue]
		     autorelease];
  return color;
};

- (id) initWithRed: (int)red
	     green: (int)green
	      blue: (int)blue
{
  if ((self = [super init]) != nil)
    {
      _red = red;
      _green = green;
      _blue = blue;
    };
  return self;
};

- (id) copyWithZone: (NSZone*)aZone
{
  if (NSShouldRetainWithZone (self, aZone))
    {
      return [self retain];
    }
  else
    {
      GDColor* aCopy = NSCopyObject (self, 0, aZone);
      aCopy->_red = _red;
      aCopy->_green = _green;
      aCopy->_blue = _blue;
      return aCopy;
    };
};

- (NSString*) description
{
  return [NSString stringWithFormat: @"<%s %p (%d,%d,%d)>",
		   [self className],
		   (void *)self,
		   _red,
		   _green,
		   _blue];
};

- (void) encodeWithCoder: (NSCoder*)aCoder
{
  [aCoder encodeValueOfObjCType: @encode(int)  at: &_red];
  [aCoder encodeValueOfObjCType: @encode(int)  at: &_green];
  [aCoder encodeValueOfObjCType: @encode(int)  at: &_blue];
};

- (id) initWithCoder: (NSCoder*)aDecoder
{
  [aDecoder decodeValueOfObjCType: @encode(int)  at: &_red];
  [aDecoder decodeValueOfObjCType: @encode(int)  at: &_green];
  [aDecoder decodeValueOfObjCType: @encode(int)  at: &_blue];
  return self;
};

- (NSComparisonResult) compare: (id)anObject
{
  if (anObject == self)
    {
      return NSOrderedSame;
    }
  if (anObject == nil || ([anObject isKindOfClass: self->isa] == NO))
    {
      return NSOrderedAscending;
    }
  else if (_red < ((GDColor*)anObject)->_red)
    {
      return NSOrderedAscending;
    }
  else if (_red > ((GDColor*)anObject)->_red)
    {
      return NSOrderedDescending;
    }
  else if (_green < ((GDColor*)anObject)->_green)
    {
      return NSOrderedAscending;
    }
  else if (_green > ((GDColor*)anObject)->_green)
    {
      return NSOrderedDescending;
    }
  else if (_blue < ((GDColor*)anObject)->_blue)
    {
      return NSOrderedAscending;
    }
  else if (_blue > ((GDColor*)anObject)->_blue)
    {
      return NSOrderedDescending;
    }
  else
    {
      return NSOrderedSame;
    }
}

- (BOOL) isEqual: (id)anObject
{
  if (anObject == self)
    {
      return YES;
    }

  if ([anObject isKindOfClass: self->isa] == NO)
    {
      return NO;
    }
  
  {
    GDColor *a = (GDColor *)anObject;
    
    if (a->_red!=_red  ||  a->_green!=_green  ||  a->_blue!=_blue)
      {
	return NO;
      }
    else
      {
	return YES;
      }
  }
};

- (int) red
{
  return _red;
};

- (int) green
{
  return _green;
};

- (int) blue
{
  return _blue;
};

@end

