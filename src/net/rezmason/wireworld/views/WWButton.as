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

	internal final class WWButton extends WWElement {
		
		private var _type:String;
		private var _setID:String;
		private var _down:Boolean = false;
		
		public function WWButton(__name:String, __content:* = null, 
				__height:Number = NaN, __capStyle:String = null, __type:String = null, __setID:String = null):void {
			
			super(__name, __content, 0, __height, __capStyle);
			
			_type = __type || ButtonType.NORMAL;
			switch (_type) {
				case ButtonType.TOGGLABLE:
				break;
				case ButtonType.IN_A_SET:
				break;
				case ButtonType.NORMAL:
				default:
				break;
			}
			
			if (_type == ButtonType.IN_A_SET) _setID = __setID || "unnamed";
		}
		
		public function get down():Boolean { return _down; }
		public function set down(value:Boolean):void {
			
		}
		
		override protected function redraw():void {
			super.redraw();
			
			backing.transform.colorTransform = WWGUIPalette.BACK_MED_CT;
			contentDO.transform.colorTransform = WWGUIPalette.FRONT_CT;
		}
	}
}