/**
* Wireworld Player by Jeremy Sachs. June 22, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld.views {
	
	import flash.display.Sprite;
	
	internal final class WWTextButton extends WWButton {
		
		public function WWTextButton(__label:String, __text:String, __height:Number = 10, __type:String = null):void {
			super(__label, TextFactory.generateInBox(__text, "_sans", __height * 0.65, true), __height, "()", __type);
		}
		
	}
}