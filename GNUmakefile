#
#  Copyright (C) 1997 Free Software Foundation, Inc.
#
#  This file is part of gsgd
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

GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_SYSTEM_ROOT)

include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = gsgd
LIBRARY_NAME = libgsgd

libgsgd_OBJC_FILES = \
GDPlot.m \
GDSimpleFont.m \
GDImage.m \
GDColor.m
#NSString+MiscRegex.m

libgsgd_HEADER_FILES = \
GDPlot.h \
GDSimpleFont.h \
GDImage.h \
GDCom.h \
GDColor.h
#NSString+MiscRegex.h

libgsgd_HEADER_FILES_INSTALL_DIR = /$(GNUSTEP_FND_DIR)/gsgd

include config.make

ADDITIONAL_INCLUDE_DIRS += -I../
LIBRARIES_DEPEND_UPON = -lgd

include $(GNUSTEP_MAKEFILES)/library.make

