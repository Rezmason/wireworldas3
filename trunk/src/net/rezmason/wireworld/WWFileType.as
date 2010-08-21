/**
* Wireworld Player by Jeremy Sachs. August 21, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld {
	
	//---------------------------------------
	// IMPORT STATEMENTS
	//---------------------------------------
	import flash.net.FileFilter;

	public final class WWFileType {

		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		public static const TXT_TYPE:FileFilter = new FileFilter("Text fileReferences (*.txt)","*.txt;");
		public static const MCL_TYPE:FileFilter = new FileFilter("MCell Wireworld fileReferences (*.mcl)","*.mcl;");
	}

}

