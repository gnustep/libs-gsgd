/* GDPieChart.m - A pie chart type  -*-objc-*-
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

#include <Foundation/NSArray.h>
#include <Foundation/NSValue.h>

#include <gsgd/GDPieChart.h>
#include <gsgd/GDImage.h>
#include <gsgd/GDFont.h>
#include <gsgd/GDBinDataSet.h>
#include <gsgd/GDFrame.h>
#include <gsgd/GDLegendBox.h>
#include <gsgd/GDLineStyle.h>

@implementation GDPieChart

- (id) init
{
  _dataSet = nil;
  return self;
}

- (void) dealloc
{
  RELEASE (_dataSet);
  RELEASE (_title);
  [super dealloc];
}

- (void) setDataSet: (GDBinDataSet *)dataSet
{
  ASSIGN (_dataSet, dataSet);
}

- (void) setTitle: (NSString *)title
{
  ASSIGN (_title, title);
}


- (NSArray *)sliceColors
{
  NSMutableArray *c;
  
  c = [NSMutableArray array];
  [c addObject: @"yellow"];
  [c addObject: @"fuchsia"];
  [c addObject: @"aqua"];
  [c addObject: @"red"];
  [c addObject: @"green"];
  [c addObject: @"blue"];
  [c addObject: @"gray"];
  [c addObject: @"maroon"];
  [c addObject: @"lime"];
  [c addObject: @"navy"];
  [c addObject: @"olive"];
  [c addObject: @"purple"];
  [c addObject: @"silver"];
  [c addObject: @"teal"];
  return c;
}


- (void) plotPieInFrame: (GDFrame *)frame
{
  GDImage *image = [frame image];
  int diameter;
  int black;
  NSPoint center;

  /* The center of the circle.  */
  {
    int width = [frame width];
    int height = [frame height];
    
    center = NSMakePoint (width / 2, height / 2);
    center = [frame convertFrameToImage: center];
    
    /* Draw a circle, not an ellipse.  */
    if (width > height)
      {
	diameter = height;
      }
    else
      {
	diameter = width;
      }
  }

  black = [image allocatePaletteColorWithName: @"black"];
  
  [image arcCenterX: center.x
		  y: center.y
	      width: diameter
	     height: diameter
	 startAngle: 0
	  stopAngle: 360
	      color: black
	    options: GDDrawArcImageArcOption];

  {
    NSArray *fractions;
    double angleA, angleB;
    NSArray *sliceColors = [self sliceColors];
    int i, colorIndex = -1, numColors = [sliceColors count];

    /* We get the fractions in degrees.  */
    fractions = [_dataSet fractionsScaledTo: 360];

    angleA = 0;
    
    for (i = 0; i < [fractions count]; i++)
      {
	int color;
	
	colorIndex++;
	if (colorIndex > numColors)
	  {
	    colorIndex = 0;
	  }
	
	color = [image allocatePaletteColorWithName: 
			 [sliceColors objectAtIndex: colorIndex]];

	/* Make sure the plot 'closes'.  */
	if (i == [fractions count] - 1)
	  {
	    angleB = 360;
	  }
	else
	  {
	    angleB = angleA + [(NSNumber *)[fractions objectAtIndex: i] 
					   doubleValue];
	  }
	
	[image arcCenterX: center.x
	       y: center.y
	       width: diameter
	       height: diameter
	       startAngle: angleA
	       stopAngle: angleB
	       color: color
	       options: GDFillArcAreaImageArcOption];
	
	angleA = angleB;
      }
  }
}

/* Draw the legend on the right of the plot.  */
- (GDFrame *) plotLegendInFrame: (GDFrame *)frame
{
  NSArray *names = [_dataSet keys];  
  GDLegendBox *legend = [GDLegendBox new];
  int count = [names count];
  NSArray *sliceColors = [self sliceColors];
  int i, colorIndex = -1, numColors = [sliceColors count];
  NSSize legendSize;
  GDImage *image = [frame image];
  int width = [frame width];
  int height = [frame height];

  for (i = 0; i < count; i++)
    {
      int color;
      
      colorIndex++;
      if (colorIndex > numColors)
	{
	  colorIndex = 0;
	}
      
      color = [image allocatePaletteColorWithName: 
		       [sliceColors objectAtIndex: colorIndex]];
      
      [legend setExplanation: [names objectAtIndex: i]
	      forStyle: [GDLineStyle lineWithColor: color]];
    }

  legendSize = [legend comfortableSize];
  
  [legend plotInFrame: [frame subFrameWithRect: 
				NSMakeRect (width - legendSize.width,
					    height - legendSize.height, 
					    legendSize.width,
					    legendSize.height)]];
  [legend release];
  /* Add a 5 pixel border between the legend and what on its left.  */
  return [frame subFrameWithRect: NSMakeRect (0, 0,
					      width - legendSize.width - 5,
					      height)];
}


/* Draw title centered in the top of frame, return the frame which
 * can be used to draw the remaining part of the image.  */
- (GDFrame *) plotTitleInFrame: (GDFrame *)frame
{
  GDImage *image = [frame image];
  GDFont *titleFont;
  NSSize box;
  NSPoint origin;

  titleFont = [GDFont mediumBoldFont];
  box = [titleFont boundingBoxForString: _title];

  /* A string is drawn by giving the coordinate of the top left
   * corner.  */
  origin.x = ([frame width] - box.width) / 2;
  origin.y = [frame height];
  origin = [frame convertFrameToImage: origin];

  [image string: _title
	 x: origin.x
	 y: origin.y
	 color: [image allocatePaletteColorWithName: @"black"]
	 font: titleFont];
  
  return [frame subFrameWithRect: NSMakeRect (0, 0, [frame width], 
					      [frame height] - box.height
					      - 10)];
}

/* `Draw' empty borders of frame, return the frame which can be used
 * to draw the remaining part of the image.  */
- (GDFrame *) plotBordersInFrame: (GDFrame *)frame
{
  int xBorder = 10;
  int yBorder = 10;

  return [frame subFrameWithRect: NSMakeRect (xBorder, yBorder, 
					      [frame width] - 2 * xBorder,
					      [frame height] - 2 * yBorder)];
}		

- (void) plotInFrame: (GDFrame *)frame
{
  /* Add borders.  */
  frame = [self plotBordersInFrame: frame];

  /* Draw the title.  */
  if (_title != nil)
    {
      frame = [self plotTitleInFrame: frame];
    }

  /* Draw the legend.  */
  frame = [self plotLegendInFrame: frame];

  /* Draw the pie.  */
  [self plotPieInFrame: frame];
}

@end

