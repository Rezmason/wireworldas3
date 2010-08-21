/**
* Wireworld Player by Jeremy Sachs. August 21, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld.views {
	
	//---------------------------------------
	// IMPORT STATEMENTS
	//---------------------------------------
	import apparat.math.IntMath;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontLookup;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	
	// CreditBox staples a text blob to the side of an image, using a pixel font. 
	
	internal final class CreditBox extends Sprite {
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private static const MARGIN:Number = 8;
		
		private var drawPoint:Point = new Point;
		private var fontDescription:FontDescription;
        private var format:ElementFormat;
        private var textBlock:TextBlock = new TextBlock();
        private var _credit:String;
        private var textColor:uint, backgroundColor:uint;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function CreditBox(fontName:String, palette:ColorPalette):void {
			fontDescription = new FontDescription(fontName);
			fontDescription.fontLookup = FontLookup.EMBEDDED_CFF;
            format = new ElementFormat();
            format.fontSize = 8;
            format.color = palette.wire;
            format.fontDescription = fontDescription;
            textColor = 0xFF000000 | palette.head;
            backgroundColor = 0xFF000000 | palette.dead;
            textBlock = new TextBlock();
		}
		
		//---------------------------------------
		// INTERNAL METHODS
		//---------------------------------------
		
		internal function appendCredit(image:BitmapData, credit:String = null):BitmapData {
			
			if (credit && credit.length && credit != _credit) {
				_credit = credit;
				while (numChildren) removeChildAt(0);
	            textBlock.content = new TextElement(_credit, format);
	            var linePosition:Number = MARGIN;
	            	            
	        	var textLine:TextLine;
	            while (textLine = textBlock.createTextLine(textLine, 300)) {
	                addChild(textLine);
	                textLine.x = MARGIN;
	                textLine.y = linePosition;
	                linePosition += 8;
	            }
   			}
   			
            var _width:int = width + MARGIN, _height:int = height + 2 * MARGIN;
            var iWidth:int = image.width + 2 * MARGIN, iHeight:int = image.height + 2 * MARGIN;
			var returnVal:BitmapData = new BitmapData(iWidth + _width, IntMath.max(iHeight, _height), true, backgroundColor);
			if (credit) {
				returnVal.draw(this);
				returnVal.threshold(returnVal, returnVal.rect, returnVal.rect.topLeft, "!=", backgroundColor, textColor, 0xFFFFFFFF, true);
			}
			drawPoint.x = int(_width + MARGIN), drawPoint.y = int(MARGIN);
			returnVal.copyPixels(image, image.rect, drawPoint);
			return returnVal;
		}
	}
}