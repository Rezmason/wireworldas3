/**
* Wireworld Player by Jeremy Sachs. August 21, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld.brains {	
	
	//---------------------------------------
	// IMPORT STATEMENTS
	//---------------------------------------
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	
	public class Spectrum {
		
		protected var width:int = 100, height:int = 1;
		protected var bitmap:BitmapData, vec:Vector.<uint>, flippedVec:Vector.<uint>;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function Spectrum():void {
			bitmap = new BitmapData(width, height, true, 0xFF000000);
			fillIn();
			vec = bitmap.getVector(bitmap.rect);
			vec.push(vec[width - 1]);
			flippedVec = vec.slice();
			var ike:int, jen:int;
			for (ike = 0; ike < flippedVec.length; ike++) {
				flippedVec[ike] = reverseUInt(flippedVec[ike]);
			}
		}
		
		protected function fillIn():void {
			var _matrix:Matrix = new Matrix;
			var _shape:Shape = new Shape;
			var _colors:Array = [0xFFFFFF, 0xFF0000, 0xFFFF00, 0x00FF00, 0x00FFFF, 0x0000FF, 0xFF00FF];
			var _alphas:Array = [1, 1, 1, 1, 1, 1, 1];
			var _places:Array = [0, 42.5, 85, 127.5, 170, 212.5, 255];
			
			_matrix.createGradientBox(bitmap.width, bitmap.height);
			_shape.graphics.beginGradientFill(GradientType.LINEAR, _colors, _alphas, _places, _matrix, SpreadMethod.PAD, InterpolationMethod.LINEAR_RGB);
			_shape.graphics.drawRect(0, 0, bitmap.width, bitmap.height);
			_shape.graphics.endFill();	
			
			bitmap.draw(_shape);
		}
		
		public function colorOf(input:Number, flipped:Boolean):uint {
			if (input > 1) input = 1;
			if (input < 0) input = 0;
			return (flipped ? flippedVec : vec)[int(input * width)];
		}
		
		private function reverseUInt(input:uint):uint {
			var a:int, r:int, g:int, b:int;
			
			a = (input >> 24) & 0xFF;
			r = (input >> 16) & 0xFF;
			g = (input >> 08) & 0xFF;
			b = (input >> 00) & 0xFF;
			
			return (b << 24) | (g << 16) | (r << 08) | (a << 00);
		}
	}
}