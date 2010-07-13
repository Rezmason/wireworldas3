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
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.rezmason.gui.Toolbar;

	internal class WWDialog extends Sprite {
		
		private static const MARGIN:Number = 20, CONTENT_MARGIN:Number = 5;
		
		private var backing:Shape;
		private var content:Sprite;
		private var gradient:Matrix;
		private var titleBox:TLFTextField, subtitleBox:TLFTextField;
		
		private var _width:Number;
		private var _title:String, _subtitle:String;
		private var toolbar:Toolbar;
		private var isBubble:Boolean = false;
		private var centerX:Number = 0, centerY:Number = 0;
		
		public function WWDialog(__width:Number = NaN, __title:String = null, __subtitle:String = null, 
				__speechX:Number = NaN, __speechY:Number = NaN):void {
			
			_width = isNaN(__width) ? 320 : __width;
			_title = __title;
			_subtitle = __subtitle;
			if (!isNaN(__speechX + __speechY)) {
				isBubble = true;
				centerX = __speechX;
				centerY = __speechY;
			}
			
			backing = new Shape();
			titleBox = new TLFTextField();
			subtitleBox = new TLFTextField();
			content = new Sprite();
			toolbar = new Toolbar(_width, 18, 0x0, 1);
			toolbar.leftMargin = toolbar.rightMargin = MARGIN;
			
			redraw();
		}
		
		public function addContent(item:DisplayObject):void {
			item.x = item.y = 0;
			var rect:Rectangle = item.getBounds(item);
			item.x = -rect.x;
			item.y = -rect.y + content.height + CONTENT_MARGIN;
			content.addChild(item);
			redraw();
		}
		
		public function clearContents():void {
			while (content.numChildren) content.removeChildAt(0);
			redraw();
		}
		
		private function redraw():void {
			while (numChildren) removeChildAt(0);
			
		}
	}
}