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
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontWeight;
	
	import net.rezmason.text.Tyro;
	
	internal class WWTextField extends WWElement {
		
		private static const FONT_DESCRIPTION:FontDescription = new FontDescription("_typewriter");
		
		private var _text:String = "", _labelText:String;
		private var field:Tyro, format:ElementFormat;
		private var editing:Boolean = false;
		
		public function WWTextField(__label:String, __width:Number = 100, __height:Number = 10, __maxChars:int = -1, __capStyle:String = null, 
				__acceptsInput:Boolean = false, __labelText:String = ""):void {
			
			var fontDesc:FontDescription = FONT_DESCRIPTION.clone();
			field = new Tyro();
			field.background = false;
			field.border = NaN;
			field.delayedRefresh = true;
			format = new ElementFormat();
			
			super(__label, null, __width, __height, __capStyle);
			
			if (__maxChars != -1) field.maxChars = __maxChars;
			_labelText = __labelText;
			if (field.maxChars && _labelText.length > field.maxChars) _labelText = _labelText.substr(0, field.maxChars - 3) + "...";
			field.defaultText = _labelText;
			
			if (leftCap) {
				field.align = rightCap ? TextFormatAlign.CENTER : TextFormatAlign.RIGHT;
			} else {
				field.align = TextFormatAlign.LEFT;
			}
			
			if (__acceptsInput) {
				backing.transform.colorTransform = WWGUIPalette.INPUT_TEXT_BACK_CT;
				field.editable = true;
				field.defaultColor = WWGUIPalette.DEFAULT_TEXT;
				field.addEventListener(Event.CHANGE, changeResponder);
			} else {
				backing.transform.colorTransform = WWGUIPalette.PLAIN_TEXT_BACK_CT;
				field.selectable = false;
				field.mouseEnabled = false;
				fontDesc.fontWeight = FontWeight.BOLD;
				if (backing.visible) {
					format.color = WWGUIPalette.NAKED_TEXT;
				} else {
					format.color = WWGUIPalette.PLAIN_TEXT;
				}
				
			}
			
			format.fontDescription = fontDesc;
			format.fontSize = _height * 0.65;
			
			field.format = format;
			field.verticalMargin = 0;
			field.selectionColor = 0x0;
			field.delayedRefresh = false;
		}
		
		public function get text():String { return _text; }
		public function set text(value:String):void {
			_text = value;
			field.text = _text;
			if (_text.length) {
				if (field.maxChars && _text.length > field.maxChars) _text = _text.substr(0, field.maxChars - 3) + "...";
				field.text = _text;
			} else {
				field.text = _labelText;
			}
			
			field.format = format;
		}
		
		public function grabFocus():void {
			if (stage) stage.focus = field;
		}
		
		override protected function redraw():void {
			super.redraw();
			addChild(field);
			
			field.y = -_height * 0.5;
			field.x = startX + MARGIN;
			field.width = endX - startX - MARGIN;
		}
		
		private function changeResponder(event:Event):void {
			_text = field.text;
			var arr:Array = _addParams ? _params.concat([_text]) : _params;
			if (_trigger != null) _trigger.apply(null, arr);
		}
	}
}