/* GDLegendBox.m - Draws a legend box  -*-objc-*-
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

#include <gsgd/GDLegendBox.h>
#include <gsgd/GDImage.h>
#include <gsgd/GDFrame.h>
#include <gsgd/GDFont.h>
#include <gsgd/GDLineStyle.h>
#include <Foundation/NSArray.h>

@implementation GDLegendBox

- (id) init
{
  ASSIGN (_font, [GDFont smallFont]);
  _meanings = [NSMutableArray new];
  _objects = [NSMutableArray new];
  return self;  
}

- (void) dealloc
{
  RELEASE (_font);
  RELEASE (_meanings);
  RELEASE (_objects);
  [super dealloc];
}


- (void) setExplanation: (NSString *)meaning
	       forStyle: (GDLineStyle *)style
{
  [_meanings addObject: meaning];
  [_objects addObject: style];
}

- (NSSize) comfortableSize
{
  NSSize size = NSMakeSize (0, 0);
  int i, count = [_meanings count];

  /* Compute the size of the string explanations.  */
  for (i = 0; i < count; i++)
    {
      NSString *s = (NSString *)[_meanings objectAtIndex: i];
      NSSize sBox;
      
      sBox = [_font boundingBoxForString: s];

      size.height += sBox.height;
      if (size.width < sBox.width)
	{
	  size.width = sBox.width;
	}
    }
  /* Add 3 pixels between each explanation and the next one.  */
  if (count > 1)
    {
      size.height += (count - 1) * 3;
    }

  /* Add 30 pixels to display each color/line style, plus 10 pixels
   * separation from the explanation.  */
  size.width += 40;

  /* Add 5 pixels border on all sides to separate from line border;
   * add 1 pixel line border on all sides.  */
  size.width += 12;
  size.height += 12;
  
  return size;
}

/* frame must be > comfortable size.  */
- (void) plotInFrame: (GDFrame *)frame
{
  GDImage *image = [frame image];
  int width = [frame width];
  int height = [frame height];
  NSRect rectangle = NSMakeRect (0, 0, width, height);
  int i, count = [_meanings count];
  
  /* Draw the line border.  */
  rectangle = [frame convertFrameRectToImage: rectangle];
  
  [image rectangleFromX: rectangle.origin.x
	 y: rectangle.origin.y
	 toX: NSMaxX (rectangle)
	 y: NSMaxY (rectangle)
	 color: [image allocatePaletteColorWithName: @"black"]];

  /* Empty space between the line border and the actual legend.  */
  width -= 12;
  height -= 12;

  frame = [frame subFrameWithRect: NSMakeRect (6, 6, width, height)];
  
  /* Draw the objects and the corresponding explanations.  */
  {
    /* A string is drawn by giving the coordinate of the top left
     * corner.  Start at the top of the list, going down.  */
    NSPoint origin = NSMakePoint (0, height);
    
    for (i = 0; i < count; i++)
      {
	NSString *s = (NSString *)[_meanings objectAtIndex: i];
	GDLineStyle *l = (GDLineStyle *)[_objects objectAtIndex: i];
	NSSize sBox;
	NSPoint imageOrigin;

	/* Get how big the string is going to be.  */
	sBox = [_font boundingBoxForString: s];

	/* Draw the object.  */
	[l plotLegendIconInFrame: [frame subFrameWithRect: 
					   NSMakeRect (0, 
						       origin.y - sBox.height,
						       30,
						       sBox.height)]];
	/* Now draw the text.  */
	origin.x = 40;
	imageOrigin = [frame convertFrameToImage: origin];
	
	[image string: s
	       x: imageOrigin.x
	       y: imageOrigin.y
	       color: [image allocatePaletteColorWithName: @"black"]
	       font: _font];

	/* Move on to the next entry.  */
	origin.y -= sBox.height;
	origin.y -= 3;
      }
  }
}

@end
