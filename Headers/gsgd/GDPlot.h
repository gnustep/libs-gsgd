/* GDPlot.h - Interface of GDPlot
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

#ifndef _GDPlot_h__
	#define _GDPlot_h__

#include <gsgd/GDCom.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSDictionary.h>

#define GIF_PLOT__GRAPH_TAG	0
#define GIF_PLOT__LABEL_TAG	1
#define GIF_PLOT__AXES_TAG	2

typedef enum {
    GDPlotFormat_DATA_DOUBLE,
    GDPlotFormat_DATA_DATE,
    GDPlotFormat_DATA_OBJECT
} GDPlotFormat;
		
@class GDSimpleFont;
@class GDImage;

@interface GDPlot: NSObject
{
  GDImage* gifImage;
  NSSize imageSize;





  NSMutableArray *displayArray;
  NSMutableDictionary *legendsTable;
  NSMutableDictionary *settings;
  NSMutableDictionary *dateData;
  NSString *xNumberFormat;
  NSString* *yNumberFormat;
  NSString *dataDateFormat;
  int count;
  BOOL first;
  NSPoint lastPoint;
  NSPoint legendPoint;
  NSPoint firstLegendPoint;
  NSPoint lastLegendPoint;
  double yMin;
  double yMax;
  double xMin;
  double xMax;
  double xMaxGraph;
  double yMaxGraph;
  double xMinGraph;
  double yMinGraph;
  double xNum;
  double yNum;
  double xTics;
  double yTics;
  int bgColor;
  int borderColor;// Color of the border if it exists.
  int axisColor;// Default color of all axis.
  int ticColor;								// Color of the tics on all axis.
  int numberColor;// Color of all numbers on all axis.
  int gridColor;// Color of the grid behind the graph.
  int plotColor;
  int titleColor;
  NSRect rect;
  NSRect frame;
  NSRect drawFrame;
  GDPlotFormat xFormat;
  GDPlotFormat yFormat;
  NSSize xNumSize;
  NSSize yNumSize;
  NSSize titleSize;
  NSSize xTitleSize;
  NSSize yTitleSize;
  NSSize legendSize;
  NSArray* xObjects;
  NSArray *yObjects; // If the DATA_OBJECT Format is selected.
  int histogramCount;
}


-(id)init;
-(void)addContentsOfFile:(NSString*)filename_;
-(void)addContentsOfDictionary:(NSDictionary*)dictionary_;

// Exception if gifImage is nil
-(void)generateGraph;
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
@end

#endif // _GDPlot_h__
