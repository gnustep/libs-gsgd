/* GDFrame.m - A rectangular area of a GDImage  -*-objc-*-
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

#include <gsgd/GDFrame.h>
#include <gsgd/GDImage.h>

@implementation GDFrame

- (id) initWithImage: (GDImage *)image
{
  return [self initWithImage: image
	       rect: NSMakeRect (0, 0, [image width], [image height])];
}

- (id) initWithImage: (GDImage *)image
		rect: (NSRect)area
{
  ASSIGN (_image, image);

  /* We store the coordinates of the lower left corner ... while the
   * coordinates we were given are the ones of the upper left
   * corner!  */
  _x = area.origin.x;
  _width = area.size.width;
  
  _y = area.origin.y + area.size.height;
  _height = area.size.height;

  return self;
}

- (void) dealloc
{
  RELEASE (_image);
  [super dealloc];
}

+ (GDFrame *) frameForImage: (GDImage *)image
{
  return AUTORELEASE ([[self alloc] initWithImage: image]);
}

- (GDImage *) image
{
  return _image;
}

- (int) width
{
  return _width;
}

- (int) height
{
  return _height;
}

- (NSPoint) convertFrameToImage: (NSPoint)framePoint
{
  NSPoint imagePoint;
  
  imagePoint.x = _x + framePoint.x;
  imagePoint.y = _y - framePoint.y;
  
  return imagePoint;
}

- (NSPoint) convertImageToFrame: (NSPoint)imagePoint
{
  NSPoint framePoint;
  
  framePoint.x = imagePoint.x - _x;
  framePoint.y = _y - imagePoint.y;
  
  return framePoint;
}

- (NSRect) convertFrameRectToImage: (NSRect)frameRect
{
  NSRect imageRect;
  
  imageRect.origin.x = _x + frameRect.origin.x;
  imageRect.origin.y = _y - (frameRect.origin.y + frameRect.size.height);
  imageRect.size = frameRect.size;

  return imageRect;
}

- (NSRect) convertImageRectToFrame: (NSRect)imageRect
{
  NSRect frameRect;
  
  frameRect.origin.x = imageRect.origin.x - _x;
  frameRect.origin.y =  _y - (imageRect.origin.y + imageRect.size.height);
  frameRect.size = imageRect.size;

  return frameRect;
}

- (GDFrame *) subFrameWithRect: (NSRect)newFrameArea
{
  GDFrame *frame;
  
  frame = [[GDFrame alloc] initWithImage: _image
			   rect: [self convertFrameRectToImage: newFrameArea]];
  AUTORELEASE (frame);

  return frame;
}

- (NSString *) description
{
  NSString *s;
  
  s = [NSString stringWithFormat: @"x = %d, y = %d, width = %d, height = %d",
		_x, _y, _width, _height];
  return s;
}

@end


