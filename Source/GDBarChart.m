/* GDChartChart.m - A pie chart type  -*-objc-*-
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

#include <gsgd/GDBarChart.h>
#include <gsgd/GDImage.h>
#include <gsgd/GDFont.h>
#include <gsgd/GDBinDataSet.h>
#include <gsgd/GDFrame.h>
#include <gsgd/GDLegendBox.h>
#include <gsgd/GDLineStyle.h>

@implementation GDBarChart

- (id) init
{
  _dataSet = nil;
  _barColor = -10;
  _barShadeColor = -10;

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

- (void) setBarColor: (int)color
{
  _barColor = color;
}

- (void) setBarShadeColor: (int)color
{
  _barShadeColor = color;
}

- (void) plotChartInFrame: (GDFrame *)frame
{
  GDImage *image = [frame image];
  int black = [image allocatePaletteColorWithName: @"black"];

  /*
   * We are going to draw something like the following:
   *
   * 84-|----------------------------
   *    |
   * 63-|----------------------------
   *    |    XX
   * 42-|----XX----------------------
   *    |    XX      ZZ
   * 21-|----XX------ZZ--------------
   *    |    XX      ZZ        YY 
   *  0==============================
   *      database  sms  web  unknown
   *
   * The first thing we need to do is determine the general layout.
   * We start by computing the size and layout of the y labels.
   * Then, we compute the size and layout of the x labels.
   * Then we draw the animal.
   */
  NSArray *values = [_dataSet values];
  NSArray *keys = [_dataSet keys];
  int i, count;
  double total = 0;
  GDFont *yFont, *xFont;
  NSMutableArray *yLabels;
  NSSize ySize;
  NSSize xLabelSize;

  if (_barColor == -10)
    {
      _barColor = [image allocatePaletteColorWithRed: 102  green: 102  
			 blue: 153];
    }

  if (_barShadeColor == -10)
    {
      _barShadeColor = [image allocatePaletteColorWithRed: 153  green: 153  
			      blue: 153];
    }

  yFont = [GDFont mediumBoldFont];
  xFont = [GDFont mediumBoldFont];

  /* Compute the total of all values.  This is the max of the y scale.  */
  count = [values count];  
  for (i = 0; i < count; i++)
    {
      total += [(NSNumber *)[values objectAtIndex: i] doubleValue];
    }

  if (total >= 4)
    {
      /* Now prepare the 5 y labels we use.  */      
      yLabels = [NSMutableArray array];
      [yLabels addObject: @"0"];
      [yLabels addObject: [NSString stringWithFormat: @"%d", 
				    (int)(total / 4)]];
      [yLabels addObject: [NSString stringWithFormat: @"%d", 
				    (int)(total / 2)]];
      [yLabels addObject: [NSString stringWithFormat: @"%d", 
				    (int)((total * 3) / 4)]];
      [yLabels addObject: [NSString stringWithFormat: @"%d", 
				    (int)(total)]];
    }
  else
    {
      /* Oh oh - we are in trouble here.  We draw only the top line in 
       * this case.  */
      yLabels = [NSMutableArray array];
      [yLabels addObject: @"0"];
      if (total > 0)
	{
	  [yLabels addObject: [NSString stringWithFormat: @"%d", (int)(total)]];
	}
      else
	{
	  /* Do not display the top one.  */
	  [yLabels addObject: @""];
	}
    }

  /* Get the maximum width of the y labels.  */
  ySize.width = [yFont boundingBoxForStrings: yLabels].width;

  /* Add 3 pixels on the right side.  */
  ySize.width += 3;

  /* Now compute the size of the xLabels.  */
  xLabelSize = [xFont boundingBoxForStrings: keys];

  /* Add 5 pixels on each vertical side; 10 to each horizontal side.  */
  xLabelSize.width += 20;
  xLabelSize.height += 10;

  /* Now draw the grid and labels.  */

  /* Prepare a few basic reference points on the frame.  */
  {
    /* The position of the 'zero' x coordinate inside the graph.  */
    int minX = ySize.width + 2;
    
    /* The position of the 'max' x coordinate inside the graph.  */
    int maxX = ySize.width + 2 + (xLabelSize.width * [keys count]);
    
    /* The position of the 'zero' y coordinate inside the graph.  */
    int minY = xLabelSize.height;
    
    /* The position of the 'max' y coordinate inside the graph.  */
    int maxY = [frame height] - 5;

    /* The x axis.  */
    [image drawLine: [frame convertFrameToImage: NSMakePoint (minX - 2, minY)]
	   to: [frame convertFrameToImage: NSMakePoint (maxX, minY)]
	   color: black];
  
    /* The y axis.  */
    [image drawLine: [frame convertFrameToImage: NSMakePoint (minX, minY - 2)]
	   to: [frame convertFrameToImage: NSMakePoint (minX, maxY)]
	   color: black];

    /* The yLabels and horizontal grid lines.  */
    [image setLineStyle: [GDLineStyle dottedLineWithColor: black]];
    count = [yLabels count];
    for (i = 0; i < count; i++)
      {
	NSString *string = [yLabels objectAtIndex: i];
	int y = minY + i * ((maxY - minY) / ([yLabels count] - 1));
	NSPoint p1, p2;

	p1 = [frame convertFrameToImage: NSMakePoint (minX - 5, y + 5)];
	[image drawRightAlignedString: string  to: p1
	       color: black  font: yFont];

	p1 = [frame convertFrameToImage: NSMakePoint (minX - 2, y)];
	p2 = [frame convertFrameToImage: NSMakePoint (maxX, y)];
	[image drawLine: p1  to: p2  color: [GDImage styledColor]];

      }

    /* The xLabels and the actual bars.  */
    {
      /* Scale the values to the size of the graph in pixels.  */
      NSArray *pixelValues = [_dataSet fractionsScaledTo: (maxY - minY)];
      count = [keys count];
      for (i = 0; i < count; i++)
	{
	  NSString *key = [keys objectAtIndex: i];
	  int pixels = (int)([[pixelValues objectAtIndex: i] doubleValue]);
	  int x = minX + i * xLabelSize.width;
	  NSPoint p1, p2;
	  NSRect r;

	  p1 = NSMakePoint (x, minY - 5);
	  p1 = [frame convertFrameToImage: p1];

	  p2 = NSMakePoint (x + xLabelSize.width, minY - 5);
	  p2 = [frame convertFrameToImage: p2];
	  
	  [image drawCenteredString: key  from: p1  to: p2 
		 color: black  font: xFont];

	  /* Draw the shade bar, shifted 1 pixel in x and y.  */
	  r = NSMakeRect (x + (xLabelSize.width / 4) + 1, minY + 1,
			  (xLabelSize.width) /2, pixels);
	  r = [frame convertFrameRectToImage: r];
	  [image drawFilledRectangle:r  color: _barShadeColor];

	  /* Then the actual bar.  */
	  r = NSMakeRect (x + (xLabelSize.width / 4), minY,
			  (xLabelSize.width) /2, pixels);
	  r = [frame convertFrameRectToImage: r];
	  [image drawFilledRectangle:r  color: _barColor];
	}
    }
  }
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

  [image drawString: _title
	 from: origin
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

  /* Draw the chart.  */
  [self plotChartInFrame: frame];
}

/* Compute the recommended size to draw this chart.  */
- (NSSize) recommendedSize
{
  NSSize result = NSMakeSize (0, 0);

  /* We compute width.  Then we choose a height which is reasonably 
   * comparable.  */

  /* Borders.  */
  result.width  += 20;

  /* Title ... only affects height - ignore.  */

  /* The actual graph ... approximate width  */
  {
    NSArray *keys = [_dataSet keys];
    GDFont *yFont, *xFont;
    NSSize xLabelSize;

    yFont = [GDFont mediumBoldFont];
    xFont = [GDFont mediumBoldFont];

    /* Compute the total of all values.  This is the max of the y scale.  */
    {
      NSArray *values = [_dataSet values];
      int i, count;
      double total = 0;
      NSString *yLabel;

      count = [values count];  
      for (i = 0; i < count; i++)
	{
	  total += [(NSNumber *)[values objectAtIndex: i] doubleValue];
	}
      
      /* Approximately, get the longest label.  */
      yLabel = [NSString stringWithFormat: @"%d", (int)(total)];

      result.width += [yFont boundingBoxForString: yLabel].width;
    }
    
    /* Add 3 pixels on the right side.  */
    result.width += 3;
    
    /* Now compute the size of the xLabels.  */
    xLabelSize = [xFont boundingBoxForStrings: keys];
    
    /* Add 10 to each horizontal side.  */
    xLabelSize.width += 20;
    
    result.width += xLabelSize.width * [keys count];

    /* Now, adjust the height to give a pleasant ratio.  */
    result.height = result.width / 1.5;

    /* Make sure the height is at least 150.  If the width is very small,
     * it might be that the height (we never computed the minimum height)
     * computed from the width might be too small.  This is sort of a hack
     * I suppose the real way out is computing the minimum height as well.  */
    if (result.height < 150)
      {
	result.height = 150;
      }

    /* Make sure if the width is unreasonably large, we don't use an unreasonably
     * large height too.  */
    if (result.height > 600)
      {
	result.height = 600;
      }


    return result;
  }
}

@end

