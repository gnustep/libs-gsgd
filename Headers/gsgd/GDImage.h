/* GDImage.h - Interface of GDImage -*-objc-*_
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:  Manuel Guesdon <mguesdon@orange-concept.com>
   Created: August 1999
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

#ifndef _gsgd_GDImage_h__
#define _gsgd_GDImage_h__

#include <gd.h>
#include <Foundation/NSObject.h>
#include <Foundation/NSGeometry.h>

/* Data format for images that we can read/write.  */
typedef unsigned GDImageDataFormat;

enum {
  GDPNGImageDataFormat = 0,
  GDJPEGImageDataFormat = 1,
  GDGDImageDataFormat = 2,
  GDWBMPImageDataFormat = 3
};

@class GDSimpleFont;

@interface GDImage : NSObject
{
  gdImagePtr _imagePtr;
}
/* 
 * Designated initializers. 
 */

/* Creates a new empty image.  */
- (id) initWithWidth: (int)width
	      height: (int)height;

/* Creates an image from existing data.  */
- (id) initWithData: (NSData *)data
	     format: (GDImageDataFormat)f;

/* To load a file into an image, first load the file into a NSData
 * object, then create a GDImage with that NSData.  */

/*
 * Other initializers.
 */

+ (id) imageWithWidth: (int)width  height: (int)height;

+ (id) imageWithData: (NSData *)data
	      format: (GDImageDataFormat)f;

/*
 * Deallocating the object.
 */
- (void) dealloc;    

/*
 * Accessing the underlying gdImage object
 */
- (gdImagePtr) imagePtr;

/*
 * Writing the image
 */

/* Generate NSData for the image in the specified format.  Extra info
 * can be used to specify further format specific information; use -1
 * to get the default.  Valid extra information at the moment are: for
 * GDJPEGImageDataFormat, info can be the image quality (a number
 * between 0 and 95; if -1 is used, the default jpeg image quality is
 * used); for GDWBMPImageDataFormat, info can be the index of the
 * color to be rendered as black (wbmp are black and white; gd renders
 * a single color as black, and all others as white) [if -1 is used,
 * the color closest to black in the image is the color rendered as
 * black].  For all other data formats, the extraInfo is ignored.
 */
- (NSData *) dataWithFormat: (GDImageDataFormat)f
		  extraInfo: (int)info;

/* Generate NSData for the image in the specified format, using the
 * default extra information.  */
- (NSData *) dataWithFormat: (GDImageDataFormat)f;

/* Simple friendly wrappers for -dataWithFormat:extraInfo:.  */
- (NSData *) pngData;
- (NSData *) jpegData;
- (NSData *) jpegDataWithQuality: (int)q;
- (NSData *) wbmpData;
- (NSData *) wbmpDataWithForegroundColor: (int)c;
- (NSData *) gdData;

/*
 * Setting writing properties.
 */

/* Sets whether the image is written in interlace or non-interlace
 * mode (only meaningful for jpeg and png output).  */
- (void) setInterlace: (BOOL)interlace;
- (BOOL) interlace;


/* TODO - work from here down.  */

- (void) setPixelX: (int)x
		 y: (int)y
	     color: (int)color;

- (int) pixelX: (int)x
	     y: (int)y;
- (int) width;
- (int) height;

/* Drawing */
- (void) lineFromX: (int)x1
		 y: (int)y1
	       toX: (int)x2
		 y: (int)y2
	     color: (int)color;

- (void) dashedLineFromX: (int)x1
		       y: (int)y1
		     toX: (int)x2
		       y: (int)y2
		   color: (int)color;
- (void) polygon: (gdPointPtr)points
	   count: (int)numPoints
	   color: (int)color;
- (void) filledPolygon: (gdPointPtr)points
		 count: (int)numPoints
		 color: (int)color;
- (void) rectFromX: (int)x1
		 y: (int)y1
	       toX: (int)x2
		 y: (int)y2
	     color: (int)color;
- (void) filledRectFromX: (int)x1
		       y: (int)y1
		     toX: (int)x2
		       y: (int)y2
		   color: (int)color;
- (void) fillToBorderX: (int)x
		     y: (int)y
		border: (int)b
		 color: (int)color;
- (void) fillX: (int)x
	     y: (int)y
	 color: (int)color;
- (void) setBrush: (GDImage *)brush;
- (void) setTile: (GDImage *)tile;
- (void) setStyle: (int *)style
	   length: (int)length;
- (BOOL) boundsSafeX: (int)x
		   y: (int)y;

/* Arcs handling */
- (void) arcCenterX: (int)x
		  y: (int)y
	      width: (int)width
	     height: (int)heigth
	      start: (int)start
	       stop: (int)stop
	      color: (int)color;
- (void) arcLineCenterX: (int)x
		      y: (int)y
		  width: (int)width
		 height: (int)height
		  start: (int)start
		   stop: (int)stop
		  color: (int)color;
- (void) arcFillCenterX: (int)x
		      y: (int)y
		  width: (int)width
		 height: (int)height
		  start: (int)start
		   stop: (int)stop
		  color: (int)color;
- (void) arcFillCenterX: (int)x
		      y: (int)y
		  width: (int)width
		 height: (int)height
		  start: (int)start
		   stop: (int)stop
		  color: (int)color
	    borderColor: (int)borderColor;

/* Colors */
- (int) blueOf: (int)color;
- (int) greenOf: (int)color;
- (int) redOf: (int)color;
+ (int) brushed;
+ (int) maxColors;
+ (int) styled;
+ (int) styledBrushed;
+ (int) dashSize;
+ (int) tiled;
+ (int) transparent;
- (int) newColorWithRed: (int)red
		  green: (int)green
		   blue: (int)blue;
- (int) closestColorToRed: (int)red
		    green: (int)green
		     blue: (int)blue;
- (int) exactColorWithRed: (int)red
		    green: (int)green
		     blue: (int)blue;
- (int) totalColors;
- (int) transparent;
- (void) setTransparent: (int)color;
- (void) setBackgroundColor: (int)color;

/* Copying and resizing */
- (id) copy;
- (void) copyRectFrom: (GDImage *)image
		    x: (int)sourceX
		    y: (int)sourceY
		width: (int)width
	       height: (int)height
		  toX: (int)destX
		    y: (int)destY;
- (void) copyRectFrom: (GDImage *)image
		    x: (int)sourceX
		    y: (int)sourceY
		width: (int)width
	       height: (int)height
		  toX: (int)destX
		    y: (int)destY
		width: (int)destWidth
	       height: (int)destHeight;

/* Fonts and text-handling */
- (void) character: (char)char_
		 x: (int)x
		 y: (int)y
	     color: (int)color
	    inFont: (GDSimpleFont *)font;
- (void) characterUp: (char)char_
		   x: (int)x
		   y: (int)y
	       color: (int)color
	      inFont: (GDSimpleFont *)font;
- (void) string: (NSString *)string
	      x: (int)x
	      y: (int)y
	  color: (int)color
	 inFont: (GDSimpleFont *)font;

- (NSString *) stringTTF: (NSString *)string
		       x: (int)x
		       y: (int)y
		   color: (int)color
		fontPath: (NSString *)fontPath_
	       pointSize: (int)ptSize_
		   angle: (double)angle_
     disableAntiAliasing: (BOOL)disableAA_;  

- (NSString *) stringTTF:(NSString *)string
		       x:(int)x
		       y:(int)y
		   color:(int)color
		fontPath:(NSString *)fontPath_
	       pointSize:(int)ptSize_
		   angle:(double)angle_
     disableAntiAliasing:(BOOL)disableAA_
 lowerLeftBoundingCorner: (NSPoint *)lowerLeft_
lowerRightBoundingCorner: (NSPoint *)lowerRight_
 upperLeftBoundingCorner: (NSPoint *)upperLeft_
upperRightBoundingCorner: (NSPoint *)upperRight_;

/* Get Bounding Corners Only */
- (NSString *) stringTTF: (NSString *)string
		       x: (int)x
		       y: (int)y
		fontPath: (NSString *)fontPath_
	       pointSize: (int)ptSize_
		   angle: (double)angle_
     disableAntiAliasing: (BOOL)disableAA_
 lowerLeftBoundingCorner: (NSPoint *)lowerLeft_
lowerRightBoundingCorner: (NSPoint *)lowerRight_
 upperLeftBoundingCorner: (NSPoint *)upperLeft_
upperRightBoundingCorner: (NSPoint *)upperRight_;

- (void) stringUp: (NSString *)string
		x: (int)x
		y: (int)y
	    color: (int)color
	   inFont: (GDSimpleFont *)font;

@end

#endif /* _gsgd_GDImage_h__ */

