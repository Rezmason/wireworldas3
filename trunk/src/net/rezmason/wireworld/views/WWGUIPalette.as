/**
* Wireworld Player by Jeremy Sachs. June 22, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld.views {
	
	import flash.geom.ColorTransform;
	
	internal final class WWGUIPalette {
		
		internal static const BACK_DARK_CT:ColorTransform 	= new ColorTransform(0, 0, 0, 1, 0x60, 0x60, 0x60);
		internal static const BACK_MED_CT:ColorTransform 	= new ColorTransform(0, 0, 0, 1, 0x90, 0x90, 0x90);
		internal static const BACK_LIGHT_CT:ColorTransform = new ColorTransform(0, 0, 0, 1, 0xD0, 0xD0, 0xD0);
		internal static const FRONT_CT:ColorTransform     	= new ColorTransform(0, 0, 0, 1, 0x20, 0x20, 0x20);
		internal static const FRONT_TEXT_BACK_CT:ColorTransform	= new ColorTransform(0, 0, 0, 1, 0xFF, 0xFF, 0xFF);
		
		internal static const PLAIN_CT:ColorTransform = new ColorTransform;
		internal static const TOGGLED_CT:ColorTransform = new ColorTransform(1, 1, 1, 1, 90, 90, 90);
		internal static const INVERTED_CT:ColorTransform = new ColorTransform(-1, -1, -1, 1, 0xFF, 0xFF, 0xFF);
		
		internal static const INPUT_TEXT_BACK_CT:ColorTransform = new ColorTransform(0, 0, 0, 1, 0xFF, 0xFF, 0xFF);
		internal static const PLAIN_TEXT_BACK_CT:ColorTransform = BACK_MED_CT;
	}
}