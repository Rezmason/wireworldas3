package net.rezmason.wireworld.views {
	
	import fl.text.TLFTextField;
	
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	
	internal final class WWTextButton extends WWButton {
		
		public function WWTextButton(__name:String, __label:String, __height:Number = NaN, __type:String = null):void {
			
			var format:TextFormat = new TextFormat();
			format.align = TextFormatAlign.CENTER;
			format.font = "_sans";
			format.bold = true;
			format.size = __height * 0.65;
			
			var field:TLFTextField = new TLFTextField();
			field.autoSize = TextFieldAutoSize.CENTER;
			field.text = __label;
			
			field.autoSize = TextFieldAutoSize.NONE;
			field.width = field.textWidth + 2 * MARGIN;
			
			field.defaultTextFormat = format;
			field.setTextFormat(format, 0, field.text.length);
			
			var fieldContainer:Sprite = new Sprite();
			fieldContainer.addChild(field);
			field.y = -field.height;
			
			super(__name, fieldContainer, __height, "()", __type);
		}
		
	}
}