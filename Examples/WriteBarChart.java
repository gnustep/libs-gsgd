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

class WriteBarChart
{ 
  public static void main (String[] args) 
    throws Throwable
  {
    /* Workaround for internal JIGS problem.  */
    NSData data = new NSData ();

    BinDataSet bin;
    BarChart p;

    bin = new BinDataSet ();

    bin.setDataValue (12, "Database");
    bin.setDataValue (18, "SMS");
    bin.setDataValue (0, "Web");
    bin.setDataValue (11, "Wap");
    bin.setDataValue (204, "Unknown");
    
    p = new BarChart ();
    p.setDataSet (bin);
    p.setTitle ("A test plot");

    NSSize size = p.recommendedSize ();
    Image image = new Image ((int)(size.width), (int)(size.height));

    /* Background color.  */
    image.allocatePaletteColorWithName ("white");

    /* Bar colors.  */
    /*
      p.setBarColor (image.allocatePaletteColorWithName ("red"));
      p.setBarShadeColor (image.allocatePaletteColorWithName ("yellow"));
    */

    p.plotInFrame (Frame.frameForImage (image));

    System.err.println ("Writing image to barchart_java.png");
    (image.pngData ()).writeToFile ("barchart_java.png", true);
  }
}



