package net.rezmason.wireworld.views {
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	
	internal final class WWTextButton extends WWButton {
		
		public function WWTextButton(__label:String, __text:String, __height:Number = 10, __type:String = null):void {
			
			var format:TextFormat = new TextFormat();
			format.align = TextFormatAlign.CENTER;
			format.font = "_sans";
			format.bold = true;
			format.size = __height * 0.65;
			
			var field:TextField = new TextField();
			field.autoSize = TextFieldAutoSize.CENTER;
			field.text = __text;
			field.width += 2 * MARGIN;
			field.height = __height;
			
			field.defaultTextFormat = format;
			field.setTextFormat(format, 0, field.text.length);
			
			var fieldContainer:Sprite = new Sprite();
			fieldContainer.addChild(field);
			field.y = -field.height;
			
			super(__label, fieldContainer, __height, "()", __type);
		}
		
	}
}