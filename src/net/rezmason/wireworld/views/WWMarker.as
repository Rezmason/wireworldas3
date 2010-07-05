/**
* Wireworld Player by Jeremy Sachs. June 22, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/

package net.rezmason.wireworld.views {
	
	import apparat.math.FastMath;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;

	internal class WWMarker extends WWElement {
		
		protected var _width:Number, _height:Number;
		protected var _content:*;
		
		private static const MARGIN:int = 1;
		
		protected var backing:Shape = new Shape();
		protected var contentDO:DisplayObject;
		
		public function WWMarker(__name:String, __content:* = null, __height:Number = NaN):void {
			super(__name);
			
			_content = __content;
			_height = __height;
			backing.visible = false;
			redraw();
		}
		
		override public function set width(value:Number):void {}
		
		override public function set height(value:Number):void {
			_height = Math.max(0, value);
			redraw();
		}
		
		public function get content():* { return _content; }
		public function set content(value:*):void {
			_content = value || null;
			redraw();
		}
		
		protected function redraw():void {
			while (numChildren) removeChildAt(0);
			
			var bounds:Rectangle;
			
			if (_content is String) {
				var textField:WWTextField = new WWTextField("text", -1);
				textField.text = _content;
				contentDO = textField;
			} else if (_content is DisplayObject) {
				contentDO = _content;
				contentDO.transform.matrix = new Matrix();
				contentDO.scaleX = contentDO.scaleY = 0.35; // Hard coded, I know. Bite me.
				bounds = contentDO.getBounds(contentDO);
			}
			
			if (backing.visible) {
				_width = contentDO.width + 2 * MARGIN + _height * 0.5;
				if (_width < _height * 1.5) _width = _height;
				
				backing.graphics.clear();
				backing.graphics.beginFill(0x0);
				backing.graphics.drawRoundRect(0, -_height * 0.5, _width, _height, _height, _height);
				backing.graphics.endFill();
			} else {
				_width = contentDO.width;
			}
			
			contentDO.x = (_width  - bounds.left - bounds.right ) * 0.5;
			contentDO.y = -(bounds.top + bounds.bottom) * 0.5;
			contentDO.transform.colorTransform = WWGUIPalette.BACK_MED_CT;
			
			addChild(backing);
			addChild(contentDO);
		}
	}
}