/**
* Wireworld Player by Jeremy Sachs. July 25, 2010
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
	import flash.text.TextFormatAlign;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontWeight;
	
	import net.rezmason.text.TallyMan;
	
	internal final class WWNumberField extends WWElement {
		
		private static const FONT_DESCRIPTION:FontDescription = new FontDescription("_typewriter");
		
		private var field:TallyMan, format:ElementFormat;
		
		public function WWNumberField(__label:String, __width:Number = 100, __height:Number = 10, __capStyle:String = null):void {
			
			var fontDesc:FontDescription = FONT_DESCRIPTION.clone();
			format = new ElementFormat();
			
			super(__label, null, __width, __height, __capStyle);
			cacheAsBitmap = false;
			
			backing.transform.colorTransform = WWGUIPalette.PLAIN_TEXT_BACK_CT;
			if (backing.visible) {
				format.color = WWGUIPalette.NAKED_TEXT;
			} else {
				fontDesc.fontWeight = FontWeight.BOLD;
				format.color = WWGUIPalette.PLAIN_TEXT;
			}
			
			format.fontDescription = fontDesc;
			format.fontSize = _height * 0.65;
			field = new TallyMan(format);
			field.number = 0;
			redraw();
		}
		
		public function get num():Number { return field.number; }
		public function set num(value:Number):void {
			field.number = value;
			redraw();
		}
		
		override protected function redraw():void {
			super.redraw();
			
			if (field) {
				addChild(field);
				
				field.y = -field.height * 0.5;
				
				if (leftCap) {
					if (rightCap) {
						field.x = (startX + endX - field.width) * 0.5;
					} else {
						field.x = endX - field.width;
					}
				} else {
					field.x = startX + MARGIN;
				}
			}
		}
	}
}