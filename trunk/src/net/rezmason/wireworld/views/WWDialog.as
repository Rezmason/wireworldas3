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
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.engine.TextLine;
	
	import net.rezmason.gui.Toolbar;

	internal class WWDialog extends Sprite {
		
		private static const BUBBLE_MARGIN:Number = 8, BOX_MARGIN:Number = 20, CONTENT_MARGIN:Number = 5;
		
		internal static var css:String;
		
		private var backing:Shape;
		private var gradient:Matrix;
		
		private var _width:Number;
		private var _title:String, _subtitle:String;
		private var _toolbar:Toolbar;
		private var isBubble:Boolean = false;
		private var centerX:Number = 0, centerY:Number = 0;
		private var _margin:Number;
		private var _pole:BarberPole;
		private var _content:Array = [];
		
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
			
			_toolbar = new Toolbar(_width, 18, 0x00FF00, 1);
			_toolbar.leftMargin = _toolbar.rightMargin = _margin;
			_toolbar.visible = true;
			
			_pole = new BarberPole(_width, 18, 0x00FF00);
			_pole.visible = false;
			
			redraw();
			
			addEventListener(Event.ADDED_TO_STAGE, resetHTMLBoxes);
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
			if (item.parent) item.parent.removeChild(item);
			
			var index:int = _content.indexOf(item);
			if (index != -1) _content.splice(index, 1);
			_content.push(item);
			
			redraw();
		}
		
		public function addHTML(input:String, __height:Number = NaN):void {
			var box:TextField = new TextField();
			box.multiline = true;
			box.wordWrap = true;
			box.selectable = false;
			box.defaultTextFormat = new TextFormat("_sans", 12, 0x222222);
			
			var sheet:StyleSheet = new StyleSheet();
			sheet.parseCSS(css);
			box.styleSheet = sheet;
			box.htmlText = input.replace(/[\n\t]/g, "").replace(/<br\/>/g, "<br>");
			box.width = _width - 2 * _margin;
			
			if (!isNaN(__height)) {
				box.height = __height;
			} else {
				box.height = 2000;
				box.height = box.textHeight + 12;
			}
			
			if (box.height >= box.textHeight) {
				addContent(box);
			} else {
				
				var rect:Rectangle = box.getBounds(box);
				var slider:WWSlider = new WWSlider("", box.height, 18, box.height / box.textHeight);
				var scrollContainer:Sprite = new Sprite();
				
				rect.height = box.height;
				
				box.width -= 24;
				box.height = 2000;
				box.height = box.textHeight + 12;
				box.scrollRect = rect;
				
				slider.bind(scroll, true, scrollContainer);
				
				slider.rotation = 90;
				slider.x = box.width + 9;
				
				scrollContainer.addChild(box);
				scrollContainer.addChild(slider);
				addContent(scrollContainer);
			}
		}
		
		private function scroll(target:Sprite, amount:Number, updateSlider:Boolean = false):void {
			var slider:WWSlider = target.getChildAt(1) as WWSlider;
			
			if (updateSlider) {
				slider.value = amount;
			} else {
				
				var box:TextField = target.getChildAt(0) as TextField;
				var rect:Rectangle = box.scrollRect;
				
				rect.y = (box.textHeight + 12 - rect.height) * amount;
				box.scrollRect = rect;
			}
		}
		
		private function resetHTMLBoxes(event:Event):void {
			if (event.target != this) return;
			for (var i:int = 0; i < _content.length; i++) {
				var htmlBox:Sprite = _content[i] as Sprite;
				if (htmlBox && htmlBox.getChildAt(1) is WWSlider) {
					scroll(htmlBox, 0, true);
				}
			}
		}
		
		public function clearContents():void {
			_content.length = 0;
			redraw();
		}
		
		private function redraw():void {
			while (numChildren) removeChildAt(0);
			
			backing.graphics.clear();
			addChild(backing);
			
			if (_title && _title.length) attach(TextFactory.generate(_title, "_sans", 36, true));
			if (_subtitle && _subtitle.length) attach(TextFactory.generate(_subtitle, "_sans", 18));
			for (var i:int = 0; i < _content.length; i++) attach(_content[i]);
			
			var rect:Rectangle = getBounds(this);
			
			x = (rect.left + rect.right) * -0.5;
			y = (rect.top + rect.bottom) * -0.5;
			
			rect.inflate(_margin, _margin);
			
			backing.graphics.beginFill(0xFFFFFF);
			backing.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
			backing.graphics.endFill();
		}
		
		private function attach(item:DisplayObject):void {
			item.transform.matrix = new Matrix();
			
			var rect:Rectangle = item.getBounds(item);
			item.x = -rect.x;
			item.y = -rect.y + _content.height;
			
			item.y += height + CONTENT_MARGIN;
			
			if (!(item is TextLine)) item.opaqueBackground = 0xFFFFFF;
			
			addChild(item);
		}
	}
}