/* GDFont.m
   Copyright (C) 2002, 2003 Free Software Foundation, Inc.
   
   Written by: Nicola Pero <n.pero@mi.flashnet.it>
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

#include "gsgd/GDFont.h"

#ifndef GNUSTEP
#include <gnustep/base/GNUstep.h>
#endif

/* For gdFontSmall.  */
#include <gdfonts.h>

/* For gdFontTiny.  */
#include <gdfontt.h>

/* For gdFontMediumBold.  */
#include <gdfontmb.h>

/* For gdFontLarge.  */
#include <gdfontl.h>

/* Fot gdFontGiant.  */
#include <gdfontg.h>

static GDFont *tinyFont = nil;
static GDFont *smallFont = nil;
static GDFont *mediumBoldFont = nil;
static GDFont *largeFont = nil;
static GDFont *giantFont = nil;

@implementation GDFont

/*
 * The default fonts.  
 */
+ (GDFont *) tinyFont
{
  if (tinyFont == nil)
    {
      tinyFont = [[GDFont alloc] initWithFontPointerNoCopy: gdFontTiny];
    }
  return tinyFont;
}

+ (GDFont *) smallFont
{
  if (smallFont == nil)
    {
      smallFont = [[GDFont alloc] initWithFontPointerNoCopy: gdFontSmall];
    }
  return smallFont;
}

+ (GDFont *) mediumBoldFont
{
  if (mediumBoldFont == nil)
    {
      mediumBoldFont = [[GDFont alloc] initWithFontPointerNoCopy: 
					 gdFontMediumBold];
    }
  return mediumBoldFont;
}

+ (GDFont *) largeFont
{
  if (largeFont == nil)
    {
      largeFont = [[GDFont alloc] initWithFontPointerNoCopy: gdFontLarge];
    }
  return largeFont;
}

+ (GDFont *) giantFont
{
  if (giantFont == nil)
    {
      giantFont = [[GDFont alloc] initWithFontPointerNoCopy: gdFontGiant];
    }
  return giantFont;
}


/* 
 * Designated initializers.
 */
- (id) initWithFontPointerNoCopy: (gdFont *)fontPtr
{
  _needsToFreeFontPtr = NO;
  _fontPtr = fontPtr;
  return self;
}


- (id) initWithFontPointer: (gdFont *)fontPtr
{
  size_t lengthOfData;

  _needsToFreeFontPtr = YES;
  _fontPtr = objc_malloc (sizeof (gdFont));
  _fontPtr = fontPtr;

  lengthOfData = sizeof (char) * _fontPtr->nchars * _fontPtr->w * _fontPtr->h;
  _fontPtr->data = objc_malloc (lengthOfData);
  memcpy (_fontPtr->data, fontPtr->data, lengthOfData);

  return self;
}

- (void) dealloc
{
  if (_needsToFreeFontPtr)
    {
      objc_free (_fontPtr->data);
      objc_free (_fontPtr);
    }
  [super dealloc];
}

- (gdFont *)fontPointer
{
  return _fontPtr;
}

- (int) width
{
  return _fontPtr->w;
}

- (int) height
{
  return _fontPtr->h;
}

- (NSSize) boundingBoxForString: (NSString *)text
{
  int length = [text length];
  NSSize s;
  
  s.width = _fontPtr->w * length;
  s.height = _fontPtr->h;
  
  return s;
}

@end

#include <Foundation/NSArray.h>

@implementation GDFont (StringUtils)
- (NSSize) boundingBoxForStrings: (NSArray *)strings
{
  int i, count = [strings count];
  NSSize result = NSMakeSize (0, 0);
  
  for (i = 0; i < count; i++)
    {
      NSString *s = [strings objectAtIndex: i];
      NSSize size = [self boundingBoxForString: s];

      if (size.width > result.width)
	{
	  result.width = size.width;
	}
      if (size.height > result.height)
	{
	  result.height = size.height;
	}
    }
  return result;
}

@end

