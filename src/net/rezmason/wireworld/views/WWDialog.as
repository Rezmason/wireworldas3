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
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.engine.TextLine;
	
	import net.rezmason.gui.Toolbar;

	internal class WWDialog extends Sprite {
		
		private static const CONTENT_MARGIN:Number = 10;
		
		internal static var css:String;
		
		private var backing:Shape;
		
		private var _width:Number;
		private var _title:String, _subtitle:String;
		private var _toolbar:Toolbar;
		private var isBubble:Boolean = false;
		private var _pole:BarberPole;
		private var _content:Array = [];
		private var _speechX:Number = 0, _speechY:Number = 0;
		private var _margin:Number;
		private var bottom:Number;
		
		public function WWDialog(__width:Number = NaN, __title:String = null, __subtitle:String = null, 
				__speechX:Number = NaN, __speechY:Number = NaN, __margin:Number = 20):void {
			
			super();
			
			_margin = isNaN(__margin) ? 320 : __margin;
			_width = isNaN(__width) ? 320 : __width;
			_title = __title;
			_subtitle = __subtitle;
			if (!isNaN(__speechX + __speechY)) {
				isBubble = true;
				_speechX = isNaN(__speechX) ? 0 : __speechX;
				_speechY = isNaN(__speechY) ? 0 : __speechY;
			}
			
			backing = new Shape();
			
			_toolbar = new Toolbar(_width, 18, 0xFFFFFF, 1);
			_toolbar.leftMargin = _toolbar.rightMargin = 0;
			_toolbar.visible = true;
			
			_pole = new BarberPole(_width, 18, 0x222222);
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
		
		public function get speechX():Number { return _speechX; }
		public function get speechY():Number { return _speechY; }
		
		public function addGUIElementsToToolbar(hAlign:Object = null, kiss:Boolean = false, ...elements):void {
			_toolbar.addGUIElements.apply(null, [hAlign, kiss].concat(elements));
		}
		
		public function addContent(item:DisplayObject, makeOpaque:Boolean = true, link:String = ""):void {
			if (item.parent) item.parent.removeChild(item);
			
			var index:int = _content.indexOf(item);
			if (index != -1) _content.splice(index, 1);
			_content.push(item);
			
			if (makeOpaque) item.opaqueBackground = 0xFFFFFF;
			
			if (item is Sprite && link && link.length) {
				linkTo(item as Sprite, link);
			}
			
			redraw();
		}
		
		public function addSpacer(__height:Number = NaN):void {
			if (isNaN(height) || __height < 0) return;
			var spacer:Shape = new Shape();
			spacer.graphics.beginFill(0xFFFFFF);
			spacer.graphics.drawRect(0, 0, 1, __height);
			spacer.graphics.endFill();
			addContent(spacer);
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
			box.width = _width;
			
			if (!isNaN(__height)) {
				box.height = __height;
			} else {
				box.height = box.textHeight + 12;
			}
			
			if (box.height >= box.textHeight) {
				addContent(box);
			} else {
				
				var rect:Rectangle = box.getBounds(box);
				var slider:WWSlider = new WWDialogSlider("", box.height, 18, box.height / box.textHeight);
				var scrollContainer:Sprite = new Sprite();
			
				box.addEventListener(MouseEvent.MOUSE_WHEEL, scrollByScroll);
				
				rect.height = box.height;
				
				slider.rotation = 90;
				slider.x = box.width - 9;
				slider.bind(scroll, true, scrollContainer);
				
				box.width -= 36;
				box.height = box.textHeight + 12;
				box.scrollRect = rect;
				
				scrollContainer.addChild(box);
				scrollContainer.addChild(slider);
				scrollContainer.name = scrollContainer.name.replace("instance", "html");
				addContent(scrollContainer);
			}
		}
		
		private function scroll(target:Sprite, amount:Number, updateSlider:Boolean = false, increment:Boolean = false):void {
			var slider:WWSlider = target.getChildAt(1) as WWSlider;
			
			if (increment) amount += slider.value;
			
			if (updateSlider) {
				slider.value = amount;
			} else {
				
				var box:TextField = target.getChildAt(0) as TextField;
				var rect:Rectangle = box.scrollRect;
				
				rect.y = (box.textHeight + 12 - rect.height) * amount;
				box.scrollRect = rect;
			}
		}
		
		private function scrollByScroll(event:MouseEvent):void {
			var target:Sprite = (event.currentTarget as TextField).parent as Sprite;
			scroll(target, event.delta * -0.005, true, true);
		}
		
		private function resetHTMLBoxes(event:Event):void {
			if (event.target != this) return;
			for (var i:int = 0; i < _content.length; i++) {
				var htmlBox:Sprite = _content[i] as Sprite;
				if (htmlBox && htmlBox.name.indexOf("html") == 0) {
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
			
			bottom = 0;
			
			if (_title && _title.length) attach(TextFactory.generate(_title, "_sans", 36, true));
			if (_subtitle && _subtitle.length) attach(TextFactory.generate(_subtitle, "_sans", 14));
			for (var i:int = 0; i < _content.length; i++) attach(_content[i]);
			
			_toolbar.width = _width;
			attach(_toolbar);
			
			var rect:Rectangle = getBounds(this);
			var topRect:Rectangle = getChildAt(1).getBounds(this);
			var bottomRect:Rectangle = getChildAt(numChildren - 1).getBounds(this);
			
			rect.top = topRect.top;
			rect.bottom = bottomRect.bottom;
			
			_toolbar.width = rect.width;
			
			x = (rect.left + rect.right) * -0.5;
			y = (rect.top + rect.bottom) * -0.5;
			
			rect.inflate(_margin, _margin);
			
			addChild(_pole);
			_pole.x = rect.left;
			_pole.y = _toolbar.y;
			_pole.width = rect.width;
			_pole.height = rect.bottom - _margin - _pole.y;
			
			backing.graphics.beginFill(0xFFFFFF);
			backing.graphics.drawRoundRect(rect.x, rect.y, rect.width, rect.height, _margin * 2, _margin * 2);
			backing.graphics.endFill();
		}
		
		private function attach(item:DisplayObject):void {
			
			var rect:Rectangle = item.getBounds(item);
			
			item.x = -rect.left;
			item.y = -rect.top + bottom;
			
			if (item.name.indexOf("html") == 0) {
				var box:TextField = (item as Sprite).getChildAt(0) as TextField;
				if (box.scrollRect) {
					bottom += (item as Sprite).getChildAt(0).scrollRect.height;
				} else {
					bottom += box.height;
				}
			} else {
				bottom += item.height;
			}
			
			bottom += CONTENT_MARGIN;
			
			addChild(item);
		}
	}
}