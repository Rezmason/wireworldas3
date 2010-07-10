/**
* Wireworld Player by Jeremy Sachs. June 22, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld.views {
	
	import apparat.math.IntMath;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.Font;
	import flash.text.TextFormat;
	
	import fl.text.TLFTextField;
	
	internal final class CreditBox {
		
		private static const FONT_SIZE:int = 8;
		
		private var drawPoint:Point = new Point, drawMatrix:Matrix = new Matrix;
		private var field:TLFTextField = new TLFTextField;
		private var format:TextFormat = new TextFormat;
		
		public function CreditBox(fontClass:Class):void {
			Font.registerFont(fontClass);
			format.font = (new fontClass as Font).fontName;
			format.size = FONT_SIZE;
			format.color = 0xD0D0D0;
			format.leading = 0;
			
			field.defaultTextFormat = format;
			field.width = 300;
			field.wordWrap = true;
			field.embedFonts = true;
		}
		
		internal function appendCredit(image:BitmapData, credit:String):BitmapData {
			field.height = image.height;
			field.text = credit;
			var returnVal:BitmapData = new BitmapData(image.width + field.width, IntMath.max(image.height, field.height), false, 0x000000);
			drawPoint.x = field.width;
			drawMatrix.tx = field.width;
			returnVal.copyPixels(image, image.rect, drawPoint);
			returnVal.draw(field);
			return returnVal;
		}
	}
}