/* GDImage.h - Interface of GDImage  -*-objc-*-
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:  Manuel Guesdon <mguesdon@orange-concept.com>
   Created: August 1999
   Rewritten by: Nicola Pero <n.pero@mi.flashnet.it>
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
  /* PNG */
  GDPNGImageDataFormat = 0,

  /* JPEG */
  GDJPEGImageDataFormat = 1,

  /* GD (libgd specific format) */
  GDGDImageDataFormat = 2,

  /* WBMP */
  GDWBMPImageDataFormat = 3
};

/* Options for drawing arcs.  You can || together the options
 * enumerated below.  NB: we support these options on libgd < 2.0 as
 * well.  */
typedef unsigned GDImageArcOptions;

enum {

  /* Draw the arc.  */
  GDDrawArcImageArcOption = 1,

  /* Fill the area of the circle corresponding to the arc.  */
  GDFillArcAreaImageArcOption = 2,

  /* Draw lines connecting the edge of the arc to the center.  */
  GDDrawArcEdgesImageArcOption = 4
};


@class GDLineStyle;

@class GDFont;

@interface GDImage : NSObject
{
  gdImagePtr _imagePtr;

  /* These are used to prevent the tile and brush image to be destroyed
   * while the gdImagePtr still holds a pointer to them.  */
  GDImage *tileImage;
  GDImage *brushImage;
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
 * Accessing the underlying gdImage object
 */
- (gdImagePtr) imagePtr;

/*
 * Writing the image
 */

/* Generate NSData for the image in the specified format.  Options
 * can be used to specify further format specific information; use nil
 * to get the default.
 *
 * Valid options at the moment are:
 *
 * for GDJPEGImageDataFormat,
 *   Quality: a number between 0 and 95 representing the image quality;
 *   Interlace: a string, YES or NO (default is NO)
 *
 * for GDWBMPImageDataFormat, 
 *   ForegroundColor: a number, the index of the color to be rendered
 *   as black (wbmp are black and white; gd renders a single color
 *   as black, and all others as white) [if not specified, the color
 *   closest to black in the image is the color rendered as black].
 * 
 * for GDPNGImageDataFormat,
 *   Interlace: a string, YES or NO (default is NO).
 */
- (NSData *) dataWithFormat: (GDImageDataFormat)f
		    options: (NSDictionary *)options;

/* Generate NSData for the image in the specified format, using the
 * default extra information.  */
- (NSData *) dataWithFormat: (GDImageDataFormat)f;

/* Simple friendly wrappers for -dataWithFormat:options:.  */
- (NSData *) pngData;
- (NSData *) jpegData;
- (NSData *) jpegDataWithQuality: (int)q;
- (NSData *) wbmpData;
- (NSData *) wbmpDataWithForegroundColor: (int)c;
- (NSData *) gdData;

/*
 * Image properties.
 */
- (int) width;
- (int) height;

/*
 * Colors 
 */

/* Part of the work of drawing inside images consists in setting up
 * and managing the colors you want to use.
 *
 * Standard palette images have a palette of 256 RGB colors.  Each
 * image has a different palette; you can freely choose the colors you
 * want to use in the palette of each image.  When you want to draw a
 * pixel, or a line, or do other drawing operations, you need to
 * supply the index (in the image palette) of the color you want to be
 * used.  This index is an integer - normally a number between 0 and
 * 255.
 *
 * Truecolor images (supported from libgd >= 2.0) allow an unlimited
 * number of RGBA colors; you still pass an integer to each drawing
 * operation to specify which color you want to be used; but it's no
 * longer an index in an associated palette; there is no image palette
 * and you get the integer associated with the color in a different
 * way (which allows much more freedom).  Truecolor images are not
 * currently supported in gsgd, but it should be easy to add support
 * for them.
 *
 * All methods containing 'Palette' in the name make no sense and should
 * not be used for 'TrueColor' images.
 */

/* The maximum number of colors in a palette image.  Currently
 * 256.  */
+ (int) maxPaletteColors;

/* These are `special' colors which cause special techniques to be
 * used when passed as the color to a drawing operation.  */
+ (int) brushedColor;
+ (int) styledColor;
+ (int) styledBrushedColor;
+ (int) tiledColor;

/* Number of colors currently in the image palette.  Makes *no* sense
 * for truecolor images.  */
- (int) totalPaletteColors;

/* In palette images, it is possible to specify that a color in the
 * palette is to be rendered as transparent if the image viewer
 * supports it.  If the image viewer (web browser, whatever) does not
 * support transparency, the color is rendered using its standard RGB
 * values, so make sure you use something reasonable for RGB value in
 * case the image viewer does not support transparency.  */
- (int) paletteTransparentColor;
- (void) setPaletteTransparentColor: (int)color;

/* Allocate a new palette color with the specified R, G, B values.  If
 * there is no more space in the palette for a new color, -1 is
 * returned; otherwise, the index of the color in the palette is
 * returned; this index must always be used to refer to this
 * color.  */
- (int) allocatePaletteColorWithRed: (int)red
			      green: (int)green
			       blue: (int)blue;

/* Deallocate an existing palette color, freeing the palette entry so that
 * it can be reused.
 */
- (void) deallocatePaletteColor: (int)color;

/* Read the R, G, B values of a palette color.  */
- (int) blueOfPaletteColor: (int)color;
- (int) greenOfPaletteColor: (int)color;
- (int) redOfPaletteColor: (int)color;


/* Search existing colors in the palette.  */
- (int) closestPaletteColorToRed: (int)red
			   green: (int)green
			    blue: (int)blue;

- (int) exactPaletteColorWithRed: (int)red
			   green: (int)green
			    blue: (int)blue;

/* The highest level routine to get a color in the palette - uses an
 * existing color if already there; otherwise creates a new color; if
 * there is no more space in the palette, reuses the closest existing
 * palette color.  */
- (int) resolvePaletteColorWithRed: (int)red
			     green: (int)green 
			      blue: (int)blue;

#if 0
/* For libgd >= 2.0, to get true colors.  */
+ (int) trueColorWithRed: (int)red
		   green: (int)green
		    blue: (int)blue;

+ (int) trueColorWithRed: (int)red
		   green: (int)green
		    blue: (int)blue
		   alpha: (int)alpha
#endif


/*
 * Named colors	
 */

/* The following names are recognized:
 *
 * black, silver, gray, white, maroon, red, purple, fuchsia,
 * green, lime, olive, yellow, navy, blue, teal, aqua
 *
 * (from the HTML 3.2 spec)
 */

- (int) allocatePaletteColorWithName: (NSString *)name;

#if 0
+ (int) trueColorWithName: (NSString *)name;
#endif

/*
 * Accessing image pixels.
 */

- (void) setPixelColor: (int)color
		    at: (NSPoint)point;

- (int) pixelColorAt: (NSPoint)point;


/*
 * Drawing 
 */

/* Draw a line in the specified color.
 *
 * To get special effects, 'color' can also be [GDImage +styledColor],
 * in which case the styled pattern (which must have been set by using
 * -setLineStyle:) is used (used for drawing dashed lines etc), or
 * [GDImage +brushedColor], in which case the brushed image (which
 * must have been set by using -xxx) is used, or [GDImage
 * styledBrushedColor], in which case both the style and the brush are
 * used.
 */
- (void) drawLine: (NSPoint)startPoint
	       to: (NSPoint)endPoint
	    color: (int)color;


/* Draw a rectangle (four lines).  Color might be +styledColor or
 * +brushColor.  */
- (void) drawRectangle: (NSRect)aRectangle
		 color: (int)color;

/* Draw a filled rectangular area.  Color might be +tiledColor to fill
 * the rectangle using a tiled image.  */
- (void) drawFilledRectangle: (NSRect)aRectangle
		       color: (int)color;


/*
 * Filling/flooding areas with color
 */

/* Flood the image with color, starting from the point at x, y.  All
 * pixels around the one at x, y and of the same color, are repainted
 * with the specified color.  */
- (void) fillFrom: (NSPoint)startPoint
       usingColor: (int)color;

/* Flood the image with color, starting from the point at x, y.  All
 * pixels around the one at x, y are repainted with the specified
 * color.  The flooding repaints all pixels, no matter what their
 * original color is, unless their color is borderColor - in which
 * case they are untouched and the flooding stops in that direction.
 * The net effect is that the image is flood up to the borders of
 * color borderColor.
 */
- (void) fillFrom: (NSPoint)startPoint
       usingColor: (int)color
	 toBorder: (int)borderColor;


/*
 * Draw polygons
 */
- (void) drawPolygon: (gdPoint *)points
	       count: (int)numPoints
	       color: (int)color;

- (void) drawFilledPolygon: (gdPoint *)points
		     count: (int)numPoints
		     color: (int)color;

/*
 * Draw arcs
 */

/* Draw an arc of ellipse with center x, y and the specified width and
 * height (basically, width and height are the axis of the ellipse);
 * starting at the specified angle (in degrees) and ending at the
 * specified angle (in degrees).  'options' decide exactly what to do
 * - the arc, or fill the circle area corresponding to the arc with
 * color, or draw lines connecting the center to the arc edges (more
 * of these things can be done at once if the corresponding options
 * are ||ed together).
 */
- (void) drawArc: (NSRect)ellipseBoundingRect
      startAngle: (int)startDegrees
       stopAngle: (int)stopDegrees
	   color: (int)color
	 options: (GDImageArcOptions)options;

/* 
 * Special drawing effects
 */

/* Set the brush image to be used when drawing lines in brushed mode.
 * To use brushed drawing mode, you must pass [GDImage +brushedColor]
 * as the color in drawing functions.  When using brushed mode, the
 * brush image is drawn in place of each pixel of the line which is
 * being drawn.  The effect is similar to the 'brush' tool in drawing
 * programs like Gimp.
 */
- (void) setBrushImage: (GDImage *)brush;
- (GDImage *)brushImage;

/* Set the tile to be used when filling areas in tiled mode.
 * To use tiled filling mode, you must pass [GDImage +tiledColor]
 * as the fill color in drawing functions.  When using tiled mode,
 * the area to fill is filled with copies of the tiled image.
 */
- (void) setTileImage: (GDImage *)tile;
- (GDImage *)tileImage;

/* Set the line style to be used when drawing lines in styled mode.
 * To use styled drawing mode, you must pass [GDImage +styledColor] as
 * the color in drawing functions.  When using styled mode, the pixels
 * are drawn by repeating applying the pattern specified by the
 * GDLineStyle object.  For example, the style might specify to draw 3
 * pixels red, then 3 pixels white, resulting in a dashed line when
 * the style is used to draw.  A GDLineStyle might also specify to
 * skip drawing some pixels (eg, draw 3 pixels red, then skip 3
 * pixels).
 */
- (void) setLineStyle: (GDLineStyle *)style;

/*
 * Copying
 */

/* FIXME: we currently do not copy 'temporary' drawing attributes such
 * as tileImage, brushImage and lineStyle.  This is for laziness at
 * implementing copying the lineStyle.  */
- (id) copyWithZone: (NSZone *)aZone;

- (void) copyFromImage: (GDImage *)image
		  rect: (NSRect)sourceRectangle
		    to: (NSPoint)destOrigin;

- (void) copyFromImage: (GDImage *)image
		  rect: (NSRect)sourceRectangle
	  toScaledRect: (NSRect)destRectangle;

/*
 * String drawing
 */
- (void) drawCharacter: (char)c
		  from: (NSPoint)point
		 color: (int)color
		  font: (GDFont *)font;

- (void) drawCharacterUp: (char)c
		    from: (NSPoint)point
		   color: (int)color
		    font: (GDFont *)font;

- (void) drawString: (NSString *)string
	       from: (NSPoint)point
	      color: (int)color
	       font: (GDFont *)font;

- (void) drawStringUp: (NSString *)string
		 from: (NSPoint)point
		color: (int)color
		 font: (GDFont *)font;

/*
 * FreeType string drawing
 */

/* This method draws a string using the specified ttf font.  x, y are
 * the origin of the string; color is the color; fontPath is the font
 * path of the font (see the libgd doc for more info);
 * disableAntiAliasing automatically replaces color with -color (used
 * by libgd to signal that AA should be disabled).  boundingRect is
 * used to return info about the actual rectangle taken up by the
 * string.  It is an array of 8 integers, containing the x, y
 * coordinates of the four bounding rectangle corners - the corners
 * being enumerated counter-clockwise starting from the lower left
 * one.  You can safely pass NULL as boundingRect if you don't need
 * that info.  Raises an exception if something goes really wrong.
 */
- (void) drawStringFreeType: (NSString *)string
		       from: (NSPoint)point
		      color: (int)color
		   fontPath: (NSString *)fontPath
		  pointSize: (int)ptSize
		      angle: (double)radians
	disableAntiAliasing: (BOOL)disableAA
	       boundingRect: (int *)rect;

/* Get the bounding rect for a string without drawing it.  */
+ (void) getBoundingRect: (int *)rect
          stringFreeType: (NSString *)string
	        fontPath: (NSString *)fontPath
  	       pointSize: (int)ptSize
	           angle: (double)radians;

@end

#endif /* _gsgd_GDImage_h__ */

