/* Generate a plot, and write it to a file.

   Copyright (C) 2002 Free Software Foundation, Inc.

   Written by: Nicola Pero <nicola@brainstorm.co.uk>
   Created: July 2002

   This file is part of the GNUstep Project

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   You should have received a copy of the GNU General Public
   License along with this program; see the file COPYING.LIB.
   If not, write to the Free Software Foundation,
   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
   */

import gnu.gnustep.base.*;
import gnu.gnustep.gd.*;

class WritePlot
{ 
  public static void main (String[] args) 
    throws Throwable
  {
    Image image;
    
    System.err.println ("Creating an image...");
    image = new Image (220, 220);
    
    System.err.println ("Drawing into it...");

    int i, white, black, red, blue, yellow, gray;
    
    white = image.allocatePaletteColorWithName ("white");
    black = image.allocatePaletteColorWithName ("black");
    red = image.allocatePaletteColorWithName ("red");
    blue = image.allocatePaletteColorWithName ("Blue");
    yellow = image.allocatePaletteColorWithName ("yellow");
    gray = image.allocatePaletteColorWithName ("Gray");

    image.rectangle (10, 10, 210, 210, black);
    image.setLineStyle (LineStyle.dottedLineWithColor (gray));

    for (i = 30; i < 210; i += 20)
      {
	image.line (11, i, 209, i, Image.styledColor ());
	image.line (i, 11, i, 209, Image.styledColor ());
      }

    image.string ("y = sin (x)", 70, 30, black, Font.mediumBoldFont ());
    
    /* Let's plot a rough  y = sin (x)  */
    int x;
    for (x = 1; x < 200; x++)
      {
	float x_ = (float)(x / 10.);
	float y_ = (float)(Math.sin (x_));
	
	image.setPixelColor (black, x + 10, (int)((y_ * 50) + 100));
      }

    System.err.println ("Saving it as plot_java.png...");

    /* FIXME ... If we don't refer the NSData class before using it,
       it's never loaded, so the object returned by image.pngData() is
       not recognized as being an NSData, but rather returned as NSObject,
       causing a crash.  The fix is not clear - manually loading the
       NSData class by referring to it is a workaround.  */
    NSData data = new NSData ();
    
    NSData d = image.pngData ();
    d.writeToFile ("plot_java.png", true);
  }
}
