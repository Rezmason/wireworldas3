/**
* Wireworld Player by Jeremy Sachs. August 21, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld.views {
	
	//---------------------------------------
	// IMPORT STATEMENTS
	//---------------------------------------
	import flash.geom.ColorTransform;
	
	// Where all the GUI-related colors are stored.
	
	internal final class WWGUIPalette {
		
		internal static const BACK_DARKEST_CT:ColorTransform = new ColorTransform(0, 0, 0, 1, 0x20, 0x20, 0x20);
		internal static const BACK_DARK_CT:ColorTransform 	= new ColorTransform(0, 0, 0, 1, 0x60, 0x60, 0x60);
		internal static const BACK_MED_CT:ColorTransform 	= new ColorTransform(0, 0, 0, 1, 0x90, 0x90, 0x90);
		internal static const BACK_LIGHT_CT:ColorTransform = new ColorTransform(0, 0, 0, 1, 0xD0, 0xD0, 0xD0);
		internal static const FRONT_CT:ColorTransform     	= new ColorTransform(0, 0, 0, 1, 0x20, 0x20, 0x20);
		internal static const FRONT_LIGHTEST_CT:ColorTransform	= new ColorTransform(0, 0, 0, 1, 0xFF, 0xFF, 0xFF);
		
		internal static const PLAIN_CT:ColorTransform = new ColorTransform;
		internal static const TOGGLED_CT:ColorTransform = new ColorTransform(1, 1, 1, 1, 90, 90, 90);
		internal static const INVERTED_CT:ColorTransform = new ColorTransform(-1, -1, -1, 1, 0xFF, 0xFF, 0xFF);
		
		internal static const INPUT_TEXT_BACK_CT:ColorTransform = new ColorTransform(0, 0, 0, 1, 0xFF, 0xFF, 0xFF);
		internal static const PLAIN_TEXT_BACK_CT:ColorTransform = BACK_MED_CT;
		
		internal static const NAKED_TEXT:int = 0x202020;
		internal static const PLAIN_TEXT:int = 0x909090;
		internal static const EDITING_TEXT:int = 0x0;
		internal static const DEFAULT_TEXT:int = 0x909090;
		
		internal static const DIALOG_BACK:int = 0xFFFFFF;
		internal static const DIALOG_BACK_CT:ColorTransform = new ColorTransform(0, 0, 0, 1, 0xFF, 0xFF, 0xFF);
		
		internal static const HINT_BACK:int = 0xFFFFAA;
	}
}