/* GDSimpleFont.m - Implementation of GDSimpleFont
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
#include <Foundation/NSDictionary.h>
#include <Foundation/NSEnumerator.h>
#include <Foundation/NSConcreteNumber.h>
#include <Foundation/NSDebug.h>
#include <gdfontg.h>
#include <gdfontl.h>
#include <gdfontmb.h>
#include <gdfonts.h>
#include <gdfontt.h>
#include <gsgd/GDSimpleFont.h>

NSDictionary* localFontsDictionary=nil;
NSDictionary* localFontSizeDictionary=nil;
GDSimpleFont* GDTinyFont=nil;
GDSimpleFont* GDSmallFont=nil;
GDSimpleFont* GDMediumBoldFont=nil;
GDSimpleFont* GDLargeFont=nil;
GDSimpleFont* GDGiantFont=nil;

@implementation GDSimpleFont

+(GDSimpleFont*)fontWithName:(NSString*)name_
{
  NSDebugMLog(@"GDSimpleFont fontWithName: name_=%@",name_);
  NSDebugMLog(@"GDSimpleFont localFontsDictionary: localFontsDictionary=%@",localFontsDictionary);
  return [localFontsDictionary objectForKey:name_];
};

-(id)initWithName:(NSString*)name_
		  fontPtr:(gdFontPtr)fontPtr_
{
  if ((self=[super init]))
	{
	  if (fontPtr_)
		fontPtr=fontPtr_;
	  ASSIGN(name,name_);
	  if (fontPtr)
		size=NSMakeSize(fontPtr->w,fontPtr->h);	  
	};
  return self;
};

+(GDSimpleFont*)fontWithName:(NSString*)name_
					 fontPtr:(gdFontPtr)fontPtr_
{
  return [[[self alloc] initWithName:name_
						fontPtr:fontPtr_] autorelease];
};


+(void)initialize
{
  NSDebugFLog(@"GDSimpleFont initialize... %@",@"");
  if (self==[GDSimpleFont class])
	{
	  NSDebugFLog(@"GDSimpleFont create fonts... %@",@"");
	  if (!GDTinyFont)
		GDTinyFont=[[GDSimpleFont fontWithName:@"TinyFont"
								 fontPtr:gdFontTiny] retain];
	  if (!GDSmallFont)
		GDSmallFont=[[GDSimpleFont fontWithName:@"SmallFont"
								  fontPtr:gdFontSmall] retain];
	  if (!GDMediumBoldFont)
		GDMediumBoldFont=[[GDSimpleFont fontWithName:@"MediumBoldFont"
									   fontPtr:gdFontMediumBold] retain];
	  
	  if (!GDLargeFont)
		GDLargeFont=[[GDSimpleFont fontWithName:@"LargeFont"
								  fontPtr:gdFontLarge] retain];
	  
	  if (!GDGiantFont)
		GDGiantFont=[[GDSimpleFont fontWithName:@"GiantFont"
								  fontPtr:gdFontGiant] retain];
	  if (!localFontsDictionary)
		localFontsDictionary=[[NSDictionary  dictionaryWithObjectsAndKeys:
											  GDTinyFont,[GDTinyFont name],
											GDSmallFont,[GDSmallFont name],
											GDMediumBoldFont,[GDMediumBoldFont name],
											GDLargeFont,[GDLargeFont name],
											GDGiantFont,[GDGiantFont name],
											nil,nil] retain];
	  if (!localFontsDictionary)
		localFontSizeDictionary=[[NSDictionary  dictionaryWithObjectsAndKeys:
												 GDTinyFont,[NSNumber numberWithInt:[GDTinyFont size].height],
											   GDSmallFont,[NSNumber numberWithInt:[GDSmallFont size].height],
											   GDMediumBoldFont,[NSNumber numberWithInt:[GDMediumBoldFont size].height],
											   GDLargeFont,[NSNumber numberWithInt:[GDLargeFont size].height],
											   GDGiantFont,[NSNumber numberWithInt:[GDGiantFont size].height],
											   nil,nil] retain];
												 
	};
};

//--------------------------------------------------------------------
+(void)dealloc
{
  DESTROY(localFontsDictionary);
  DESTROY(GDTinyFont);
  DESTROY(GDSmallFont);
  DESTROY(GDMediumBoldFont);
  DESTROY(GDLargeFont);
  DESTROY(GDGiantFont);
};

-(NSString*)name
{
  return name;
};

-(NSSize)size
{
  return size;
};

-(gdFontPtr)fontPtr
{
  return fontPtr;
};

-(GDSimpleFont*)largerFont
{
  int goodSize=INT_MAX;
  GDSimpleFont* goodFont=nil;
  NSNumber* _key=nil;
  NSEnumerator* _enum = [localFontsDictionary keyEnumerator];
  while ((_key = [_enum nextObject]))
	{
	  if ([_key intValue]>size.height && [_key intValue]<goodSize)
		{
		  goodSize=[_key intValue];
		  goodFont=[localFontsDictionary objectForKey:_key];
		};
	};
  return goodFont;
};
-(GDSimpleFont*)smallerFont
{
  int goodSize=INT_MIN;
  GDSimpleFont* goodFont=nil;
  NSNumber* _key=nil;
  NSEnumerator* _enum = [localFontsDictionary keyEnumerator];
  while ((_key = [_enum nextObject]))
	{
	  if ([_key intValue]<size.height && [_key intValue]>goodSize)
		{
		  goodSize=[_key intValue];
		  goodFont=[localFontsDictionary objectForKey:_key];
		};
	};
  return goodFont;
};

-(NSDictionary*)sizeDictionary
{
  return localFontsDictionary;
};
@end


