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
	import flash.events.MouseEvent;

	internal class WWElement extends Sprite {
		
		protected var _target:Object, _value:*, _trigger:Function;
		
		public function WWElement(__name:String):void {
			super();
			name = __name;
		}
		
		internal function bind(target:Object, value:String):void {
			_target = target, _value = value;
		}
		
		internal function trigger(func:Function):void {
			_trigger = func;
		}
		
		internal function click():void {
			
		}
	}
}