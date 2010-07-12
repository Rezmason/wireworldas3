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
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;

	internal final class Hint extends Sprite {

		private var showTimer:Timer = new Timer(1000, 1);		
		private var hideTimer:Timer = new Timer(5000, 1);
		
		private var field:TLFTextField, format:TextFormat;
		private var tooFarX:Boolean, tooFarY:Boolean;
		
		private var target:DisplayObject;
		
		private var alphaTween:Object = {alpha:0, ease:Quad.easeOut, visible:false};
		
		public function Hint():void {
			super();
			
			field = new TLFTextField();
			field.defaultTextFormat = new TextFormat("_typewriter", 12, 0x0, true);;
			field.selectable = false;
			field.autoSize = TextFieldAutoSize.LEFT;
			field.background = true;
			field.backgroundColor = WWGUIPalette.HINT_BACK;
			field.backgroundAlpha = 0.8;
			field.border = true;
			field.borderColor = 0x000000;
			visible = false;
			mouseEnabled = mouseChildren = false;
			
			filters = [new DropShadowFilter(10, 45, 0x0, 0.4, 10, 10, 1)];
			
			addChild(field);
			
			showTimer.addEventListener(TimerEvent.TIMER_COMPLETE, show);
			hideTimer.addEventListener(TimerEvent.TIMER_COMPLETE, hide);
		}
		
		internal function check(event:Event):void {
			
			var candidate:DisplayObject = event.target as DisplayObject;
			
			if (target && (target as DisplayObjectContainer).contains(candidate)) return;
			
			while (candidate != parent) {
				if (candidate is WWElement) {
					target = candidate;
					target.addEventListener(MouseEvent.ROLL_OUT, hide);
					showTimer.start();
					break;
				}
				candidate = candidate.parent;
			}
		}
		
		internal function show(event:Event = null):void {
			showTimer.stop();
			showTimer.reset();
			
			field.text = target["label"];
			TweenLite.killTweensOf(this, true);
			alpha = 1;
			visible = true;
			
			position();
			
			hideTimer.start();
		}
		
		internal function position(event:Event = null):void {
			field.x = mouseX;
			if (field.x + field.width > stage.stageWidth) {
				field.x = mouseX - field.width;
				tooFarX = true;
			} else {
				tooFarX = false;
			}
			field.y = mouseY + 15;
			if (field.y + field.height > stage.stageHeight) {
				field.y = mouseY - 10 - field.height;
				tooFarY = true;
			} else {
				tooFarY = false;
			}
		}
		
		internal function hide(event:Event = null):void {
			showTimer.stop();
			hideTimer.stop();
			TweenLite.killTweensOf(this, true);
			TweenLite.to(this, 0.25, alphaTween);
			if (target) {
				target.removeEventListener(MouseEvent.ROLL_OUT, hide);
				target = null;
			}
		}
	}
}