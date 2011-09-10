/**
 * Wireworld Player by Jeremy Sachs. August 21, 2010
 *
 * Feel free to distribute the source, just try not to hand it off to some douchebag.
 * Keep this header here.
 *
 * Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
 */
package net.rezmason.wireworld.views {
	
	//---------------------------------------
	// IMPORT STATEMENTS
	//---------------------------------------
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	// WWTextField is a WWElement that contains
	// a dynamic text box, based on TextField. Not to be
	// confused with WWTextButton.
	
	internal final class WWSimpleTextField extends WWElement {
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private static const FONT:String = "_typewriter";
		
		private var _text:String = "", _labelText:String;
		private var field:TextField, format:TextFormat;
		private var editing:Boolean = false;
		
		public static var keyboardPrompt:Function;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function WWSimpleTextField(__label:String, __width:Number = 100, __height:Number = 10, __maxChars:int = -1, __capStyle:String = null, 
									__acceptsInput:Boolean = false, __labelText:String = ""):void {
			
			field = new TextField();
			field.background = false;
			field.border = false;
			format = field.defaultTextFormat;
			format.font = FONT;
			
			super(__label, null, __width, __height, __capStyle);
			
			if (__maxChars != -1) field.maxChars = __maxChars;
			_labelText = __labelText;
			if (field.maxChars && _labelText.length > field.maxChars) _labelText = _labelText.substr(0, field.maxChars - 3) + "...";
			
			// The WWElement leftCap and rightCap properties are used to determine text alignment
			
			if (leftCap) {
				format.align = rightCap ? TextFormatAlign.CENTER : TextFormatAlign.RIGHT;
			} else {
				format.align = TextFormatAlign.LEFT;
			}
			
			// WWTextFields can be input text boxes, which look different from plain dynamic ones.
			
			if (__acceptsInput) {
				backing.transform.colorTransform = WWGUIPalette.INPUT_TEXT_BACK_CT;
				field.type = TextFieldType.INPUT;
				field.addEventListener(Event.CHANGE, changeResponder);
			} else {
				backing.transform.colorTransform = WWGUIPalette.PLAIN_TEXT_BACK_CT;
				field.selectable = false;
				field.mouseEnabled = false;
				format.bold = true;
				if (backing.visible) {
					format.color = WWGUIPalette.NAKED_TEXT;
				} else {
					format.color = WWGUIPalette.PLAIN_TEXT;
				}
				
			}
			
			format.size = _height * 0.65;
			
			field.defaultTextFormat = format;
			
			field.addEventListener(MouseEvent.CLICK, grabFocus);
		}
		
		//---------------------------------------
		// GETTERS & SETTERS
		//---------------------------------------
		
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
			
			field.defaultTextFormat = format;
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		// Dialogs that contain text boxes should give focus to the top textbox.
		public function grabFocus(event:Event = null):void {
			if (stage) stage.focus = field;
			if (keyboardPrompt != null) keyboardPrompt();
		}
		
		//---------------------------------------
		// PRIVATE METHODS
		//---------------------------------------
		
		override protected function redraw():void {
			super.redraw();
			addChild(field);
			
			field.y = -_height * 0.5;
			field.x = startX + MARGIN;
			field.width = endX - startX - MARGIN;
			field.height = _height;
		}
		
		private function changeResponder(event:Event):void {
			_text = field.text;
			var arr:Array = _addParams ? _params.concat([_text]) : _params;
			if (_trigger != null) _trigger.apply(null, arr);
		}
	}
}