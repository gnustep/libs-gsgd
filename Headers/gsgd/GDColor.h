/* GDColor.h - Interface of GDColor -*-objc-*-
   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:  Manuel Guesdon <mguesdon@orange-concept.com>
   Created: Dec 1999
   
   Modified by: Nicola Pero <n.pero@mi.flashnet.it>
   Date: July 2002

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

#ifndef _gsgd_GDColor_h__
#define _gsgd_GDColor_h__

#include <Foundation/NSObject.h>

@interface GDColor : NSObject <NSCoding, NSCopying>
{
  int _red;
  int _green;
  int _blue;
};

+ (GDColor *) colorWithRed: (int)red
		     green: (int)green
		      blue: (int)blue;
- (id) initWithRed: (int)red
	     green: (int)green
	      blue: (int)blue;
- (id) copyWithZone: (NSZone*)aZone;
- (NSString*) description;
- (void) encodeWithCoder: (NSCoder*)aCoder;
- (id) initWithCoder: (NSCoder*)aDecoder;
- (NSComparisonResult) compare: (id)anObject;
- (BOOL) isEqual: (id)anObject;
- (int) red;
- (int) green;
- (int) blue;
@end

#endif /* _gsgd_GDColor_h__ */

