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

class WritePie
{ 
  public static void main (String[] args) 
    throws Throwable
  {
    Image image;
    
    System.err.println ("Creating an image...");
    image = new Image (300, 300);
    
    System.err.println ("Drawing into it...");

    BinDataSet bin;
    PieChart p;

    image.allocatePaletteColorWithName ("white");

    bin = new BinDataSet ();

    bin.setDataValue (1950, "Alpha");
    bin.setDataValue (13551, "Beta");
    bin.setDataValue (61402, "Gamma");
    bin.setDataValue (21703, "Delta");
    bin.setDataValue (121252, "Epsilon");
    bin.setDataValue (94939, "Mu");
    bin.setDataValue (59593, "Nu");
    bin.setDataValue (1950, "Kappa");
    bin.setDataValue (13551, "Omega");
    bin.setDataValue (61402, "Theta");
    bin.setDataValue (21703, "Psi");
    bin.setDataValue (121252, "Phi");
    bin.setDataValue (94939, "Zeta");
    bin.setDataValue (59593, "Eta");
    
    p = new PieChart ();
    p.setDataSet (bin);
    p.setTitle ("A test plot");
    p.plotInFrame (Frame.frameForImage (image));
    
    System.err.println ("Saving it as plot_java.png...");

    /* FIXME ... If we don't refer the NSData class before using it,
       it's never loaded, so the object returned by image.pngData() is
       not recognized as being an NSData, but rather returned as NSObject,
       causing a crash.  The fix is not clear - manually loading the
       NSData class by referring to it is a workaround.  */
    NSData data = new NSData ();
    
    NSData d = image.pngData ();
    d.writeToFile ("pie_java.png", true);
  }
}
