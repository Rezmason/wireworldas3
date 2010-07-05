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

	internal class WWTextField extends Sprite {
		
		private var _text:String;
		
		public function WWTextField(__name:String, __width:Number = 100, __height:Number = 10, 
				__idDynamic:Boolean = false, __defaultText:String = ""):void {
			super();
			name = __name; 
		}
		
		public function get text():String { return _text; }
		public function set text(value:String):void {
			_text = value;
			redraw();
		}
		
		private function redraw():void {
			
		}
	}
}