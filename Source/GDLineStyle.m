/* GDLineStyle.m
   Copyright (C) 2002, 2003 Free Software Foundation, Inc.
   
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

#include "gsgd/GDLineStyle.h"
#include "gsgd/GDFrame.h"
#include "gsgd/GDImage.h"

#include <gd.h>
#include <Foundation/NSException.h>
#include <Foundation/NSGeometry.h>

#ifndef GNUSTEP
#include <GNUstepBase/GNUstep.h>
#endif

@implementation GDLineStyle

+ (GDLineStyle *) dottedLineWithColor: (int)color
{
  return [self dottedLineWithColor: color  spacing: 3];
}


+ (GDLineStyle *) dottedLineWithColor: (int)color
			      spacing: (int)spacing
{
  GDLineStyle *s;

  s = [[self alloc] initWithLength: spacing + 1];
  s->colors[0] = color;
  AUTORELEASE (s);
  
  return s;
}

+ (GDLineStyle *) dashedLineWithColor: (int)color
{
  return [self dashedLineWithColor: color  spacing: 3];
}

+ (GDLineStyle *) dashedLineWithColor: (int)color
			      spacing: (int)spacing
{
  GDLineStyle *s;
  int i;

  s = [[self alloc] initWithLength: spacing * 2];
  for (i = 0; i < spacing; i++)
    {
      s->colors[i] = color;
    }
  AUTORELEASE (s);
  
  return s;
}

+ (GDLineStyle *) dashdotLineWithColor: (int)color
{
  return [self dashdotLineWithColor: color
	       spacing: 3];
}

+ (GDLineStyle *) dashdotLineWithColor: (int)color
			       spacing: (int)spacing
{
  GDLineStyle *s;
  int i;

  s = [[self alloc] initWithLength: (spacing * 3) + 1];
  for (i = 0; i < spacing; i++)
    {
      s->colors[i] = color;
    }
  s->colors[2 * spacing] = color;
  AUTORELEASE (s);
  
  return s;
}

+ (GDLineStyle *) lineWithColor: (int)color
{
  GDLineStyle *s;

  s = [[self alloc] initWithLength: 1];
  s->colors[0] = color;
  AUTORELEASE (s);
  
  return s;  
}


/*
 * Initializers
 */

- (id) initWithLength: (int)l
{
  return [self initWithLength: l  pixelColors: NULL];
}

- (id) initWithLength: (int)l
	  pixelColors: (int *)c
{
  int i;

  length = l;
  colors = objc_malloc (sizeof (int) * length);
  
  if (c == NULL)
    {
      for (i = 0; i < length; i++)
	{
	  colors[i] = gdTransparent;
	} 
    }
  else
    {
      for (i = 0; i < length; i++)
	{
	  colors[i] = c[i];
	}
    }

  return self;
}

- (void) dealloc
{
  objc_free (colors);
  [super dealloc];
}

/*
 * Manipulating line styles
 */

- (void) setPixelColor: (int)color
	       atIndex: (int)i
{
  if (i < 0  ||  i >= length)
    {
      [NSException raise: NSRangeException
		   format: @"Setting color outside GDLineStyle length"];
    }
  
  colors[i] = color;
}


- (void) setPixelTransparentAtIndex: (int)i
{
  if (i < 0  ||  i >= length)
    {
      [NSException raise: NSRangeException
		   format: @"Setting color outside GDLineStyle length"];
    }

  colors[i] = gdTransparent;
}

/*
 * Accessing line styles
 */

- (int) length
{
  return length;
}

- (int *) colors
{
  return colors;
}

/*
 * Drawing a legend icon for this line style
 */
- (void) plotLegendIconInFrame: (GDFrame *)frame
{
  if (length == 1)
    {
      /* Draw a square, as big as possible, with the color.  */
      int width = [frame width];
      int height = [frame height];
      int side;
      NSRect r;
      
      if (width > height)
	{
	  side = height;
	}
      else
	{
	  side = width;
	}

      r = NSMakeRect ((width - side) / 2, (height - side) / 2, side, side);
      r = [frame convertFrameRectToImage: r];

      [[frame image] drawFilledRectangle: r
		     color: colors[0]];
    }
  else
    {
      NSLog (@"Yet to implement");
    }
}

@end
