/* GDFont.h - Interface of GDFont
   Copyright (C) 2002 Free Software Foundation, Inc.
   
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

#ifndef _gsgd_GDFont_h__
#define _gsgd_GDFont_h__

#include <Foundation/NSObject.h>
#include <Foundation/NSGeometry.h>
#include <gd.h>

/*
 * GDFont holds a fixed size fonts of - normally - 256 chars.
 * There are five default fonts provided with libgd; you can create
 * your own fixed size fonts if you need.  Details on how to do this
 * can be found in the libgd sources.
 */
@interface GDFont : NSObject
{
  gdFont *_fontPtr;

  /* If YES, we need to free _fontPtr when we are deallocated.  */
  BOOL _needsToFreeFontPtr;
}

/*
 * The default fonts.  
 */
+ (GDFont *) tinyFont;
+ (GDFont *) smallFont;
+ (GDFont *) mediumBoldFont;
+ (GDFont *) largeFont;
+ (GDFont *) giantFont;

/*
 * Designated initializers.
 */

/* NB: Normally you are just happy with the default fonts - the designated
 * initializers are for internal and/or advanced use.  */

/* This does not copy fontPtr.  Use this initializer when fontPtr is a
 * pointer to a statically allocated struct which is never freed.  */
- (id) initWithFontPointerNoCopy: (gdFont *)fontPtr;

/* This copies fontPtr.  Use this initializer when fontPtr is a
 * pointer to malloc-ed data which might go away at any moment.  */
- (id) initWithFontPointer: (gdFont *)fontPtr;

/*
 * Accessing the font pointer
 */
- (gdFont *)fontPointer;

/* The width and height of each character in the font.  They all have the
 * same size because the font is fixed size.  */
- (int) width;
- (int) height;

/* Compute the bounding box for a string.  */
- (NSSize) boundingBoxForString: (NSString *)text;

@end

#endif /* _gsgd_GDFont_h__ */
