/**
* Wireworld Player by Jeremy Sachs. June 22, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld.views {
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Matrix;

	internal final class BarberPole extends Shape {
		
		private var stripe:BitmapData, mat:Matrix;
		private var _width:Number, _height:Number;
		
		public function BarberPole(__width:Number = NaN, __height:Number = NaN):void {
			super();
			
			stripe = new BitmapData(2, 1, true, 0x0);
			stripe.setPixel32(0, 0, 0xFF000000);
			mat = new Matrix(30, 0, 20, 20);
			
			_width = isNaN(__width) ? 200 : __width;
			_height = isNaN(__height) ? 25 : __height;
			update();
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		override public function set width(value:Number):void {
			if (isNaN(value) || value == _width) return;
			_width = value;
			update();
		}
		
		override public function set height(value:Number):void {
			if (isNaN(value) || value == _height) return;
			_height = value;
			update();
		}
		
		override public function set visible(value:Boolean):void {
			if (visible == value) return;
			visible = value;
			(visible ? addEventListener : removeEventListener)(Event.ENTER_FRAME, update);
		}
		
		private function update(event:Event = null):void {
			if (event) mat.tx += 5;
			trace(mat.tx);
			
			graphics.clear();
			graphics.beginBitmapFill(stripe, mat, true);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
		}
	}
}