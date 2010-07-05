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

	internal class WWTextField extends WWElement {
		
		private var _text:String;
		
		public function WWTextField(__name:String, __width:Number = 100, __height:Number = 10, __capStyle:String = null, 
				__idDynamic:Boolean = false, __defaultText:String = ""):void {
			
			// the content will be a dynamic text area.		
			var textbox:* = null;
			
			super(__name, textbox, __width, __height, __capStyle);
		}
		
		public function get text():String { return _text; }
		public function set text(value:String):void {
			_text = value;
			redraw();
		}
		
		override protected function redraw():void {
			super.redraw();
			
			backing.transform.colorTransform = WWGUIPalette.BACK_MED_CT;
		}
	}
}