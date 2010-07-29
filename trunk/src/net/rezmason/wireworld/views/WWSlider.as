/**
* Wireworld Player by Jeremy Sachs. July 25, 2010
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
	import apparat.math.FastMath;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	// A slider, or scroll bar. Depends on how it's used.
	// Supports four types of manipulation: manually draging the thumb,
	// grabbing the track, arbitrarily setting its value (0 to 1),
	// and telling it to scroll by some amount over time.
	
	internal class WWSlider extends WWElement {
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		public static const ZIP_STEP:Number = 5;
		
		private var dragging:Boolean = false, zipping:Boolean = false;
		private var _value:Number = 0;
		private var _thumb:Sprite, grip:Number, _thumbRatio:Number;
		private var minX:Number, maxX:Number, thumbHeight:Number, thumbWidth:Number;
		private var zipTimer:Timer = new Timer(10);
		private var zipAmount:Number;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function WWSlider(__label:String, __width:Number = 100, __height:Number = 10, __thumbRatio:Number = 0):void {
			_thumb = new Sprite();
			_thumb.transform.colorTransform = WWGUIPalette.FRONT_CT;
			_thumb.useHandCursor = _thumb.buttonMode = true;
			
			thumbHeight = __height - MARGIN * 2;
			
			super(__label, null, __width, __height, "[]");
			cacheAsBitmap = false;
			_thumb.cacheAsBitmap = true;
			this.backing.cacheAsBitmap = true;
			
			thumbRatio = isNaN(__thumbRatio) ? 0 : Math.max(0, Math.min(1, __thumbRatio));
			backing.transform.colorTransform = WWGUIPalette.BACK_DARK_CT;
			
			_thumb.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
			addEventListener(MouseEvent.MOUSE_UP, endDrag);
			
			addEventListener(MouseEvent.MOUSE_DOWN, beginZip);
			addEventListener(MouseEvent.MOUSE_UP, endZip);
			zipTimer.addEventListener(TimerEvent.TIMER, changeZip);
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		// The value is always between 0 (left end) and 1 (right end)
		public function get value():Number { return _value; }
		public function set value(val:Number):void {
			if (!isNaN(val)) {
				_value = FastMath.min(FastMath.max(0, val), 1);
			}
			_thumb.x = minX + (maxX - minX) * _value;
			if (_trigger != null) _trigger.apply(null, _addParams ? _params.concat([_value]) : _params);
		}
		
		// The length of the thumb, relative to the length of the track.
		public function get thumbRatio():Number { return _thumbRatio; }
		public function set thumbRatio(val:Number):void {
			if (!isNaN(val)) {
				_thumbRatio = FastMath.min(FastMath.max(0, val), 1);
				thumbWidth = Math.max(thumbHeight, (_width - 2 * MARGIN) * _thumbRatio);
				minX = MARGIN;
				maxX = _width - MARGIN - thumbWidth;
				trace(minX, maxX);
				_thumb.x = minX + (maxX - minX) * _value;
				redraw();
			}
		}
		
		// When a WWSlider is paired with other buttons, this function can be bound to them
		// to cause the slider to steadily "zip" in the given direction.
		public function startZip(amount:Number):void {
			if (!isNaN(amount)) {
				zipAmount = amount;
				beginZip();
			}
		}
		
		public function stopZip():void {
			endZip();
		}
		
		//---------------------------------------
		// PRIVATE METHODS
		//---------------------------------------
		
		override protected function redraw():void {
			super.redraw();
			
			if (!thumbWidth || !thumbHeight) return;
			
			_thumb.graphics.beginFill(0x0);
			_thumb.graphics.drawRoundRect(0, -thumbHeight * 0.5, thumbWidth, thumbHeight, thumbHeight * 0.25, thumbHeight * 0.25);
			_thumb.graphics.endFill();
			value = value;
			addChild(_thumb);
			
			value = value;
		}
		
		// Methods related to dragging the thumb
		
		private function beginDrag(event:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, updateDrag, false, 0, true);
			dragging = true;
			grip = _thumb.x - mouseX;
		}
		
		private function updateDrag(event:MouseEvent = null):void {
			if (!dragging) return;
			_thumb.x = FastMath.min(maxX, FastMath.max(minX, mouseX + grip));
			_value = (_thumb.x - minX) / (maxX - minX);
			if (_trigger != null) _trigger.apply(null, _addParams ? _params.concat([_value]) : _params);
		}
		
		private function endDrag(event:Event):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, updateDrag);
			updateDrag();
			dragging = false;
		}
		
		// Methods related to touching the track or zipping.
		
		private function beginZip(event:Event = null):void {
			if (event && event.target == _thumb) return;
			zipping = true;
			zipTimer.start();
		}
		
		private function changeZip(event:Event):void { updateZip(); }
		
		private function updateZip():void {
			if (!zipping) return;
			if (zipAmount) {
				_thumb.x += zipAmount;
			} else {
				if (FastMath.abs(mouseX - (_thumb.x + thumbWidth * 0.5)) < ZIP_STEP) {
					_thumb.x = mouseX - thumbWidth * 0.5;
				} else {
					_thumb.x += (mouseX < _thumb.x + thumbWidth * 0.5) ? -ZIP_STEP : ZIP_STEP;
				}
			}
			_thumb.x = FastMath.min(maxX, FastMath.max(minX, _thumb.x));
			_value = (_thumb.x - minX) / (maxX - minX);
			if (_trigger != null) _trigger.apply(null, _addParams ? _params.concat([_value]) : _params);
		}
		
		private function endZip(event:Event = null):void {
			zipTimer.stop();
			updateZip();
			zipping = false;
			zipAmount = 0;
		}
	}
}