/* GDGIFImage.m - Implementation of GDGIFImage
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:  Manuel Guesdon <mguesdon@orange-concept.com>
   Created: August 1999
   
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
#include <string.h>
#include <Foundation/NSData.h>
#include <Foundation/NSDebug.h>
#include <Foundation/NSException.h>
#include <gsgd/GDSimpleFont.h>
#include <gsgd/GDGIFImage.h>
#include <math.h>

static int dataReadWrapper(void* context,char* buf,int len)
{
  NSMutableData* inData=(NSMutableData*)context;
  int inDataLength=[inData length];
  void* inDataBytes=[inData mutableBytes];
  len=min(len,inDataLength);
  [inData getBytes:(void*)buf
		  length:len];
  memmove(inDataBytes,inDataBytes+len,inDataLength-len);
  [inData setLength:inDataLength-len];
  return len;
};

@implementation GDGIFImage

-(gdImagePtr)imagePtr
{
  return imagePtr;
};

-(id)initWithWidth:(int)width
			 height:(int)height
{
  if ((self=[super init]))
	{
	  imagePtr=gdImageCreate(width,height);
	};
  return self;
};

-(id)initWithFilename:(NSString*)filename
{
  NSData* data=[NSData dataWithContentsOfFile:filename];
  if ((self=[self initWithData:data]))
	{
	};
  return self;
};

-(id)initWithData:(NSData*)data
{
  if ((self=[super init]))
	{
	  gdSource s;
	  s.source = dataReadWrapper;
	  s.context = [data mutableCopy];
//TODO	  imagePtr=gdImageCreateFromGifSource(&s);
	};
  return self;
};

+(id)imageWithWidth:(int)width
			 height:(int)height
{
  return [[[self alloc]initWithWidth:width
					  height:height] autorelease];
};

+(id)imageWithFilename:(NSString*)filename
{
  NSData* _data=[NSData dataWithContentsOfFile:filename];
  return [[[self alloc]initWithData:_data] autorelease];
};

+(id)imageWithData:(NSData*)data
{
  return [[[self alloc]initWithData:data] autorelease];
};

-(void)dealloc
{
  [self destroyImage];
  [super dealloc];
};

-(void)destroyImage
{
  gdImageDestroy(imagePtr);
};

-(BOOL)interlace
{
  return (gdImageGetInterlaced(imagePtr)!=0);
};

-(void)setInterlace:(BOOL)interlace
{
  gdImageInterlace(imagePtr,interlace ? 1 : 0);
};

-(NSData*)imageData
{
  int size=0;
  void* dataPtr=gdImageGifPtr(imagePtr,&size);
  return [NSData dataWithBytesNoCopy:dataPtr
				 length:size];
};

-(BOOL)writeToFile:(NSString*)filename
{
  NSData* _imageData=[self imageData];
  return ([_imageData writeToFile:filename
					  atomically:NO]);
};

-(void)setPixelX:(int)x
				y:(int)y
			color:(int)color
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageSetPixel(imagePtr,x,y,color);
};

-(int)pixelX:(int)x
		   y:(int)y
{
  return gdImageGetPixel(imagePtr,x,y);
};

-(int)width
{
  return gdImageSX(imagePtr);
};
-(int)height
{
  return gdImageSY(imagePtr); 
};

// Drawing
-(void)lineFromX:(int)x1
			   y:(int)y1
			 toX:(int)x2
			   y:(int)y2
		   color:(int)color
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageLine(imagePtr,x1,y1,x2,y2,color);
};

-(void)dashedLineFromX:(int)x1
					 y:(int)y1
				   toX:(int)x2
					 y:(int)y2
				 color:(int)color
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageDashedLine(imagePtr,x1,y1,x2,y2,color);
};
-(void)polygon:(gdPointPtr)points
		 count:(int)numPoints
		 color:(int)color
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImagePolygon(imagePtr,points,numPoints,color);
};

-(void)filledPolygon:(gdPointPtr)points
			   count:(int)numPoints
			   color:(int)color
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageFilledPolygon(imagePtr,points,numPoints,color);
};

-(void)rectFromX:(int)x1
			   y:(int)y1
			 toX:(int)x2
			   y:(int)y2
		   color:(int)color
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageRectangle(imagePtr,x1,y1,x2,y2,color);
};

-(void)filledRectFromX:(int)x1
					 y:(int)y1
				   toX:(int)x2
					 y:(int)y2
				 color:(int)color
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageFilledRectangle(imagePtr,x1,y1,x2,y2,color);
};

-(void)fillToBorderX:(int)x
				   y:(int)y
			  border:(int)border
			   color:(int)color
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageFillToBorder(imagePtr,x,y,border,color);
};
-(void)fillX:(int)x
		   y:(int)y
	   color:(int)color;
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageFill(imagePtr,x,y,color);
};
-(void)setBrush:(GDGIFImage*)brush
{
  gdImageSetBrush(imagePtr,[brush imagePtr]);
};

-(void)setTile:(GDGIFImage*)tile
{
  gdImageSetTile(imagePtr, [tile imagePtr]);
};

-(void)setStyle:(int*)style
		 length:(int)length
{
  gdImageSetStyle(imagePtr,style,length);
};

-(BOOL)boundsSafeX:(int)x
				 y:(int)y
{
  return (gdImageBoundsSafe(imagePtr,x,y)!=0);
};

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
  gdImageArc(imagePtr,x,y,width,height,start,stop,color);
};

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
  gdImageArc(imagePtr,x,y,width,height,start,stop,color);
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

// Colors
-(int)blueOf:(int)color
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  return gdImageBlue(imagePtr,color);
};

-(int)greenOf:(int)color
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  return gdImageGreen(imagePtr,color);
};

-(int)redOf:(int)color
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  return gdImageRed(imagePtr,color);
};

+(int)brushed
{
  return gdBrushed;
};
+(int)maxColors
{
  return gdMaxColors;
};

+(int)styled
{
  return gdStyled;
};

+(int)styledBrushed
{
  return gdStyledBrushed;
};

+(int)dashSize
{
  return gdDashSize;
};
+(int)tiled
{
  return gdTiled;
};

+(int)transparent
{
  return gdTransparent;
};
-(int)newColorWithRed:(int)red
				green:(int)green
				 blue:(int)blue
{
  return gdImageColorAllocate(imagePtr,red,green,blue);
};

-(int)closestColorToRed:(int)red
				  green:(int)green
				   blue:(int)blue
{
  return gdImageColorClosest(imagePtr,red,green,blue);
};
-(int)exactColorWithRed:(int)red
				  green:(int)green
				   blue:(int)blue
{
  return gdImageColorExact(imagePtr,red,green,blue);
};

-(int)totalColors
{
  return gdImageColorsTotal(imagePtr);
};

-(int)transparent
{
  return gdImageGetTransparent(imagePtr);
};

-(void)setTransparent:(int)color
{
  gdImageColorTransparent(imagePtr,color);
};

-(void)setBackgroundColor:(int)color
{
  NSAssert1(color>=0,@"bad color index: %d",color);
  //TODO
};


// Copying and resizing
-(id)copy
{
  //TODO
  return nil;
};

-(void)copyRectFrom:(GDGIFImage*)image
				  x:(int)sourceX
				  y:(int)sourceY
			  width:(int)width
			 height:(int)height
				toX:(int)destX
				  y:(int)destY
{
  gdImageCopy(imagePtr,[image imagePtr],
			  destX,
			  destY,
			  sourceX,
			  sourceY,
			  width,
			  height);
};
-(void)copyRectFrom:(GDGIFImage*)image
				  x:(int)sourceX
				  y:(int)sourceY
			  width:(int)width
			 height:(int)height
				toX:(int)destX
				  y:(int)destY
			  width:(int)destWidth
			 height:(int)destHeight
{
  gdImageCopyResized(imagePtr,[image imagePtr],
					 destX,
					 destY,
					 sourceX,
					 sourceY,
					 destWidth,
					 destHeight,
					 width,
					 height);
};

// Fonts and text-handling
-(void)character:(char)char_
			   x:(int)x
			   y:(int)y
		   color:(int)color
		  inFont:(GDSimpleFont*)font
{
  NSDebugMLog(@"GDGIFImage character: char_=%d",(int)char_);
  NSAssert(font,@"no Font");
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageChar(imagePtr,[font fontPtr],x,y,char_,color);
  NSDebugMLog(@"Stop GDGIFImage character %@",@"");
};

-(void)characterUp:(char)char_
				 x:(int)x
				 y:(int)y
			 color:(int)color
			inFont:(GDSimpleFont*)font
{
  NSDebugMLog(@"GDGIFImage characterUp: char_=%d",(int)char_);
  NSAssert(font,@"no Font");
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageCharUp(imagePtr,[font fontPtr],x,y,char_,color);
  NSDebugMLog(@"Stop GDGIFImage characterUp %@",@"");
};

-(void)string:(NSString*)string_
			x:(int)x
			y:(int)y
		color:(int)color
	   inFont:(GDSimpleFont*)font
{
  NSDebugMLog(@"GDGIFImage string: string_=%@",string_);
  NSAssert(font,@"no Font");
  NSAssert(string_,@"no String");
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageString(imagePtr,[font fontPtr],x,y,[string_ cString],color);
  NSDebugMLog(@"Stop GDGIFImage string %@",@"");
};

-(void)stringUp:(NSString*)string_
			  x:(int)x
			  y:(int)y
		  color:(int)color
		 inFont:(GDSimpleFont*)font
{
  NSDebugMLog(@"GDGIFImage stringUp: string_=%@",string_);
  NSAssert(font,@"no Font");
  NSAssert(string_,@"no String");
  NSAssert1(color>=0,@"bad color index: %d",color);
  gdImageStringUp(imagePtr,[font fontPtr],x,y,[string_ cString],color);
  NSDebugMLog(@"Stop GDGIFImage stringUp %@",@"");
};

@end

