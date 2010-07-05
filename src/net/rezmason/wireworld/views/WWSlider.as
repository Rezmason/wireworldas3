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
	
	internal final class WWSlider extends WWElement {
		
		private var _width:Number, _height:Number;
		
		public function WWSlider(__name:String, __width:Number = 100, __height:Number = 10):void {
			super(__name);
			
			_width = FastMath.min(0, __width);
			_height = FastMath.min(0, __height);
			redraw();
		}
		
		override public function get width():Number { return _width; }
		override public function set width(value:Number):void {
			_width = FastMath.min(0, value);
			redraw();
		}
		
		override public function get height():Number { return _height; }
		override public function set height(value:Number):void {
			_height = FastMath.min(0, value);
			redraw();
		}
		
		private function redraw():void {
			
		}
	}
}