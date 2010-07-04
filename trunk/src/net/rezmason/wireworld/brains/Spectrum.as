/**
* Wireworld Player by Jeremy Sachs. June 22, 2010
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
	
	internal final class Spectrum extends BitmapData {
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function Spectrum():void {
			
			super(100, 1, true, 0xFF000000);
			
			var _matrix:Matrix = new Matrix;
			var _shape:Shape = new Shape;
			var _colors:Array = [0xFFFFFF, 0xFF0000, 0xFFFF00, 0x00FF00, 0x00FFFF, 0x0000FF, 0xFF00FF];
			var _alphas:Array = [1, 1, 1, 1, 1, 1, 1];
			var _places:Array = [0, 42.5, 85, 127.5, 170, 212.5, 255];
			
			_matrix.createGradientBox(width, height);
			_shape.graphics.beginGradientFill(GradientType.LINEAR, _colors, _alphas, _places, _matrix, SpreadMethod.PAD, InterpolationMethod.LINEAR_RGB);
			_shape.graphics.drawRect(0, 0, width, height);
			_shape.graphics.endFill();	
			
			draw(_shape);
		}
	}
}