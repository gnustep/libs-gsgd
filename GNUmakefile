#
#  examples makefile for the GNUstep Base Library
#
#  Copyright (C) 1997 Free Software Foundation, Inc.
#
#  Written by:	Scott Christley <scottc@net-community.com>
#
#  This file is part of the GNUstep Base Library.
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
#  Library General Public License for more details.
#
#  You should have received a copy of the GNU Library General Public
#  License along with this library; if not, write to the Free
#  Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#

# Install into the system root by default
GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_SYSTEM_ROOT)

GNUSTEP_MAKEFILES = $(GNUSTEP_SYSTEM_ROOT)/Makefiles

include $(GNUSTEP_MAKEFILES)/common.make


#include ../../Version
#include ../../config.mak

srcdir = .
PACKAGE_NAME = gsgd

# The library to be compiled
LIBRARY_NAME=libgsgd

# The Objective-C source files to be compiled
#NSString+MiscRegex.m
libgsgd_OBJC_FILES = \
GDGIFPlot.m \
GDSimpleFont.m \
GDGIFImage.m \
GDColor.m

#NSString+MiscRegex.h
libgsgd_HEADER_FILES = \
GDGIFPlot.h \
GDSimpleFont.h \
GDGIFImage.h \
GDCom.h \
GDColor.h

SRCS = $(LIBRARY_NAME:=.m)

HDRS = $(LIBRARY_NAME:=.h)

libgsgd_HEADER_FILES_DIR = .
libgsgd_HEADER_FILES_INSTALL_DIR = /$(GNUSTEP_FND_DIR)/gsgd

#DIST_FILES = $(SRCS) $(HDRS) GNUmakefile Makefile.postamble Makefile.preamble

-include Makefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/library.make

-include Makefile.postamble
