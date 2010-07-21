/**
* Wireworld Player by Jeremy Sachs. June 22, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld.views {
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontWeight;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	
	
	internal final class TextFactory {
		
		private static const BLOCK:TextBlock = new TextBlock();
		
		internal static function generate(text:String, font:String, size:Number, bold:Boolean = false):TextLine {
			var fd:FontDescription = new FontDescription(font, bold ? FontWeight.BOLD : FontWeight.NORMAL);
			BLOCK.content = new TextElement(text, new ElementFormat(fd, size));
			
			return BLOCK.createTextLine();
		}
		
		internal static function generateInBox(text:String, font:String, size:Number, bold:Boolean = false, margin:Number = 3, 
				border:int = -1, background:int = -1, backgroundAlpha:Number = NaN):Sprite {
			
			var box:Sprite = new Sprite();
			var line:TextLine = generate(text, font, size, bold);
			
			box.addChild(line);
			
			var rect:Rectangle = line.getBounds(box);
			rect.inflate(margin, margin);
			
			line.x -= rect.x;
			line.y -= rect.y;
			rect.x = rect.y = 0;
			
			if (border >= 0) box.graphics.lineStyle(0, border);
			if (background >= 0) {
				box.graphics.beginFill(background, !isNaN(backgroundAlpha) ? backgroundAlpha : 1);
			} else {
				box.graphics.beginFill(0x0, 0);
			}
			box.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
			box.graphics.endFill();
			
			return box;
		}
	}
}