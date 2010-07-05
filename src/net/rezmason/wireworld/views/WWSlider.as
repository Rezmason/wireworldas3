/**
* Wireworld Player by Jeremy Sachs. June 22, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/

package net.rezmason.wireworld.views {
	
	import apparat.math.FastMath;
	
	import flash.display.Sprite;
	
	internal final class WWSlider extends WWElement {
		
		private var _value:Number = 1;
		private var _thumb:Sprite = new Sprite();
		
		public function WWSlider(__name:String, __width:Number = 100, __height:Number = 10):void {
			_thumb.transform.colorTransform = WWGUIPalette.BACK_MED_CT;
			super(__name, null, __width, __height, "[]");
		}
		
		override public function set content(value:*):void {}
		
		public function get value():Number { return _value; }
		public function set value(val:Number):void {
			if (!isNaN(val)) {
				_value = FastMath.min(FastMath.max(0, val), 1);
			}
			// position the slider
		}
		
		override protected function redraw():void {
			super.redraw();
			
			backing.transform.colorTransform = WWGUIPalette.BACK_DARKER_CT;
			
			_thumb.graphics.beginFill(0x0);
			_thumb.graphics.drawRoundRect(0, -_height * 0.5, _width * 0.1, _height, _height * 0.25, _height * 0.25);
			_thumb.graphics.endFill();
			addChild(_thumb);
			
			value = value;
		}
	}
}