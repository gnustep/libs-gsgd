/* GDSimpleFont.h - Interface of GDSimpleFont
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

#ifndef _GDSimpleFont_h__
	#define _GDSimpleFont_h__

#include <gsgd/GDCom.h>

@interface GDSimpleFont : NSObject
{
  NSString* name;
  gdFontPtr fontPtr;
  NSSize size;
};

+(GDSimpleFont*)fontWithName:(NSString*)name;
-(NSString*)name;
-(NSSize)size;
-(gdFontPtr)fontPtr;
-(GDSimpleFont*)largerFont;
-(GDSimpleFont*)smallerFont;
-(NSDictionary*)sizeDictionary;
@end

extern GDSimpleFont* GDTinyFont;
extern GDSimpleFont* GDSmallFont;
extern GDSimpleFont* GDMediumBoldFont;
extern GDSimpleFont* GDLargeFont;
extern GDSimpleFont* GDGiantFont;


#endif // _GDSimpleFont_h__
