/**
* Wireworld Player by Jeremy Sachs. June 22, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld.views {
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import net.rezmason.gui.Toolbar;

	internal class WWDialog extends Sprite {
		
		private static const BUBBLE_MARGIN:Number = 8, BOX_MARGIN:Number = 20, CONTENT_MARGIN:Number = 5;
		
		private var backing:Shape;
		private var _content:Sprite;
		private var gradient:Matrix;
		private var titleBox:TextField, subtitleBox:TextField;
		
		private var _width:Number;
		private var _title:String, _subtitle:String;
		private var _toolbar:Toolbar;
		private var isBubble:Boolean = false;
		private var centerX:Number = 0, centerY:Number = 0;
		private var _margin:Number;
		private var _pole:BarberPole;
		
		public function WWDialog(__width:Number = NaN, __title:String = null, __subtitle:String = null, 
				__speechX:Number = NaN, __speechY:Number = NaN):void {
			
			_width = isNaN(__width) ? 320 : __width;
			_title = __title;
			_subtitle = __subtitle;
			if (!isNaN(__speechX + __speechY)) {
				isBubble = true;
				centerX = __speechX;
				centerY = __speechY;
			}
			
			_margin = isBubble ? BUBBLE_MARGIN : BOX_MARGIN;;
			
			backing = new Shape();
			
			titleBox = new TextField();
			titleBox.selectable = false;
			titleBox.defaultTextFormat = new TextFormat("_sans", 36, 0xFFFFFF);
			titleBox.autoSize = TextFieldAutoSize.LEFT;
			
			subtitleBox = new TextField();
			subtitleBox.selectable = false;
			subtitleBox.defaultTextFormat = new TextFormat("_sans", 18, 0xFFFFFF);
			subtitleBox.autoSize = TextFieldAutoSize.LEFT;
			
			_content = new Sprite();
			
			_toolbar = new Toolbar(_width, 18, 0x00FF00, 1);
			_toolbar.leftMargin = _toolbar.rightMargin = _margin;
			_toolbar.visible = true;
			
			_pole = new BarberPole(_width, 18, 0x00FF00);
			_pole.visible = false;
			
			redraw();
		}
		
		public function get interactive():Boolean { return _pole.visible; }
		public function set interactive(value:Boolean):void {
			_pole.visible = !value;
			_toolbar.visible = value;
		}
		
		public function get title():String { return _title; }
		public function set title(value:String):void { _title = value; redraw(); }
		
		public function get subtitle():String { return _subtitle; }
		public function set subtitle(value:String):void { _subtitle = value; redraw(); }
		
		public function addGUIElementsToToolbar(hAlign:Object = null, kiss:Boolean = false, ...elements):void {
			_toolbar.addGUIElements.apply(null, [hAlign, kiss].concat(elements));
		}
		
		public function addContent(item:DisplayObject):void {
			item.x = item.y = 0;
			var rect:Rectangle = item.getBounds(item);
			item.x = -rect.x;
			item.y = -rect.y + _content.height;
			if (_content.height > 0) item.y += CONTENT_MARGIN;
			_content.addChild(item);
			redraw();
		}
		
		public function addHTML(input:XML, __height:Number = NaN):void {
			if (!isNaN(__height)) __height = -1;
			var box:TextField = new TextField();
			box.background = true;
			box.backgroundColor = 0xFF0000;
			box.defaultTextFormat = new TextFormat("_sans", 12, 0x222222);
			box.selectable = false;
			box.width = _width - 2 * _margin;
			
			box.height = (__height > 0) ? __height : 2000;
			box.htmlText = input.toXMLString();
			if (__height < 0) box.height = box.textHeight;
			
			addContent(box);
		}
		
		public function clearContents():void {
			while (_content.numChildren) _content.removeChildAt(0);
			redraw();
		}
		
		private function redraw():void {
			while (numChildren) removeChildAt(0);
			
			// draw backing
			// maybe draw backing tail
			
			addChild(backing);
			if (_title && _title.length) addChild(titleBox);
			if (_subtitle && _subtitle.length) addChild(subtitleBox);
			addChild(_content);
			addChild(_toolbar);
			addChild(_pole);
			
			// position everything
		}
	}
}