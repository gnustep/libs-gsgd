/* GDLineStyle.h - Interface of GDLineStyle  -*-objc-*-
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

#ifndef _gsgd_GDLineStyle_h__
#define _gsgd_GDLineStyle_h__

#include <Foundation/NSObject.h>

@class GDFrame;

/* A GDLineStyle object is used to specify how a line is to be drawn.
 * For example, dotted or dashed lines.  A GDLineStyle object holds an 
 * array of pixel colors, which is the pattern to repeat when drawing
 * a line using this GDLineStyle.
 */
@interface GDLineStyle : NSObject
{
  int length;
  int *colors;
}

/*
 * Ready-to-use line styles
 */

/* Return the default dotted line style.  Draw a pixel in color,
 * followed by three transparent pixels.  */
+ (GDLineStyle *) dottedLineWithColor: (int)color;

/* Return a dotted line style.  Draw a pixel in color, followed by
 * spacing transparent pixels.  */
+ (GDLineStyle *) dottedLineWithColor: (int)color
                            spacing: (int)spacing; 

/* Return the default dashed line style.  Draw three pixels in color
 * color, followed by three transparent pixels.  */
+ (GDLineStyle *) dashedLineWithColor: (int)color;

/* Return a dashed line style.  Draw spacing pixel in color, followed
 * by spacing transparent pixels.  */
+ (GDLineStyle *) dashedLineWithColor: (int)color
			      spacing: (int)spacing;

/* Return the default dashdot line style.  Draw three pixels in color
 * color, followed by three transparent pixels, followed by one pixel
 * in color color, followed by three transparent pixels.  */
+ (GDLineStyle *) dashdotLineWithColor: (int)color;

/* Return a dashdot line style.  Draw spacing pixel in color, followed
 * by spacing transparent pixels, followed by one pixel in color,
 * followed by spacing transparent pixels.  */
+ (GDLineStyle *) dashdotLineWithColor: (int)color
			       spacing: (int)spacing;

/* Return a style using a single color.  */
+ (GDLineStyle *) lineWithColor: (int)color;

/*
 * Initializers
 */

/* Designed initializer.  Create a new GDLineStyle holding a specified
 * pattern of pixel colors.  If c is NULL, the pattern is filled with
 * transparent pixels. */
- (id) initWithLength: (int)l
	  pixelColors: (int *)c;

/* Create a new GDLineStyle which holds a pattern of length l pixels.
 * All pixels are initially initialized as transparent.  */
- (id) initWithLength: (int)l;

/*
 * Manipulating line styles
 */

/* Change the color used to draw the pixel at index i in the pattern.
 * The color might be a palette index for a palette image, or just a color
 * for a true color image.  */
- (void) setPixelColor: (int)color
	       atIndex: (int)i;

/* Change the pattern so that the pixel at index i is transparent, that
 * is, it is not drawn at all.  */
- (void) setPixelTransparentAtIndex: (int)i;

/*
 * Accessing line styles
 */

/* Return the length of the pattern.  */
- (int) length;

/* Return the pattern as a (int *) array (which must not be freed! it's the
 * array how it is used internally).  Used internally by GDImage.  */
- (int *) colors;

/*
 * Drawing a legend icon for this line style
 */
- (void) plotLegendIconInFrame: (GDFrame *)frame;

@end

#endif /* _gsgd_GDLineStyle_h__ */

