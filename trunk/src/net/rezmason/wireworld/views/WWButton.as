/**
* Wireworld Player by Jeremy Sachs. June 22, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/

package net.rezmason.wireworld.views {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;

	internal final class WWButton extends WWElement {
		
		private static const CT_TABLE:Object = {};
		
		private var _type:String;
		private var _setID:String;
		private var _down:Boolean = false;
		private var _backCT:ColorTransform, _frontCT:ColorTransform;
		
		private var tapped:Boolean = false;
		
		public function WWButton(__name:String, __content:* = null, 
				__height:Number = NaN, __capStyle:String = null, __type:String = null, __setID:String = null):void {
			
			if (!CT_TABLE[ButtonType.NORMAL]) initTable();
			
			_type = __type || ButtonType.NORMAL;
			if (_type == ButtonType.IN_A_SET) _setID = __setID || "unnamed";
			
			addEventListener(MouseEvent.ROLL_OVER, updateAppearance);
			addEventListener(MouseEvent.ROLL_OUT, updateAppearance);
			addEventListener(MouseEvent.MOUSE_DOWN, updateAppearance);
			addEventListener(MouseEvent.MOUSE_UP, updateAppearance);
			
			useHandCursor = buttonMode = true;
			
			super(__name, __content, 0, __height, __capStyle);
		}
		
		public function get down():Boolean { return _down; }
		public function set down(value:Boolean):void {
			
		}
		
		private function updateAppearance(event:Event):void {
			if (event.type == MouseEvent.MOUSE_DOWN) tapped = true;
			else if (event.type == MouseEvent.MOUSE_UP) tapped = false;
			
			var cts:Object = CT_TABLE[event.type][_type][tapped]; 
			_backCT = cts.back;
			_frontCT = cts.front;
		}
		
		override protected function redraw():void {
			super.redraw();
			updateCTs();
		}
		
		private function updateCTs():void {
			backing.transform.colorTransform = _backCT;
			if (contentDO) contentDO.transform.colorTransform = _frontCT;
		}
		
		private function initTable():void {
			var normalCTs:Object = {};
			CT_TABLE[ButtonType.NORMAL] = normalCTs;
			
			
			var toggleableCTs:Object = {};
			CT_TABLE[ButtonType.TOGGLABLE] = toggleableCTs;
			
			var inASetCTs:Object = {};
			CT_TABLE[ButtonType.IN_A_SET] = inASetCTs;
		}
	}
}