/* GDImage.m - Implementation of GDImage
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:  Manuel Guesdon <mguesdon@orange-concept.com>
   Created: August 1999
   Modified: Nicola Pero <n.pero@mi.flashnet.it>
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
#include <Foundation/NSException.h>

#include <gsgd/GDSimpleFont.h>

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
};


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
};

/*
 * Deallocating the object.
 */
- (void) dealloc
{
  gdImageDestroy (_imagePtr);
  [super dealloc];
};

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
		  extraInfo: (int)info
{
  NSData *output = nil;
  void *bytes = NULL;
  int size;

  switch (f)
    {
    case GDPNGImageDataFormat:
      {
	bytes = gdImagePngPtr (_imagePtr, &size);
	break;
      }
    case GDJPEGImageDataFormat:
      {
	/* Info is quality in this case, a value between 0-95.
	   Pass -1 to get the default quality.  */
	bytes = gdImageJpegPtr (_imagePtr, &size, info);
	break;
      }
    case GDGDImageDataFormat:
      {
	bytes = gdImageGdPtr (_imagePtr, &size);
	break;
      }
    case GDWBMPImageDataFormat:
      {
	/* Info is the color to use as foreground in this case.
	   Pass -1 to get 'black' (or if black is not found, the best
	   match for black) used.  */
	if (info < 0)
	  {
	    info = gdImageColorClosest (_imagePtr, 0, 0, 0);
	    
	    /* No colors defined in the image! */
	    if (info < 0)
	      {
		return nil;
	      }
	  }
	
	bytes = gdImageWBMPPtr (_imagePtr, &size, info);
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
  return [self dataWithFormat: f  extraInfo: -1];
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
  return [self dataWithFormat: GDJPEGImageDataFormat  extraInfo: q];
}

- (NSData *) wbmpData
{
  return [self dataWithFormat: GDWBMPImageDataFormat];
}

- (NSData *) wbmpDataWithForegroundColor: (int)c
{
  return [self dataWithFormat: GDWBMPImageDataFormat  extraInfo: c];
}

- (NSData *) gdData
{
  return [self dataWithFormat: GDGDImageDataFormat];
}

/*
 * Setting writing properties.
 */
- (BOOL) interlace
{
  if (gdImageGetInterlaced (_imagePtr))
    {
      return YES;
    }
  else
    {
      return NO;
    }
}

- (void) setInterlace: (BOOL)interlace
{
  gdImageInterlace (_imagePtr, interlace ? 1 : 0);
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

+ (int) transparentColor
{
  return gdTransparent;
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
  /* Return not found.  */
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

- (void) setPixelColor: (int)color
		     x: (int)x
		     y: (int)y
{
  gdImageSetPixel (_imagePtr, x, y, color);
}

- (int) pixelColorAtX: (int)x
		    y: (int)y
{
  return gdImageGetPixel (_imagePtr, x, y);
}


//--------------------------------------------------------------------
// Drawing
-(void)lineFromX:(int)x1
			   y:(int)y1
			 toX:(int)x2
			   y:(int)y2
		   color:(int)color
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageLine(_imagePtr,x1,y1,x2,y2,color);
};

//--------------------------------------------------------------------
-(void)dashedLineFromX:(int)x1
					 y:(int)y1
				   toX:(int)x2
					 y:(int)y2
				 color:(int)color
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageDashedLine(_imagePtr,x1,y1,x2,y2,color);
};

//--------------------------------------------------------------------
-(void)polygon:(gdPointPtr)points
		 count:(int)numPoints
		 color:(int)color
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImagePolygon(_imagePtr,points,numPoints,color);
};

//--------------------------------------------------------------------
-(void)filledPolygon:(gdPointPtr)points
			   count:(int)numPoints
			   color:(int)color
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageFilledPolygon(_imagePtr,points,numPoints,color);
};

//--------------------------------------------------------------------
-(void)rectFromX:(int)x1
			   y:(int)y1
			 toX:(int)x2
			   y:(int)y2
		   color:(int)color
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageRectangle(_imagePtr,x1,y1,x2,y2,color);
};

//--------------------------------------------------------------------
-(void)filledRectFromX:(int)x1
					 y:(int)y1
				   toX:(int)x2
					 y:(int)y2
				 color:(int)color
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageFilledRectangle(_imagePtr,x1,y1,x2,y2,color);
};

//--------------------------------------------------------------------
-(void)fillToBorderX:(int)x
				   y:(int)y
			  border:(int)border
			   color:(int)color
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageFillToBorder(_imagePtr,x,y,border,color);
};

//--------------------------------------------------------------------
-(void)fillX:(int)x
		   y:(int)y
	   color:(int)color;
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageFill(_imagePtr,x,y,color);
};

//--------------------------------------------------------------------
-(void)setBrush:(GDImage*)brush
{
  gdImageSetBrush(_imagePtr,[brush imagePtr]);
};

//--------------------------------------------------------------------
-(void)setTile:(GDImage*)tile
{
  gdImageSetTile(_imagePtr, [tile imagePtr]);
};

//--------------------------------------------------------------------
-(void)setStyle:(int*)style
		 length:(int)length
{
  gdImageSetStyle(_imagePtr,style,length);
};

//--------------------------------------------------------------------
-(BOOL)boundsSafeX:(int)x
				 y:(int)y
{
  return (gdImageBoundsSafe(_imagePtr,x,y)!=0);
};

//--------------------------------------------------------------------
// Arcs handling
-(void)arcCenterX:(int)x
				y:(int)y
			width:(int)width
		   height:(int)height
			start:(int)start
			 stop:(int)stop
			color:(int)color
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageArc(_imagePtr,x,y,width,height,start,stop,color);
};

//--------------------------------------------------------------------
void XYFromDegWithHeight(int* x,int* y,int deg,int width,int height,int baseX,int baseY)
{
  double _pi=acos(-1);
  double _rad=deg*_pi/180;
  double _cos=cos(_rad);
  double _sin=sin(_rad);
  *x=(int)((_cos*(double)width)/2);
  *y=(int)((_sin*(double)height)/2);
  (*x)+=baseX;
  (*y)+=baseY;
};

//--------------------------------------------------------------------
-(void)arcLineCenterX:(int)x
					y:(int)y
				width:(int)width
			   height:(int)height
				start:(int)start
				 stop:(int)stop
				color:(int)color
{
  int startX=0;
  int startY=0;
  int stopX=0;
  int stopY=0;
  NSAssert1(color>=0,@"bad color index: %d",color);
  XYFromDegWithHeight(&startX,&startY,start,width,height,x,y);
  XYFromDegWithHeight(&stopX,&stopY,stop,width,height,x,y);
  gdImageArc(_imagePtr,x,y,width,height,start,stop,color);
  if (stop%360!=start%360)
	{
	  [self lineFromX:x
			y:y
			toX:startX
			y:startY
			color:color];
	  [self lineFromX:x
			y:y
			toX:stopX
			y:stopY
			color:color];
	};
};

//--------------------------------------------------------------------
-(void)arcFillCenterX:(int)x
					y:(int)y
				width:(int)width
			   height:(int)height
				start:(int)start
				 stop:(int)stop
				color:(int)color
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  [self arcFillCenterX:x
		y:y
		width:width
		height:height
		start:start
		stop:stop
		color:color
		borderColor:color];
};

//--------------------------------------------------------------------
-(void)arcFillCenterX:(int)x
					y:(int)y
				width:(int)width
			   height:(int)height
				start:(int)start
				 stop:(int)stop
				color:(int)color
		  borderColor:(int)borderColor_
{
  int midX=0;
  int midY=0;
  NSAssert1(color>=0,@"bad color index: %d",color);
  NSAssert1(color>=0,@"bad borderColor index: %d",borderColor_);
  XYFromDegWithHeight(&midX,&midY,(start+stop)/2,width/2,height/2,x,y);
  [self arcLineCenterX:x
		y:y
		width:width
		height:height
		start:start
		stop:stop
		color:borderColor_];
		
  [self fillToBorderX:midX
		y:midY
		border:borderColor_
		color:color];
};

//--------------------------------------------------------------------
// Copying and resizing
-(id)copy
{
  //TODO
  return nil;
};

//--------------------------------------------------------------------
-(void)copyRectFrom:(GDImage*)image
				  x:(int)sourceX
				  y:(int)sourceY
			  width:(int)width
			 height:(int)height
				toX:(int)destX
				  y:(int)destY
{
  gdImageCopy(_imagePtr,[image imagePtr],
			  destX,
			  destY,
			  sourceX,
			  sourceY,
			  width,
			  height);
};

//--------------------------------------------------------------------
-(void)copyRectFrom:(GDImage*)image
				  x:(int)sourceX
				  y:(int)sourceY
			  width:(int)width
			 height:(int)height
				toX:(int)destX
				  y:(int)destY
			  width:(int)destWidth
			 height:(int)destHeight
{
  gdImageCopyResized(_imagePtr,[image imagePtr],
					 destX,
					 destY,
					 sourceX,
					 sourceY,
					 destWidth,
					 destHeight,
					 width,
					 height);
};

//--------------------------------------------------------------------
// Fonts and text-handling
-(void)character:(char)char_
			   x:(int)x
			   y:(int)y
		   color:(int)color
		  inFont:(GDSimpleFont*)font
{
  NSDebugMLog(@"GDImage character: char_=%d",(int)char_);
  NSAssert(font,@"no Font");
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageChar(_imagePtr,[font fontPtr],x,y,char_,color);
  NSDebugMLog(@"Stop GDImage character %@",@"");
};

//--------------------------------------------------------------------
-(void)characterUp:(char)char_
				 x:(int)x
				 y:(int)y
			 color:(int)color
			inFont:(GDSimpleFont*)font
{
  NSDebugMLog(@"GDImage characterUp: char_=%d",(int)char_);
  NSAssert(font,@"no Font");
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageCharUp(_imagePtr,[font fontPtr],x,y,char_,color);
  NSDebugMLog(@"Stop GDImage characterUp %@",@"");
};

//--------------------------------------------------------------------
-(void)string:(NSString*)string_
			x:(int)x
			y:(int)y
		color:(int)color
	   inFont:(GDSimpleFont*)font
{
  NSDebugMLog(@"GDImage string: string_=%@",string_);
  NSAssert(font,@"no Font");
  NSAssert(string_,@"no String");
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageString(_imagePtr,[font fontPtr],x,y,[string_ cString],color);
  NSDebugMLog(@"Stop GDImage string %@",@"");
};

//--------------------------------------------------------------------
-(NSString*)stringTTF:(NSString*)string
					x:(int)x
					y:(int)y
				color:(int)color
			 fontPath:(NSString*)fontPath_
			pointSize:(int)ptSize_
				angle:(double)angle_
  disableAntiAliasing:(BOOL)disableAA_
		 boundingOnly:(BOOL)boundingOnly_
lowerLeftBoundingCorner:(NSPoint*)lowerLeft_
lowerRightBoundingCorner:(NSPoint*)lowerRight_
upperLeftBoundingCorner:(NSPoint*)upperLeft_
upperRightBoundingCorner:(NSPoint*)upperRight_
{
  NSString* errorString=nil;
  int corners[8];
  char* err=NULL;
  NSDebugMLog(@"GDImage stringTTF: string_=%@",string);
  NSAssert([fontPath_ length]>0,@"no Font");
  NSAssert(string,@"no String");
  NSAssert1(color>=0,@"bad color index: %d",color);
  err=gdImageStringTTF((boundingOnly_ ? NULL : _imagePtr),
					   corners,
					   (disableAA_ ? (-color) : (color)),
					   [fontPath_ cString],
					   ptSize_,
					   angle_,
					   x,
					   y,
					   [string cString]);
  if (lowerLeft_)
	{
	  lowerLeft_->x=corners[0];
	  lowerLeft_->y=corners[1];
	};
  if (lowerRight_)
	{
	  lowerRight_->x=corners[2];
	  lowerRight_->y=corners[3];
	};
  if (upperLeft_)
	{
	  upperLeft_->x=corners[4];
	  upperLeft_->y=corners[5];
	};
  if (upperRight_)
	{
	  upperRight_->x=corners[6];
	  upperRight_->y=corners[7];
	};
  if (err)
	errorString=[NSString stringWithCString:err];
  NSDebugMLog(@"Stop GDImage stringTTF %@",@"");
  return errorString;
};

//--------------------------------------------------------------------
-(NSString*)stringTTF:(NSString*)string
					x:(int)x
					y:(int)y
				color:(int)color
			 fontPath:(NSString*)fontPath_
			pointSize:(int)ptSize_
				angle:(double)angle_
  disableAntiAliasing:(BOOL)disableAA_
{
  return [self stringTTF:string
			   x:x
			   y:y
			   color:color
			   fontPath:fontPath_
			   pointSize:ptSize_
			   angle:angle_
			   disableAntiAliasing:disableAA_
			   boundingOnly:NO
			   lowerLeftBoundingCorner:NULL
			   lowerRightBoundingCorner:NULL
			   upperLeftBoundingCorner:NULL
			   upperRightBoundingCorner:NULL];
};

//--------------------------------------------------------------------
-(NSString*)stringTTF:(NSString*)string
					x:(int)x
					y:(int)y
				color:(int)color
			 fontPath:(NSString*)fontPath_
			pointSize:(int)ptSize_
				angle:(double)angle_
  disableAntiAliasing:(BOOL)disableAA_
lowerLeftBoundingCorner:(NSPoint*)lowerLeft_
lowerRightBoundingCorner:(NSPoint*)lowerRight_
upperLeftBoundingCorner:(NSPoint*)upperLeft_
upperRightBoundingCorner:(NSPoint*)upperRight_
{
  return [self stringTTF:string
			   x:x
			   y:y
			   color:color
			   fontPath:fontPath_
			   pointSize:ptSize_
			   angle:angle_
			   disableAntiAliasing:disableAA_
			   boundingOnly:NO
			   lowerLeftBoundingCorner:lowerLeft_
			   lowerRightBoundingCorner:lowerRight_
			   upperLeftBoundingCorner:upperLeft_
			   upperRightBoundingCorner:upperRight_];
};


//--------------------------------------------------------------------
-(NSString*)stringTTF:(NSString*)string
					x:(int)x
					y:(int)y
			 fontPath:(NSString*)fontPath_
			pointSize:(int)ptSize_
				angle:(double)angle_
  disableAntiAliasing:(BOOL)disableAA_
lowerLeftBoundingCorner:(NSPoint*)lowerLeft_
		 lowerRightBoundingCorner:(NSPoint*)lowerRight_
upperLeftBoundingCorner:(NSPoint*)upperLeft_
upperRightBoundingCorner:(NSPoint*)upperRight_
{
  return [self stringTTF:string
			   x:x
			   y:y
			   color:1
			   fontPath:fontPath_
			   pointSize:ptSize_
			   angle:angle_
			   disableAntiAliasing:disableAA_
			   boundingOnly:YES
			   lowerLeftBoundingCorner:lowerLeft_
			   lowerRightBoundingCorner:lowerRight_
			   upperLeftBoundingCorner:upperLeft_
			   upperRightBoundingCorner:upperRight_];
};

//--------------------------------------------------------------------
-(void)stringUp:(NSString*)string_
			  x:(int)x
			  y:(int)y
		  color:(int)color
		 inFont:(GDSimpleFont*)font
{
  NSDebugMLog(@"GDImage stringUp: string_=%@",string_);
  NSAssert(font,@"no Font");
  NSAssert(string_,@"no String");
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageStringUp(_imagePtr,[font fontPtr],x,y,[string_ cString],color);
  NSDebugMLog(@"Stop GDImage stringUp %@",@"");
};

@end
