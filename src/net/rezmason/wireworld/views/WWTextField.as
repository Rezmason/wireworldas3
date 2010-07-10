/**
* Wireworld Player by Jeremy Sachs. June 22, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld.views {
	
	import fl.text.TLFTextField;
	
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.SelectionFormat;
	import flashx.textLayout.formats.VerticalAlign;

	internal class WWTextField extends WWElement {
		
		private static const SEL_FORMAT:SelectionFormat = new SelectionFormat(0x0, 0.2, BlendMode.LAYER, 0x0, 1, BlendMode.LAYER, 300);
		private var _text:String = "", _labelText:String;
		private var field:TLFTextField, format:TextFormat;
		private var editing:Boolean = false;
		
		public function WWTextField(__name:String, __width:Number = 100, __height:Number = 10, __capStyle:String = null, 
				__acceptsInput:Boolean = false, __labelText:String = ""):void {
			
			field = new TLFTextField();
			format = field.defaultTextFormat;
			
			super(__name, null, __width, __height, __capStyle);
			
			_labelText = __labelText;
			field.text = _labelText;
			
			if (leftCap) {
				format.align = rightCap ? TextFormatAlign.CENTER : TextFormatAlign.RIGHT;
			} else {
				format.align = TextFormatAlign.LEFT;
			}
			
			if (__acceptsInput) {
				backing.transform.colorTransform = WWGUIPalette.INPUT_TEXT_BACK_CT;
				field.type = TextFieldType.INPUT;
				field.textFlow.interactionManager = new EditManager();
				field.textFlow.interactionManager.focusedSelectionFormat = SEL_FORMAT;
				format.color = 0x606060;
				addEventListener(MouseEvent.CLICK, beginEdit);
				addEventListener(TextEvent.TEXT_INPUT, enterResponder);
			} else {
				backing.transform.colorTransform = WWGUIPalette.PLAIN_TEXT_BACK_CT;
				field.type = TextFieldType.DYNAMIC;
				field.selectable = false;
				field.mouseChildren = field.mouseEnabled = false;
				if (backing.visible) {
					format.bold = true;
					format.color = 0x202020;
				} else {
					format.color = 0x909090;
				}
				
			}
			
			format.font = "_typewriter";
			format.size = _height * 0.65;
			
			field.verticalAlign = VerticalAlign.MIDDLE;
			field.defaultTextFormat = format;
			field.setTextFormat(format, 0, field.text.length);
		}
		
		public function get text():String { return _text; }
		public function set text(value:String):void {
			_text = value;
			if (_text.length) {
				field.text = _text;
				if (field.type == TextFieldType.INPUT) format.color = 0x0;
			} else {
				field.text = _labelText;
				if (field.type == TextFieldType.INPUT) format.color = 0x606060;
			}
			
			field.defaultTextFormat = format;
			field.setTextFormat(format, 0, field.text.length);
		}
		
		override protected function redraw():void {
			super.redraw();
			addChild(field);
			
			field.y = -_height * 0.5 + MARGIN;
			field.x = startX + MARGIN;
			field.width = endX - startX - MARGIN;
			field.height = _height - MARGIN * 2;
		}
		
		private function beginEdit(event:Event):void {
			if (editing) return;
			editing = true;
			stage.addEventListener(MouseEvent.MOUSE_DOWN, endEdit, false, 0, true);
			field.text = _text;
			format.color = 0x0;
			field.defaultTextFormat = format;
			field.setTextFormat(format, 0, field.text.length);
			field.setSelection(field.text.length, field.text.length);
		}
		
		private function endEdit(event:Event = null):void {
			if (!editing) return;
			editing = false;
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, endEdit);
			text = field.text.replace(/[\r\n]/g, "");
			field.setSelection(-1, -1);
			format.color = 0x606060;
			field.defaultTextFormat = format;
			field.setTextFormat(format, 0, field.text.length);
			
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