/**
* Wireworld Player by Jeremy Sachs. June 22, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld.views {
	
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	internal class WWTextField extends WWElement {
		
		private var _text:String = "", _labelText:String;
		private var field:TextField, format:TextFormat;
		private var editing:Boolean = false;
		
		public function WWTextField(__label:String, __width:Number = 100, __height:Number = 10, __maxChars:int = -1, __capStyle:String = null, 
				__acceptsInput:Boolean = false, __labelText:String = ""):void {
			
			field = new TextField();
			format = field.defaultTextFormat;
			
			super(__label, null, __width, __height, __capStyle);
			
			if (__maxChars != -1) field.maxChars = __maxChars;
			_labelText = __labelText;
			if (_labelText.length > field.maxChars) _labelText = _labelText.substr(0, field.maxChars - 3) + "...";
			field.text = _labelText;
			
			if (leftCap) {
				format.align = rightCap ? TextFormatAlign.CENTER : TextFormatAlign.RIGHT;
			} else {
				format.align = TextFormatAlign.LEFT;
			}
			
			if (__acceptsInput) {
				backing.transform.colorTransform = WWGUIPalette.INPUT_TEXT_BACK_CT;
				field.type = TextFieldType.INPUT;
				format.color = WWGUIPalette.DEFAULT_TEXT;
				addEventListener(MouseEvent.CLICK, beginEdit);
				addEventListener(TextEvent.TEXT_INPUT, enterResponder);
			} else {
				backing.transform.colorTransform = WWGUIPalette.PLAIN_TEXT_BACK_CT;
				field.type = TextFieldType.DYNAMIC;
				field.selectable = false;
				field.mouseEnabled = false;
				format.bold = true;
				if (backing.visible) {
					format.color = WWGUIPalette.NAKED_TEXT;
				} else {
					format.color = WWGUIPalette.PLAIN_TEXT;
				}
				
			}
			
			format.font = FontSet.getFontName("typewriter");
			format.size = _height * 0.65;
			
			field.defaultTextFormat = format;
			if (field.text) field.setTextFormat(format, 0, field.text.length);
			field.embedFonts = (format.font.charAt(0) != "_");
		}
		
		public function get text():String { return _text; }
		public function set text(value:String):void {
			_text = value;
			if (_text.length) {
				if (_text.length > field.maxChars) _text = _text.substr(0, field.maxChars - 3) + "...";
				field.text = _text;
				if (field.type == TextFieldType.INPUT) format.color = WWGUIPalette.EDITING_TEXT;
			} else {
				field.text = _labelText;
				if (field.type == TextFieldType.INPUT) format.color = WWGUIPalette.DEFAULT_TEXT;
			}
			
			field.defaultTextFormat = format;
			field.setTextFormat(format, 0, field.text.length);
		}
		
		public function grabFocus():void {
			/*
			var sprite:* = (field.getChildAt(1) as Sprite);
			var button:* = sprite.getChildAt(1);
			var line:* = sprite.getChildAt(1);
			
			stage.focus = line;
			button.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
			sprite.dispatchEvent(new FocusEvent(FocusEvent.FOCUS_IN));
			*/
		}
		
		override protected function redraw():void {
			super.redraw();
			addChild(field);
			
			field.y = -_height * 0.5;
			field.x = startX + MARGIN;
			field.width = endX - startX - MARGIN;
			field.height = _height;
		}
		
		private function beginEdit(event:Event):void {
			if (editing) return;
			editing = true;
			stage.addEventListener(MouseEvent.MOUSE_DOWN, endEdit, false, 0, true);
			field.text = _text;
			format.color = WWGUIPalette.EDITING_TEXT;
			field.defaultTextFormat = format;
			if (field.text) field.setTextFormat(format, 0, field.text.length);
			field.setSelection(field.text.length, field.text.length);
		}
		
		private function endEdit(event:Event = null):void {
			if (!editing) return;
			editing = false;
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, endEdit);
			text = field.text.replace(/[\r\n]/g, "");
			field.setSelection(-1, -1);
			format.color = WWGUIPalette.DEFAULT_TEXT;
			field.defaultTextFormat = format;
			if (field.text) field.setTextFormat(format, 0, field.text.length);
			
			var arr:Array = _addParams ? _params.concat([_text]) : _params;
			if (_trigger != null) _trigger.apply(null, arr);
		}
		
		private function enterResponder(event:TextEvent):void {
			if (event.text == "\n" || event.text == "\r") {
				endEdit();
				stage.focus = stage;
			}
		}
	}
}