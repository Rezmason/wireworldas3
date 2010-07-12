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

	internal class WWButton extends WWElement {
		
		private var _type:String;
		private var _setID:String;
		private var _down:Boolean = false;
		private var _backCT:ColorTransform, _frontCT:ColorTransform;
		private var _option:*;
		
		private static const BUTTON_SETS:Object = {};
		
		private var tapped:int = 0, hovering:Boolean = false;
		
		public function WWButton(__label:String, __content:* = null, 
				__height:Number = NaN, __capStyle:String = null, __type:String = null, __setID:String = null, __option:* = null):void {
			
			addEventListener(MouseEvent.CLICK, click);
			
			useHandCursor = buttonMode = true;
			mouseChildren = false;
			
			_type = __type || ButtonType.NORMAL;
			if (_type != ButtonType.IN_A_DIALOG) {
				addEventListener(MouseEvent.ROLL_OVER, updateAppearance);
				addEventListener(MouseEvent.ROLL_OUT, updateAppearance);
				addEventListener(MouseEvent.MOUSE_DOWN, updateAppearance);
				addEventListener(MouseEvent.MOUSE_UP, updateAppearance);
				_backCT = WWGUIPalette.BACK_MED_CT;
				_frontCT = WWGUIPalette.FRONT_CT;
			} else {
				_backCT = WWGUIPalette.BACK_DARKEST_CT;
				_frontCT = WWGUIPalette.FRONT_LIGHTEST_CT;
			}
			
			super(__label, __content, 0, __height, __capStyle);
			
			if (_type == ButtonType.CONTINUOUS) {
				addEventListener(MouseEvent.MOUSE_DOWN, pressContinuous);
				addEventListener(MouseEvent.ROLL_OVER, pressContinuous);
				addEventListener(MouseEvent.ROLL_OUT, releaseContinuous);
			} else if (_type == ButtonType.IN_A_SET) {
				_setID = __setID || "unnamed";
				_option = __option;
				if (BUTTON_SETS[_setID]) {
					BUTTON_SETS[_setID].push(this);
				} else {
					BUTTON_SETS[_setID] = [this];
					click();
				}
			}
		}
		
		public function get down():Boolean { return _down; }
		public function set down(value:Boolean):void {
			if (value && (_type != ButtonType.TOGGLABLE || _down != value)) click();
		}
		
		public function click(event:Event = null):void {
			var arr:Array = null;
			switch (_type) {
				case ButtonType.NORMAL:
				case ButtonType.IN_A_DIALOG:
				break;
				case ButtonType.CONTINUOUS:
				_down = false;
				arr = [_down];
				break;
				case ButtonType.TOGGLABLE:
				transform.colorTransform = _down ? WWGUIPalette.PLAIN_CT : WWGUIPalette.TOGGLED_CT; 
				_down = !_down;
				arr = [_down];
				break;
				case ButtonType.IN_A_SET:
				var bSet:Array = BUTTON_SETS[_setID];
				for (var ike:int = 0; ike < bSet.length; ike++) {
					bSet[ike].transform.colorTransform = WWGUIPalette.PLAIN_CT;
					bSet[ike].mouseEnabled = true;
					bSet[ike]._down = false;
				}
				transform.colorTransform = WWGUIPalette.INVERTED_CT;
				mouseEnabled = false;
				_down = true;
				arr = [_setID, _option];
				break;
			}
			if (_addParams) { 
				arr = _params.concat(arr);
			} else {
				arr = _params;
			}
			if (_trigger != null) _trigger.apply(null, arr);
		}
		
		private function pressContinuous(event:Event = null):void {
			if (tapped || event.type == MouseEvent.MOUSE_DOWN) {
				_down = true;
				if (_trigger != null) _trigger.apply(null, _addParams ? _params.concat([_down]) : _params);
			}
		}
		
		private function releaseContinuous(event:Event = null):void {
			if (tapped) {
				_down = false;
				if (_trigger != null) _trigger.apply(null, _addParams ? _params.concat([_down]) : _params);
			}
		}
		
		private function updateAppearance(event:Event = null, eventType:String = null):void {
			eventType ||= event.type || MouseEvent.MOUSE_UP; 
			switch (event.type) {
				case MouseEvent.MOUSE_DOWN:
				tapped = 1;
				_backCT = WWGUIPalette.BACK_DARK_CT;
				break;
				case MouseEvent.MOUSE_UP:
				tapped = 0;
				_backCT = hovering ? WWGUIPalette.BACK_LIGHT_CT : WWGUIPalette.BACK_MED_CT;
				break;
				case MouseEvent.ROLL_OVER:
				hovering = true;
				_backCT = tapped ? WWGUIPalette.BACK_DARK_CT : WWGUIPalette.BACK_LIGHT_CT;
				break;
				case MouseEvent.ROLL_OUT:
				hovering = false;
				_backCT = tapped ? WWGUIPalette.BACK_LIGHT_CT : WWGUIPalette.BACK_MED_CT;
				break;
			}
			updateCTs();
		}
		
		override protected function redraw():void {
			super.redraw();
			updateCTs();
		}
		
		private function updateCTs():void {
			backing.transform.colorTransform = _backCT;
			if (_content) _content.transform.colorTransform = _frontCT;
		}
	}
}