/* GDFrame.h - A rectangular area of a GDImage  -*-objc-*-
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

#ifndef _gsgd_GDFrame_h__
#define _gsgd_GDFrame_h__

#include <Foundation/NSObject.h>
#include <Foundation/NSGeometry.h>

@class GDImage;

/* A GDFrame object is used to hold a rectangular area of a GDImage,
 * with a standard x, y coordinate system starting from the lower left
 * corner.
 *
 * GDFrame can convert points from the GDFrame coordinate system into
 * the GDImage coordinate system.
 *
 * Each GDFrame is a direct sub-rectangle of the GDImage.
 *
 * When a Chart or Plot object needs to draw in a GDImage, it is
 * normally given a GDFrame in which to draw (this GDFrame might
 * eventually cover the whole GDImage, if the whole image should
 * contain a single plot; might cover only a part if the image
 * contains multiple plots).
 *
 * The object will divide the frame into subframes, and pass the
 * subframes to drawing routines so that they can draw in the frame.
 *
 */
@interface GDFrame : NSObject
{
  /* The GDImage this frame belongs to.  */
  GDImage *_image;

  /* The coordinates of the GDFrame lower left corner in the GDImage
   * coordinate system.
   *
   * This is for easier conversion of coordinates ... A point of
   * coordinates (a, b) in the GDFrame coordinate system has
   * coordinates (x + a, y - b) in the GDImage coordinate system.
   */
  int _x;
  int _y;

  /* The size of the GDFrame.  */
  int _width;
  int _height;
}

/* Create a GDFrame covering the whole image.  */
- (id) initWithImage: (GDImage *)image;

/* Create a GDFrame covering a part of the image.  area is the
 * rectangle covered by the GDFrame in the GDImage coordinate
 * system.  */
- (id) initWithImage: (GDImage *)image
		rect: (NSRect)area;

/* Create a GDFrame covering the whole image.  */
+ (GDFrame *) frameForImage: (GDImage *)image;

/* Return the image we belong to.  */
- (GDImage *) image;

/* The size of the frame.  */
- (int) width;
- (int) height;

/* Convert a point in the frame coordinate system into the image
 * coordinate system.  (using (0, 0) will give you the position of the
 * lower left corner of the frame)  */
- (NSPoint) convertFrameToImage: (NSPoint)framePoint;

/* Convert a point in the image coordinate system into the frame
 * coordinate system.  */
- (NSPoint) convertImageToFrame: (NSPoint)imagePoint;

/* Convert a rectangle from frame to image.  */
- (NSRect) convertFrameRectToImage: (NSRect)frameRect;

- (NSRect) convertImageRectToFrame: (NSRect)frameRect;

/* Creates a new GDFrame (totally independent from the old one) which
 * represents an area in the image which covers the 'newFrameArea',
 * expressed in the existing GDFrame coordinate system.  */
- (GDFrame *) subFrameWithRect: (NSRect)newFrameArea;

@end

#endif /* _gsgd_GDFrame_h__ */

