#
#   Copyright (C) 2002 Free Software Foundation, Inc.
#
#   Author:  Nicola Pero <n.pero@mi.flashnet.it>
#   Date: July 2002
#   
#   This file is part of GNUstep.
#   
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#   
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#   
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. */

include $(GNUSTEP_MAKEFILES)/common.make

TOOL_NAME = ReadFile WriteFile WritePlot WritePie WriteBarChart
ReadFile_OBJC_FILES = ReadFile.m
WriteFile_OBJC_FILES = WriteFile.m
WritePlot_OBJC_FILES = WritePlot.m
WritePie_OBJC_FILES = WritePie.m
WriteBarChart_OBJC_FILES = WriteBarChart.m

ADDITIONAL_OBJCFLAGS += -Wall
ADDITIONAL_TOOL_LIBS += -lgsgd

JAVA_PACKAGE_NAME = gsgdtest
gsgdtest_JAVA_FILES = WritePlot.java WritePie.java WriteBarChart.java

include $(GNUSTEP_MAKEFILES)/tool.make
include $(GNUSTEP_MAKEFILES)/java.make

after-clean::
	-rm test.png test.jpg test.wbmp
	-rm plot.png plot_java.png
	-rm pie.png  pie_java.png
	-rm barchart.png barchart_java.png
