package net.rezmason.display {

	import __AS3__.vec.Vector;
	
	import apparat.math.FastMath;
	
	import com.adobe.images.PNGEncoder;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.IBitmapDrawable;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	// This class is a modification of Keith Peters's aptly named BigAssCanvas.
	// Yes sir! 
	// You can download the original here: http://www.bit-101.com/blog/?p=1199
	
	// Since BAMFs typically contain only one segment, I've added a condition
	// to most of these methods to quickly operate on that segment, 
	// rather than pass through a for loop.
	
	public final class BAMF {
		
		private static const ORIGIN:Point = new Point();
		
		private var _bitmaps:Vector.<BitmapData>;
		private var _positions:Vector.<Point>;
		private var _width:Number;
		private var _height:Number;
		private var _transparent:Boolean;
		private var _color:uint;
		private var dirtyPNG:Boolean = true;
		private var _png:ByteArray;
		
		private var pt:Point, bmp:BitmapData;
		private var ike:int;

		public function BAMF(__width:Number, __height:Number, __transparent:Boolean = false, __color:uint = 0xffffff, __copyFrom:BAMF = null) {
			_width = __width;
			_height = __height;
			_transparent = __transparent;
			_color = __color;
			makeBitmaps(__copyFrom);
		}

		private function makeBitmaps(copyFrom:BAMF):void {
			
			if (copyFrom) {
				_bitmaps = copyFrom._bitmaps.slice();
				_positions = copyFrom._positions.slice();
				for (ike = 0; ike < _bitmaps.length; ike++) _bitmaps[ike] = _bitmaps[ike].clone();
				for (ike = 0; ike < _positions.length; ike++) _positions[ike] = _positions[ike].clone();
			} else {
				_bitmaps = new <BitmapData>[];
				_positions = new <Point>[];
				
				var h:Number = _height;
				var ypos:Number = 0;
	
				while (h > 0) {
					var xpos:Number = 0;
					var w:Number = _width;
					while (w > 0) {
						bmp = new BitmapData(FastMath.min(2880, w), FastMath.min(2880, h), _transparent, _color);
						_bitmaps.push(bmp);
						_positions.push(new Point(xpos, ypos));
						w -= bmp.width;
						xpos += bmp.width;
					}
					
					ypos += FastMath.min(2880, h);
					h -= FastMath.min(2880, h);
				}
			}
		}
		
		public function get height():Number { return _height; }
		public function get width():Number { return _width; }
		public function get transparent():Boolean { return _transparent; }

		public function draw(source:IBitmapDrawable, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:String = null, clipRect:Rectangle = null, smoothing:Boolean = false):void {

			if (matrix == null) matrix = new Matrix();
			
			if (_bitmaps.length == 1) {
				_bitmaps[0].draw(source, matrix, colorTransform, blendMode, clipRect, smoothing);
				return;
			}
			
			for (ike = 0; ike < _bitmaps.length; ike++) {
				bmp = _bitmaps[ike];
				pt = _positions[ike];
				var temp:Matrix = matrix.clone();
				temp.tx -= pt.x;
				temp.ty -= pt.y;

				var tempRect:Rectangle;
				if (clipRect != null) {
					tempRect = clipRect.clone();
					tempRect.x -= pt.x;
					tempRect.y -= pt.y;
				} else {
					tempRect = null;
				}
				bmp.draw(source, temp, colorTransform, blendMode, tempRect, smoothing);
			}
			
			dirtyPNG = true;
		}

		public function dispose():void {
			while (_bitmaps.length) _bitmaps.shift().dispose();
			if (_png) _png.clear();
			_png = null;
		}

		public function fillRect(rect:Rectangle, color:uint):void {
			if (_bitmaps.length == 1) {
				_bitmaps[0].fillRect(rect, color);
				return;
			}
			
			var temp:Rectangle = rect.clone();
			for (ike = 0; ike < _bitmaps.length; ike++) {
				bmp = _bitmaps[ike];
				pt = _positions[ike];
				temp.x -= pt.x;
				temp.y -= pt.y;
				bmp.fillRect(temp, color);
				temp.x += pt.x;
				temp.y += pt.y;
			}
			
			dirtyPNG = true;
		}
		
		public function get rect():Rectangle {
			return new Rectangle(0, 0, _width, _height);
		}

		public function getPixel(x:Number, y:Number):uint {
			if (_bitmaps.length == 1) {
				return _bitmaps[0].getPixel(x, y);
			}
			
			for (ike = 0; ike < _bitmaps.length; ike++) {
				bmp = _bitmaps[ike];
				pt = _positions[ike];
				if (x >= pt.x && x < pt.x + bmp.width && y >= pt.y && y < pt.y + bmp.height) {
					return bmp.getPixel(x - pt.x, y - pt.y);
				}
			}
			return 0;
		}

		public function setPixel(x:Number, y:Number, color:uint):void {
			if (_bitmaps.length == 1) {
				_bitmaps[0].setPixel(x, y, color);
				return;
			}
			
			for (ike = 0; ike < _bitmaps.length; ike++) {
				bmp = _bitmaps[ike];
				pt = _positions[ike];
				if (x >= pt.x && x < pt.x + bmp.width && y >= pt.y && y < pt.y + bmp.height) {
					bmp.setPixel(FastMath.round(x - pt.x), FastMath.round(y - pt.y), color);
				}
			}
			
			dirtyPNG = true;
		}

		public function getPixel32(x:Number, y:Number):uint {
			if (_bitmaps.length == 1) {
				return _bitmaps[0].getPixel32(x, y);
			}
			
			for (ike = 0; ike < _bitmaps.length; ike++) {
				bmp = _bitmaps[ike];
				pt = _positions[ike];
				if (x >= pt.x && x < pt.x + bmp.width && y >= pt.y && y < pt.y + bmp.height) {
					return bmp.getPixel32(x - pt.x, y - pt.y);
				}
			}
			return 0;
		}

		public function setPixel32(x:Number, y:Number, color:uint):void {
			if (_bitmaps.length == 1) {
				_bitmaps[0].setPixel32(x, y, color);
				return;
			}
			
			for (ike = 0; ike < _bitmaps.length; ike++) {
				bmp = _bitmaps[ike];
				pt = _positions[ike];
				if (x >= pt.x && x < pt.x + bmp.width && y >= pt.y && y < pt.y + bmp.height) {
					bmp.setPixel32(x - pt.x, y - pt.y, color);
				}
			}
			
			dirtyPNG = true;
		}
		
		public function lock():void {
			for (ike = 0; ike < _bitmaps.length; ike++) {
				bmp = _bitmaps[ike].lock();
			}
		}

		public function unlock():void {
			for (ike = 0; ike < _bitmaps.length; ike++) {
				_bitmaps[ike].unlock();
			}
		}
		
		public function get topLeftSegment():BitmapData {
			return _bitmaps[0];
		}
		
		public function get png():ByteArray {
			if (dirtyPNG) {
				dirtyPNG = false;
				_png = PNGEncoder.encode(null, _width, _height, _transparent, _transparent ? getPixel32 : getPixel);
			}
			return _png;
		}
		
		public function clone():BAMF {
			return new BAMF(_width, _height, _transparent, 0x0, this);
		}
		
		public function copyPixels(source:BAMF, sourceRect:Rectangle = null, destPoint:Point = null):void {
			sourceRect ||= source.rect;
			destPoint ||= ORIGIN;
			
			if (source._bitmaps.length == 1 && _bitmaps.length == 1) {
				_bitmaps[0].copyPixels(source._bitmaps[0], sourceRect, destPoint);
				return;
			}
			
			// NOT DONE YET
			// I'd use Rectangles and Points to figure this out- 
			// they've got useful functions- but they're expensive,
			// and copyPixels is called often.
		}
		
		// I think this works...?
		public function drawTo(graphicsObject:Graphics, rect:Rectangle):void {
			graphicsObject.clear();
			var temp:Matrix = new Matrix();
			var right:Number, bottom:Number;
			for (ike = 0; ike < _bitmaps.length; ike++) {
				rect.x -= _positions[ike].x; rect.y -= _positions[ike].y;
				temp.tx = rect.x; temp.ty = rect.y;
				right  = FastMath.min(_bitmaps[ik].width,  rect.right)  - rect.x;
				bottom = FastMath.min(_bitmaps[ik].height, rect.bottom) - rect.y;
				
				graphicsObject.beginBitmapFill(_bitmaps[ike], temp);
				graphicsObject.drawRect(rect.x, rect.y, right, bottom);
				graphicsObject.endFill();
				
				rect.x += _positions[ike].x; rect.y += _positions[ike].y;
			}
		}
	}
}