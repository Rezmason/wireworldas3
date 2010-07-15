/**
* Wireworld Player by Jeremy Sachs. June 22, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld.views {
	import flash.text.Font;
	
	
	internal final class FontSet {
		
		private static const FONTS:Object = {};
		
		internal static function populate(obj:Object):void {
			for (var prop:String in obj) {
				FONTS[prop] = (new obj[prop] as Font).fontName;
			}
		}
		
		internal static function getFontName(kind:String):String {
			return FONTS[kind] || "_" + kind;
		}
	}
}