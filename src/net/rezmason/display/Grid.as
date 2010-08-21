/**
* Wireworld Player by Jeremy Sachs. August 21, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.display {

	//---------------------------------------
	// IMPORT STATEMENTS
	//---------------------------------------
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	public final class Grid extends Sprite {
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private var smallRect:Rectangle;
		private var gridData:BitmapData;
		private var _width:Number = 1, _height:Number = 1;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		// Draws a grid of a certain square size. For now its colors are hard coded in.
		
		public function Grid(squareSize:int, __width:Number, __height:Number):void {
			
			gridData = new BitmapData(squareSize, squareSize, true, 0xFF555555);
			smallRect = new Rectangle(0, 0, gridData.width / 2, gridData.height / 2);
			gridData.fillRect(smallRect, 0xFF333333);
			smallRect.x = smallRect.y = smallRect.width;
			gridData.fillRect(smallRect, 0xFF333333);
			
			width = __width;
			height = __height;
			
			opaqueBackground = 0x333333;
			cacheAsBitmap = true;
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		override public function get width():Number {
			return _width;
		}
		
		override public function set width(value:Number):void {
			if (value > 0) {
				_width = value;
				redraw();
			}
		}
		
		override public function get height():Number {
			return _height;
		}
		
		override public function set height(value:Number):void {
			if (value > 0) {
				_height = value;
				redraw();
			}
		}
		
		//---------------------------------------
		// PRIVATE METHODS
		//---------------------------------------
		
		private function redraw():void {
			graphics.clear();
			graphics.beginBitmapFill(gridData, null, true);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
		}
	}
}
