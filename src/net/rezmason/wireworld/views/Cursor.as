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
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	// It's a cursor. It's no different from a SimpleButton,
	// except that it has no over state and its x and y
	// are always ints, to help with pixel alignment.
	
	internal final class Cursor extends Sprite {
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private var _down:DisplayObject, _up:DisplayObject;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function Cursor(__upAsset:Class, __downAsset:Class, centerX:int = 0, centerY:int = 0) {
			super();
			
			_up = (new __upAsset) as DisplayObject;
			_down = (new __downAsset) as DisplayObject;
			if (!_up || !_down) throw new Error("The Cursor class must be given a valid down asset and up asset.");
			
			addChild(_down);
			addChild(_up);
			_down.x = centerX - _down.width * 0.5;
			_up.x = centerX - _up.width * 0.5;
			_down.y = centerY - _down.height * 0.5;
			_up.y = centerY - _up.height * 0.5;
			_down.visible = false;
			
			visible = false;
			
			mouseEnabled = mouseChildren = false;
		}
		
		public function get mouseDown():Boolean { return _down.visible; }
		public function set mouseDown(value:Boolean):void {
			_down.visible = value;
			_up.visible = !value;
		}
		
		override public function set x(value:Number):void { super.x = int(value); }
		override public function set y(value:Number):void { super.y = int(value); }
	}
}