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
	
	// Used to color the heat bitmap.
	
	public final class HeatSpectrum extends Spectrum {
		
		override protected function fillIn():void {
			var _matrix:Matrix = new Matrix;
			var _shape:Shape = new Shape;
			var _colors:Array = [0x000000, 0x0000FF, 0xFF00FF, 0xFF8800];
			var _alphas:Array = [1, 1, 1, 1];
			var _places:Array = [0, 20, 128, 255];
			
			_matrix.createGradientBox(bitmap.width, bitmap.height);
			_shape.graphics.beginGradientFill(GradientType.LINEAR, _colors, _alphas, _places, _matrix, SpreadMethod.PAD, InterpolationMethod.LINEAR_RGB);
			_shape.graphics.drawRect(0, 0, bitmap.width, bitmap.height);
			_shape.graphics.endFill();	
			
			bitmap.draw(_shape);
		}
	}
}