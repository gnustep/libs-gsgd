/* GDPlot.m - Implementation of GDPlot
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

#include <Foundation/NSDictionary.h>
#include <gsgd/GDPlot.h>

@implementation GDPlot

/*
-(id)init
{
  if ((self=[super init]))
	{
	};
  return self;
};

-(void)addContentsOfFile:(NSString*)filename_
{
  NSDictionary* _dict=[NSDictionary dictionaryWithContentsOfFile:filename_];
  [self addContentsOfDictionary:_dict];
};

-(void)addContentsOfDictionary:(NSDictionary*)dictionary_
{
};

// Exception if gifImage is nil
-(void)generateGraph
{
  gifImage=[GDImage imageWithWidth:imageSize.width
					   Height:imageSize.height];
  
};
-(void)addLegendBoxColor:(int)color;
-(void)addLinexArray:(NSArray*)x
			  yArray:(NSArray*)y color:(int)lineColor;
-(void)addHistogramxArray:(NSArray*)x
				   yArray:(NSArray*)y1
					color:(int)pc
		 barWidthInPixels:(double)pixels;
-(void)addHistogramxArray:(NSArray*)x
			yArray:(NSArray*)y1
			color:(int)pc
			barWidth:(double)width;
-(void)addDotxArray:(NSArray*)x
			yArray:(NSArray*)y
			color:(int)pc;


-(void)addBorder;
-(void)addBackgroundColor:(int)color;
-(void)addBox;
-(void)addXGrid;
-(void)addYGrid;
-(void)addXMainAxis;
-(void)addXSecondaryAxis;
-(void)addXCenteredAxis;
-(void)addYMainAxis;
-(void)addYSecondaryAxis;
-(void)addYCenteredAxis;

-(void)addLegend:(NSString*)title
			font:(GDSimpleFont*)font
		   color:(int)textColor;

-(void)addText:(NSString*)title
		   atX:(double)x
			 y:(double)y
		  font:(GDSimpleFont*)font
		 color:(int)textColor;

-(void)addLeftTitle:(NSString*)title
			   font:(GDSimpleFont*)font
			  color:(int)textColor;

-(void)addRightTitle:(NSString*)title
				font:(GDSimpleFont*)font
			   color:(int)textColor;

-(void)addCenterTitle:(NSString*)title
				 font:(GDSimpleFont*)font
				color:(int)textColor;

-(void)addBottomCenterTitle:(NSString*)title
					   font:(GDSimpleFont*)font
					  color:(int)textColor;

-(void)addLineToX:(double)x
				y:(double)y
			color:(int)aColor;

-(void)addWideLineToX:(double)x
					y:(double)y
				color:(int)aColor
				width:(double)aWidth;

-(void)addLineFromX:(double)x1
				  y:(double)y1
				toX:(double)x2
				  y:(double)y2
			  color:(int)aColor;

-(void)addWideLineFromX:(double)x1
					  y:(double)y1
					toX:(double)x2
					  y:(double)y2
				  color:(int)aColor
				  width:(double)width;

-(void)addTicsAndNumbersForXAxisAtX:(double)x
								  y:(double)y;

-(void)addTicsAndNumbersForYAxisAtX:(double)x
								  y:(double)y;



-(void)draw;
-(GDImage*)gifImage;
-(NSData*)imageData;
-(int)imageWidth;
-(int)imageHeight;
-(void)flush;
-(void)writeToFile:(NSString*)aFileName;

-(NSDictionary*)settings;
*/
@end
