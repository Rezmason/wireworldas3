package net.rezmason.text {
	
	import flash.display.Sprite;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;

	public class TallyMan extends Sprite {
		
		private var _number:Number = 0;
		private var pool:Vector.<Vector.<TextLine>> = new Vector.<Vector.<TextLine>>(13, true);
		private var element:TextElement;
		private var block:TextBlock;
		private var digitY:Number;
		
		public function TallyMan(format:ElementFormat):void {
			super();
			
			element = new TextElement("0", format);
			block = new TextBlock(element);
			
  			var firstDigit:TextLine = getDigit("0");
			digitY = -firstDigit.getBounds(firstDigit).top;
			takeDigit(firstDigit);
		}
		
		public function get number():Number {
			return _number;
		}
		
		public function set number(value:Number):void {
			
			if (isNaN(value)) value = 0;
			if (_number == value) return;
			_number = value;
			
			while (numChildren) takeDigit(removeChildAt(0) as TextLine);
			
			var chars:Array = value.toString().split("");
			
			for (var i:int = 0; i < chars.length; i++) {
				var digit:TextLine = getDigit(chars[i]);
				digit.x = width;
				digit.y = digitY;
				addChild(digit);
			}
		}
		
		private function makeChar(char:String, value:int):TextLine {
			element.replaceText(0, 1, char);
			var returnVal:TextLine = block.createTextLine();
			returnVal.userData = value;
			return returnVal;
		}
		
		private function getDigit(char:String):TextLine {
			var value:int = parseInt(char);
			if (char == ".") value = 10;
			if (char == "-") value = 11;
			if (char == "+") value = 12;
			pool[value] ||= new Vector.<TextLine>();
			if (pool[value].length) return pool[value].pop();
			return makeChar(char, value);
		}
		
		private function takeDigit(digit:TextLine):void {
			pool[int(digit.userData)].push(digit);
		}
	}
}