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
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;

	internal class WWElement extends Sprite {
		
		protected var _target:Object, _bindValue:*, _trigger:Function;
		
		protected var _width:Number, _specifiedWidth:Number, _height:Number;
		protected var leftCap:Boolean, rightCap:Boolean;
		protected var _content:*;
		
		protected var backing:Shape = new Shape();
		protected var contentDO:DisplayObject;
		
		public function WWElement(__name:String, __content:* = null, __width:Number = NaN, __height:Number = NaN, __capStyle:String = null):void {
			super();
			if (__name) name = __name;
			
			_content = __content;
			_height = __height;
			_specifiedWidth = __width;
			__capStyle ||= "()";
			leftCap = __capStyle.charAt(0) == "(";
			rightCap = __capStyle.charAt(1) == ")";
			if (__capStyle == "--") backing.visible = false;
			redraw();
		}
		
		override public function set width(value:Number):void {
			_specifiedWidth = FastMath.max(0, value);
			redraw();
		}
		
		override public function set height(value:Number):void {
			_height = FastMath.max(0, value);
			redraw();
		}
		
		public function get content():* { return _content; }
		public function set content(value:*):void {
			_content = value || null;
			contentDO = null;
			redraw();
		}
		
		public function bind(target:Object, bindValue:String):void {
			_target = target, _bindValue = bindValue;
		}
		
		public function trigger(func:Function):void {
			_trigger = func;
		}
		
		public function click():void {
			
		}
		
		protected function redraw():void {
			while (numChildren) removeChildAt(0);
			
			var bounds:Rectangle;
			
			// I'm using hard coded values, I know. Bite me. 
			// This class isn't general purpose and you're not my boss.
			
			if (!contentDO) {
				if (_content is String) {
					var textField:WWTextField = new WWTextField("text", -1);
					textField.text = _content;
					contentDO = textField;
				} else if (_content is DisplayObject) {
					contentDO = _content;
					contentDO.transform.matrix = new Matrix();
					contentDO.scaleX = contentDO.scaleY = 0.35;
					bounds = contentDO.getBounds(contentDO);
				}
			}
			
			if (contentDO) {
				_width = contentDO.width + _height * 0.5;
				if (_width < _height * 1.5) _width = _height;
				contentDO.transform.colorTransform = WWGUIPalette.BACK_MED_CT;
				addChild(contentDO);
			} else {
				_width = _specifiedWidth;
			}
			
			if (backing.visible) {
				backing.graphics.clear();
				var startX:Number = 0;
				var endX:Number = _width;
				if (leftCap) {
					backing.graphics.beginFill(0x0);
					backing.graphics.drawCircle(startX + _height * 0.5, 0, _height * 0.5);
					backing.graphics.endFill();
					startX += _height * 0.5;
					if (!rightCap) endX += _height * 0.25; // making it wider
				}
				
				if (rightCap) {
					if (!leftCap) endX += _height * 0.25; // making it wider
					backing.graphics.beginFill(0x0);
					backing.graphics.drawCircle(endX - _height * 0.5, 0, _height * 0.5);
					backing.graphics.endFill();
					endX -= _height * 0.5;
				}
				
				backing.graphics.beginFill(0x0);
				backing.graphics.drawRect(startX, -_height * 0.5, endX - startX, _height);
				backing.graphics.endFill();
				
				if (contentDO) {
					contentDO.x = (startX + endX  - bounds.left - bounds.right ) * 0.5;
					if (leftCap && !rightCap) contentDO.x -= _height * 0.25;
					else if (rightCap && !leftCap) contentDO.x += _height * 0.25;
					contentDO.y = -(bounds.top + bounds.bottom) * 0.5;
				}
			} else {
				_width = contentDO ? contentDO.width : _specifiedWidth;
			}
			
			addChildAt(backing, 0);
		}
	}
}