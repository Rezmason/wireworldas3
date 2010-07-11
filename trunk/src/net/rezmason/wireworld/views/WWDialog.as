/**
* Wireworld Player by Jeremy Sachs. June 22, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld.views {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import net.rezmason.gui.Toolbar;

	internal class WWDialog extends Sprite {
		
		private var _width:Number;
		private var toolbar:Toolbar
		
		public var elements:Object = {}; // Perhaps this looks stingy, but it's mighty convenient.
		
		public function WWDialog(__width:Number = 320, __title:String = null, __subtitle:String = null, 
				__speechX:Number = NaN, __speechY:Number = NaN):void {
			
		}
		
		public function addContent(content:DisplayObject):void {
			
		}
		
		private function redraw():void {
			
		}
	}
}