/* GDImage.m - Implementation of GDImage
   Copyright (C) 1999, 2002 Free Software Foundation, Inc.
   
   Written by: Manuel Guesdon <mguesdon@orange-concept.com>
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

#include <gsgd/GDImage.h>
#include <Foundation/NSData.h>
#include <Foundation/NSDebug.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSException.h>
#include <Foundation/NSString.h>
#include <Foundation/NSValue.h>

#include <gsgd/GDLineStyle.h>

#include <gsgd/GDFont.h>

/* For cos, sin */
#include <math.h>

/* We use this context to keep track of the state of the process when
 * we have data to be fed to the gd library.  */
typedef struct _GDDataReadContext
{
  unsigned length;
  const void *bytes;
  unsigned position;
} GDDataReadContext;


/* This is the function that reads the data and feeds them to the gd
 * library.  */
static int GDDataReadWrapper (void *context, char *buf, int len)
{
  GDDataReadContext *readContext = (GDDataReadContext *)context;

  /* We need to clip data reading at the boundary.  */
  if (readContext->position + len > readContext->length)
    {
      len = readContext->length - readContext->position;
    }

  /* Copy the data in the output buffer.  */
  memcpy (buf, readContext->bytes + readContext->position, len);
  
  /* Update position.  */
  readContext->position += len;

  return len;
}


@implementation GDImage

/* 
 * Designated initializers.
 */
- (id) initWithWidth: (int)width
	      height: (int)height
{
  _imagePtr = gdImageCreate (width, height);
  return self;
}

- (id) initWithData: (NSData *)data
	     format: (GDImageDataFormat)f
{
  GDDataReadContext *ctx;
  gdSource *ourGdSource;
  gdIOCtx *gdCtx;

  ctx = (GDDataReadContext *)(objc_malloc (sizeof (GDDataReadContext)));
  ctx->length = [data length];
  ctx->bytes = [data bytes];
  ctx->position = 0;

  ourGdSource = (gdSource *)(objc_malloc (sizeof (gdSource)));
  ourGdSource->source = GDDataReadWrapper;
  ourGdSource->context = ctx;

  gdCtx = gdNewSSCtx (ourGdSource, NULL);
  
  switch (f)
    {
    case GDPNGImageDataFormat:
      {
	_imagePtr = gdImageCreateFromPngCtx (gdCtx);
	break;
      }
    case GDJPEGImageDataFormat:
      {
	_imagePtr = gdImageCreateFromJpegCtx (gdCtx);
	break;
      }
    case GDGDImageDataFormat:
      {
	_imagePtr = gdImageCreateFromGdCtx (gdCtx);
	break;
      }
    case GDWBMPImageDataFormat:
      {
	_imagePtr = gdImageCreateFromWBMPCtx (gdCtx);
	break;
      }
    default:
      {
	gdFree (gdCtx);
	objc_free (ourGdSource);
	objc_free (ctx);
	[NSException raise: NSGenericException  
		     format: @"Unknown data format to read"];
      }
    }

  gdFree (gdCtx);
  objc_free (ourGdSource);
  objc_free (ctx);

  return self;
}

/*
 * Other initializers.
 */
+ (id) imageWithWidth: (int)width
	       height: (int)height
{
  return [[[self alloc] initWithWidth: width  height: height] autorelease];
}

+ (id) imageWithData: (NSData *)data
	      format: (GDImageDataFormat)f
{
  return [[[self alloc] initWithData: data  format: f] autorelease];
}

/*
 * Deallocating the object.
 */
- (void) dealloc
{
  TEST_RELEASE (brushImage);
  TEST_RELEASE (tileImage);
  gdImageDestroy (_imagePtr);
  [super dealloc];
}

/*
 * Accessing the underlying gdImage object
 */
- (gdImagePtr) imagePtr
{
  return _imagePtr;
}

/*
 * Writing the image
 */
- (NSData *) dataWithFormat: (GDImageDataFormat)f
		    options: (NSDictionary *)options
{
  NSData *output = nil;
  void *bytes = NULL;
  int size;

  /* Manage Interlace option.  */
  {
    NSString *interlace = [options objectForKey: @"Interlace"];
    
    if (interlace != nil  &&  [interlace isEqualToString: @"YES"])
      {
	gdImageInterlace (_imagePtr, 1);
      }
    else
      {
	gdImageInterlace (_imagePtr, 0);
      }
  }
  
  switch (f)
    {
    case GDPNGImageDataFormat:
      {
	bytes = gdImagePngPtr (_imagePtr, &size);
	break;
      }
    case GDJPEGImageDataFormat:
      {
	/* Quality is a value between 0-95.
	   Pass -1 to get the default quality.  */
	int q = -1;
	{
	  NSNumber *quality = [options objectForKey: @"Quality"];

	  if (quality != nil  &&  [quality isKindOfClass: [NSNumber class]])
	    {
	      q = [quality intValue];
	    }

	  if (q < 0 || q > 95)
	    {
	      q = -1;
	    }
	}

	bytes = gdImageJpegPtr (_imagePtr, &size, q);
	break;
      }
    case GDGDImageDataFormat:
      {
	bytes = gdImageGdPtr (_imagePtr, &size);
	break;
      }
    case GDWBMPImageDataFormat:
      {
	/* The color to use as foreground in this case.
	   Pass -1 to get 'black' (or if black is not found, the best
	   match for black) used.  */
	int foreground = -1;
	{
	  NSNumber *fore = [options objectForKey: @"Foreground"];
	  
	  if (fore != nil  &&  [fore isKindOfClass: [NSNumber class]])
	    {
	      foreground = [fore intValue];
	    }
	}	


	if (foreground < 0)
	  {
	    foreground = gdImageColorClosest (_imagePtr, 0, 0, 0);
	    
	    /* No colors defined in the image! */
	    if (foreground < 0)
	      {
		return nil;
	      }
	  }
	
	bytes = gdImageWBMPPtr (_imagePtr, &size, foreground);
	break;
      }
    default:
      {
	[NSException raise: NSGenericException  
		     format: @"Unknown data format to write"];
      }
    }
  
  NS_DURING
    {
      output = [NSData dataWithBytes: bytes  length: size];
    }
  NS_HANDLER
    {    
      gdFree (bytes);
      [localException raise];
    }
  NS_ENDHANDLER

  gdFree (bytes);
  
  return output;
}

- (NSData *) dataWithFormat: (GDImageDataFormat)f
{
  return [self dataWithFormat: f  options: nil];
}

- (NSData *) pngData
{
  return [self dataWithFormat: GDPNGImageDataFormat];
}

- (NSData *) jpegData
{
  return [self dataWithFormat: GDJPEGImageDataFormat];
}

- (NSData *) jpegDataWithQuality: (int)q
{
  return [self dataWithFormat: GDJPEGImageDataFormat  
	       options: [NSDictionary dictionaryWithObject: 
					[NSNumber numberWithInt: q]
				      forKey: @"Quality"]];
}

- (NSData *) wbmpData
{
  return [self dataWithFormat: GDWBMPImageDataFormat];
}

- (NSData *) wbmpDataWithForegroundColor: (int)c
{
  return [self dataWithFormat: GDWBMPImageDataFormat  
	       options: [NSDictionary dictionaryWithObject: 
					[NSNumber numberWithInt: c]
				      forKey: @"Foreground"]];
}

- (NSData *) gdData
{
  return [self dataWithFormat: GDGDImageDataFormat];
}

/*
 * Image properties.
 */
- (int) width
{
  return gdImageSX (_imagePtr);
}

- (int) height
{
  return gdImageSY (_imagePtr); 
}

/*
 * Colors 
 */

+ (int) maxPaletteColors
{
  return gdMaxColors;
}

+ (int) brushedColor
{
  return gdBrushed;
}

+ (int) styledColor
{
  return gdStyled;
}

+ (int) styledBrushedColor
{
  return gdStyledBrushed;
}

+ (int) tiledColor
{
  return gdTiled;
}

- (int) totalPaletteColors
{
  return gdImageColorsTotal (_imagePtr);
}

- (int) paletteTransparentColor
{
  return gdImageGetTransparent (_imagePtr);
}

- (void) setPaletteTransparentColor: (int)color
{
  gdImageColorTransparent (_imagePtr, color);
}

- (int) allocatePaletteColorWithRed: (int)red
			      green: (int)green
			       blue: (int)blue
{
  return gdImageColorAllocate (_imagePtr, red, green, blue);
}

- (void) deallocatePaletteColor: (int)color
{
  return gdImageColorDeallocate (_imagePtr, color);
}

- (int) redOfPaletteColor: (int)color
{
  return gdImageRed (_imagePtr, color);
}

- (int) greenOfPaletteColor: (int)color
{
  return gdImageGreen (_imagePtr, color);
}

- (int) blueOfPaletteColor: (int)color
{
  return gdImageBlue (_imagePtr, color);
}

- (int) closestPaletteColorToRed: (int)red
			   green: (int)green
			    blue: (int)blue
{
  return gdImageColorClosest (_imagePtr, red, green, blue);  
}

- (int) exactPaletteColorWithRed: (int)red
			   green: (int)green
			    blue: (int)blue
{
  return gdImageColorExact (_imagePtr, red, green, blue);
}

- (int) resolvePaletteColorWithRed: (int)red
			     green: (int)green 
			      blue: (int)blue
{
  return gdImageColorResolve (_imagePtr, red, green, blue);
}

#if 0
+ (int) trueColorWithRed: (int)red
		   green: (int)green
		    blue: (int)blue
{
  return gdImageTrueColor (red, green, blue);
}


+ (int) trueColorWithRed: (int)red
		   green: (int)green
		    blue: (int)blue
		   alpha: (int)alpha
{
  return gdImageTrueColorAlpha (red, green, blue, alpha);
}
#endif

/*
 * Color names
 */

#define NUMBER_OF_COLOR_NAMES 16
static struct 
{
  char firstLetter;
  NSString *name;
  int red;
  int green;
  int blue;
} gsgdImageColorNameTable[NUMBER_OF_COLOR_NAMES] = 
  {
    {'a', @"aqua",      0, 255, 255},
    {'b', @"black",     0,   0,   0},
    {'b', @"blue",      0,   0, 255},
    {'f', @"fuchsia", 255,   0, 255},
    {'g', @"green",     0, 128,   0},
    {'g', @"gray",    128, 128, 128},
    {'l', @"lime",      0, 255,   0},
    {'m', @"maroon",  128,   0,   0},
    {'n', @"navy",      0,   0, 128},
    {'o', @"olive",   128, 128,   0},
    {'p', @"purple",  128,   0, 128},
    {'r', @"red",     255,   0,   0},
    {'s', @"silver",  192, 192, 192},
    {'t', @"teal",      0, 128, 128},
    {'w', @"white",   255, 255, 255},
    {'y', @"yellow",  255, 255,   0}
  };

/* this function is called after name has already been converted to
 * lowercase, and it's a non-empty string.  */
static inline void 
getColorForName (int *red, int *green, int *blue, NSString *name)
{
  int i;
  unichar c = [name characterAtIndex: 0];

  /* We accept colors in web notation.  */
  if (c == '#')
    {
      /* TODO ! */
      NSLog (@"Web #RRGGBB notation not implemented yet!");
      return;
    }
  
  
  for (i = 0; i < NUMBER_OF_COLOR_NAMES; i++)
    {
      if (gsgdImageColorNameTable[i].firstLetter == c)
	{
	  if ([gsgdImageColorNameTable[i].name isEqualToString: name])
	    {
	      *red = gsgdImageColorNameTable[i].red;
	      *green = gsgdImageColorNameTable[i].green;
	      *blue = gsgdImageColorNameTable[i].blue;
	      return;
	    }
	}
    }
  /* Not found.  */
  *red = -1;
  return;
}

- (int) allocatePaletteColorWithName: (NSString *)name
{
  int red, green, blue;

  if (name == nil  ||  [name length] < 1)
    {
      return -1;
    }
  
  name = [name lowercaseString];

  getColorForName (&red, &green, &blue, name);
  
  if (red == -1)
    {
      NSLog (@"Unknown color %@", name);
      return -1;
    }
  
  return [self allocatePaletteColorWithRed: red
	       green: green
	       blue: blue];
}


#if 0
+ (int) trueColorWithName: (NSString *)name
{
    int red, green, blue;

  if (name == nil  ||  [name length] < 1)
    {
      return -1;
    }
  
  name = [name lowercaseString];

  getColorForName (&red, &green, &blue, name);
  
  if (red == -1)
    {
      return -1;
    }
  
  return [self trueColorWithRed: red
	       green: green
	       blue: blue];
}
#endif

/*
 * Accessing image pixels.
 */

- (void) setPixelColor: (int)color
		    at: (NSPoint)point
{
  unsigned int x = (unsigned int)(point.x);
  unsigned int y = (unsigned int)(point.y);

  gdImageSetPixel (_imagePtr, x, y, color);
}

- (int) pixelColorAt: (NSPoint)point
{
  unsigned int x = (unsigned int)(point.x);
  unsigned int y = (unsigned int)(point.y);

  return gdImageGetPixel (_imagePtr, x, y);
}


/*
 * Drawing lines and rectangles
 */
- (void) drawLine: (NSPoint)startPoint
	       to: (NSPoint)endPoint
	    color: (int)color
{
  unsigned int x1 = (unsigned int)(startPoint.x);
  unsigned int y1 = (unsigned int)(startPoint.y);
  unsigned int x2 = (unsigned int)(endPoint.x);
  unsigned int y2 = (unsigned int)(endPoint.y);

  gdImageLine (_imagePtr, x1, y1, x2, y2, color);
}

- (void) drawRectangle: (NSRect)aRectangle
		 color: (int)color
{
  NSPoint cornerA = aRectangle.origin;
  NSPoint cornerB = NSMakePoint (aRectangle.origin.x, NSMaxY (aRectangle));
  NSPoint cornerC = NSMakePoint (NSMaxX (aRectangle), NSMaxY (aRectangle));
  NSPoint cornerD = NSMakePoint (NSMaxX (aRectangle), aRectangle.origin.y);

  [self drawLine: cornerA  to: cornerB  color: color];
  [self drawLine: cornerB  to: cornerC  color: color];
  [self drawLine: cornerC  to: cornerD  color: color];
  [self drawLine: cornerD  to: cornerA  color: color];
}

- (void) drawFilledRectangle: (NSRect)aRectangle
		       color: (int)color
{
  unsigned int x1 = (unsigned int)(NSMinX (aRectangle));
  unsigned int y1 = (unsigned int)(NSMinY (aRectangle));
  unsigned int x2 = (unsigned int)(NSMaxX (aRectangle));
  unsigned int y2 = (unsigned int)(NSMaxY (aRectangle));

  gdImageFilledRectangle (_imagePtr, x1, y1, x2, y2, color);
}


/*
 * Filling/flooding areas with color
 */

- (void) fillFrom: (NSPoint)startPoint
       usingColor: (int)color
	 toBorder: (int)borderColor
{
  unsigned int x = (unsigned int)(startPoint.x);
  unsigned int y = (unsigned int)(startPoint.y);

  gdImageFillToBorder (_imagePtr, x, y, borderColor, color);
}

- (void) fillFrom: (NSPoint)startPoint
       usingColor: (int)color
{
  unsigned int x = (unsigned int)(startPoint.x);
  unsigned int y = (unsigned int)(startPoint.y);

  gdImageFill (_imagePtr, x, y, color);
}

/*
 * Draw polygons
 */
- (void) drawPolygon: (gdPoint *)points
	       count: (int)numPoints
	       color: (int)color
{
  gdImagePolygon (_imagePtr, points, numPoints, color);
}

- (void) drawFilledPolygon: (gdPoint *)points
		     count: (int)numPoints
		     color: (int)color
{
  gdImageFilledPolygon (_imagePtr, points, numPoints, color);
}

/*
 * Draw arcs
 */
- (void) drawArc: (NSRect)ellipseBoundingRect
      startAngle: (int)startDegrees
       stopAngle: (int)stopDegrees
	   color: (int)color
	 options: (GDImageArcOptions)options
{
  /* Center of the ellipse.  */
  unsigned int x = (unsigned int)(NSMidX (ellipseBoundingRect));
  unsigned int y = (unsigned int)(NSMidY (ellipseBoundingRect));
  /* Size of the ellipse.  */
  unsigned int width = (unsigned int)(ellipseBoundingRect.size.width);
  unsigned int height = (unsigned int)(ellipseBoundingRect.size.height);

  /* First draw the arc if required.  */
  if (options & GDDrawArcImageArcOption
      || options & GDFillArcAreaImageArcOption)
    {
      gdImageArc (_imagePtr, x, y, width, height, 
		  startDegrees, stopDegrees, color);
    }

  /* Draw the edges if required.  */
  if (options & GDDrawArcEdgesImageArcOption
      || options & GDFillArcAreaImageArcOption)
    {
      /* The ellipsis semiaxis.  */
      float a = width / 2;
      float b = height / 2;
      
      /* The angle in radians.  */
      float radians;

#ifndef PI
#define PI 3.14153
#endif

      /* Connect the start point of the arc with the center.  */
      radians = (startDegrees * PI) / 180;
      gdImageLine (_imagePtr, 
		   x, y,
		   x + a * cos (radians), y + b * sin (radians), 
		   color);

      /* Connect the end point of the arc with the center.  */
      radians = (stopDegrees * PI) / 180;
      gdImageLine (_imagePtr, 
		   x, y,
		   x + a * cos (radians), y + b * sin (radians), 
		   color);
    }


  /* Fill if required.  Warning - it currently doesn't work in all
   * cases when drawing *over* existing images ... existing pixels of
   * color color in the area we want to fill might cause problems.  */
  if (options & GDFillArcAreaImageArcOption)
    {
      /* We search a point inside the area, and fill starting from
       * there.  */

      /* The ellipsis semiaxis.  */
      float a = width / 2;
      float b = height / 2;
      
      /* The angle at the middle of the arc, in radians.  */
      float radians = (((startDegrees + stopDegrees) / 2) * PI) / 180;
      
      gdImageFillToBorder (_imagePtr, 
			   x + (a * cos (radians) / 2),
			   y + (b * sin (radians) / 2),
			   color, color);
    }
}

/* 
 * Special drawing effects
 */

- (void) setBrushImage: (GDImage *)brush
{
  ASSIGN (brushImage, brush);
  gdImageSetBrush (_imagePtr, brush->_imagePtr);
}

- (GDImage *)brushImage
{
  return brushImage;
}

- (void) setTileImage: (GDImage *)tile
{
  ASSIGN (tileImage, tile);
  gdImageSetTile (_imagePtr, tile->_imagePtr);
}

- (GDImage *)tileImage
{
  return tileImage;
}

- (void) setLineStyle: (GDLineStyle *)style
{
  int length = [style length];
  int *colors = [style colors];

  gdImageSetStyle (_imagePtr, colors, length);
}

/*
 * Copying
 */
- (id) copyWithZone: (NSZone*)zone
{
  int w = [self width];
  int h = [self height];
  GDImage *copy = [[GDImage allocWithZone: zone] initWithWidth: w  height: h];
  
  gdImagePaletteCopy (copy->_imagePtr, _imagePtr);
  gdImageCopy (copy->_imagePtr, _imagePtr, 0, 0, 0, 0, w, h);

  [copy setPaletteTransparentColor: [self paletteTransparentColor]];

  return copy;
}

- (void) copyFromImage: (GDImage *)image
		  rect: (NSRect)sourceRectangle
		    to: (NSPoint)destOrigin
{
  unsigned int sourceX = (unsigned int)(sourceRectangle.origin.x);
  unsigned int sourceY = (unsigned int)(sourceRectangle.origin.y);
  unsigned int width = (unsigned int)(sourceRectangle.size.width);
  unsigned int height = (unsigned int)(sourceRectangle.size.height);
  unsigned int destX = (unsigned int)(destOrigin.x);
  unsigned int destY = (unsigned int)(destOrigin.y);

  gdImageCopy (_imagePtr, image->_imagePtr, destX, destY,
	       sourceX, sourceY, width, height);  
}


- (void) copyFromImage: (GDImage *)image
		  rect: (NSRect)sourceRectangle
	  toScaledRect: (NSRect)destRectangle;
{
  unsigned int sourceX = (unsigned int)(sourceRectangle.origin.x);
  unsigned int sourceY = (unsigned int)(sourceRectangle.origin.y);
  unsigned int sourceWidth = (unsigned int)(sourceRectangle.size.width);
  unsigned int sourceHeight = (unsigned int)(sourceRectangle.size.height);
  unsigned int destX = (unsigned int)(destRectangle.origin.x);
  unsigned int destY = (unsigned int)(destRectangle.origin.y);
  unsigned int destWidth = (unsigned int)(destRectangle.size.width);
  unsigned int destHeight = (unsigned int)(destRectangle.size.height);

  gdImageCopyResized (_imagePtr, image->_imagePtr,
		      destX, destY, sourceX, sourceY,
		      destWidth, destHeight, sourceWidth, sourceHeight);
}

/*
 * String drawing
 */
- (void) drawCharacter: (char)c
		  from: (NSPoint)point
		 color: (int)color
		  font: (GDFont *)font
{
  unsigned int x = (unsigned int)(point.x);
  unsigned int y = (unsigned int)(point.y);

  gdImageChar (_imagePtr, [font fontPointer], x, y, c, color);
}

- (void) drawCharacterUp: (char)c
		    from: (NSPoint)point
		   color: (int)color
		    font: (GDFont *)font
{
  unsigned int x = (unsigned int)(point.x);
  unsigned int y = (unsigned int)(point.y);

  gdImageCharUp (_imagePtr, [font fontPointer], x, y, c, color);
}

- (void) drawString: (NSString *)string
	       from: (NSPoint)point
	      color: (int)color
	       font: (GDFont *)font
{
  /* Convert the string to iso-8859-2 as that is the charset used by
   * the default fonts.  NB - for a custom font, this might not be
   * appropriate!! */
  NSMutableData *m = [[string dataUsingEncoding: NSISOLatin2StringEncoding
			      allowLossyConversion: YES] mutableCopy];
  unsigned char *c;
  unsigned int x = (unsigned int)(point.x);
  unsigned int y = (unsigned int)(point.y);

  [m appendBytes: "" length: 1];
  c = (unsigned char *)[m bytes];
  
  gdImageString (_imagePtr, [font fontPointer], x, y, c, color);
  RELEASE (m);
}

- (void) drawStringUp: (NSString *)string
		 from: (NSPoint)point
		color: (int)color
		 font: (GDFont *)font
{
  /* Convert the string to iso-8859-2 as that is the charset used by
   * the default fonts.  NB - for a custom font, this might not be
   * appropriate!! */
  NSMutableData *m = [[string dataUsingEncoding: NSISOLatin2StringEncoding
			      allowLossyConversion: YES] mutableCopy];
  unsigned char *c;
  unsigned int x = (unsigned int)(point.x);
  unsigned int y = (unsigned int)(point.y);

  [m appendBytes: "" length: 1];
  c = (unsigned char *)[m bytes];

  gdImageStringUp (_imagePtr, [font fontPointer], x, y, c, color);
  RELEASE (m);
}

- (void) drawStringFreeType: (NSString *)string
		       from: (NSPoint)point
		      color: (int)color
		   fontPath: (NSString *)fontPath
		  pointSize: (int)ptSize
		      angle: (double)radians
	disableAntiAliasing: (BOOL)disableAA
	       boundingRect: (int *)rect
{
  /* Convert the string to UTF-8 as it looks like the FT function is
   * expecting that.  */
  NSMutableData *m = [[string dataUsingEncoding: NSUTF8StringEncoding
			      allowLossyConversion: YES] mutableCopy];
  unsigned char *c;
  char *error = NULL;
  unsigned int x = (unsigned int)(point.x);
  unsigned int y = (unsigned int)(point.y);
  
  [m appendBytes: "" length: 1];
  c = (unsigned char *)[m bytes];

  error = gdImageStringFT (_imagePtr, rect,
			   (disableAA ? (-color) : (color)),
			   (unsigned char*)[fontPath fileSystemRepresentation],
			   ptSize, radians, x, y, c);

  RELEASE (m);
  
  if (error != NULL)
    {
      [NSException raise: NSGenericException  
		   format: @"Error while rendering FreeType font: %s",
		   error];
    }
}

+ (void) getBoundingRect: (int *)rect
          stringFreeType: (NSString *)string
	        fontPath: (NSString *)fontPath
  	       pointSize: (int)ptSize
	           angle: (double)radians
{
  /* Convert the string to UTF-8 as it looks like the FT function is
   * expecting that.  */
  NSMutableData *m = [[string dataUsingEncoding: NSUTF8StringEncoding
			      allowLossyConversion: YES] mutableCopy];
  unsigned char *c;
  char *error = NULL;
  
  [m appendBytes: "" length: 1];
  c = (unsigned char *)[m bytes];
  
  error = gdImageStringFT (NULL, rect, 0,	   
			   (unsigned char*)[fontPath fileSystemRepresentation],
			   ptSize, radians, 0, 0, c);
  
  RELEASE (m);

  if (error != NULL)
    {
      [NSException raise: NSGenericException  
		   format: @"Error computing bounding rect of FreeType font: %s",
		   error];
    }  
}


@end


@implementation GDImage (StringUtils)
- (void) drawCenteredString: (NSString *)string
		       from: (NSPoint)point
			 to: (NSPoint)point2
		      color: (int)color
		       font: (GDFont *)font
{
  NSSize box = [font boundingBoxForString: string];
  int width = point2.x - point.x;

  [self drawString: string
	from: NSMakePoint (point.x + ((width - box.width) / 2),
			   point.y)
	color: color
	font: font];
}

- (void) drawRightAlignedString: (NSString *)string
			     to: (NSPoint)point
			  color: (int)color
			   font: (GDFont *)font
{
  NSSize box = [font boundingBoxForString: string];

  [self drawString: string
	from: NSMakePoint (point.x - box.width, point.y)
	color: color
	font: font];
  
}
@end
