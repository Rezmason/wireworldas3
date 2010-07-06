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
		
		private static const MARGIN:Number = 2;
		
		private var _value:Number = 1;
		private var _thumb:Sprite = new Sprite();
		
		public function WWSlider(__name:String, __width:Number = 100, __height:Number = 10):void {
			_thumb.transform.colorTransform = WWGUIPalette.FRONT_CT;
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
			
			backing.transform.colorTransform = WWGUIPalette.BACK_DARK_CT;
			
			var thumbHeight:Number = _height - MARGIN * 2;
			
			_thumb.graphics.beginFill(0x0);
			_thumb.graphics.drawRoundRect(0, -thumbHeight * 0.5, thumbHeight, thumbHeight, thumbHeight * 0.25, thumbHeight * 0.25);
			_thumb.graphics.endFill();
			_thumb.x = MARGIN;
			addChild(_thumb);
			
			value = value;
		}
	}
}