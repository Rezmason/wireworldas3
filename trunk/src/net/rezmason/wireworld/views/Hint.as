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
	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.utils.Timer;
	
	// Every self-respecting piece of software has
	// a contextual annotation system, like hint boxes,
	// to help users learn their way around the GUI.
	
	internal final class Hint extends Sprite {
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private var showTimer:Timer = new Timer(1000, 1);		
		private var hideTimer:Timer = new Timer(5000, 1);
		private var field:Sprite;
		private var target:DisplayObject;
		private var alphaTween:Object = {alpha:0, ease:Quad.easeOut, visible:false};
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function Hint():void {
			super();
			
			visible = false;
			mouseEnabled = mouseChildren = false;
			
			filters = [new DropShadowFilter(10, 45, 0x0, 0.4, 10, 10, 1)];
			
			showTimer.addEventListener(TimerEvent.TIMER_COMPLETE, show);
			hideTimer.addEventListener(TimerEvent.TIMER_COMPLETE, hide);
		}
		
		//---------------------------------------
		// INTERNAL METHODS
		//---------------------------------------
		
		// Looks for a potential subject. If it finds one, it starts the timer.
		internal function check(event:MouseEvent):void {
			
			if (event.buttonDown) return;
			
			var candidate:DisplayObject = event.target as DisplayObject;
			
			if (target && (target as DisplayObjectContainer).contains(candidate)) return;
			
			while (candidate != parent) {
				if (candidate is WWElement) {
					target = candidate;
					target.addEventListener(MouseEvent.ROLL_OUT, hide);
					if (target["label"]) showTimer.start();
					break;
				}
				candidate = candidate.parent;
			}
		}
		
		// After hovering a while over a subject, the Hint pops up.
		internal function show(event:Event = null):void {
			
			showTimer.stop();
			showTimer.reset();
			
			if (field) removeChild(field);
			field = TextFactory.generateInBox(target["label"], "_typewriter", 12, true, 3, -1, WWGUIPalette.HINT_BACK, 0.8);
			addChild(field);
			TweenLite.killTweensOf(this, true);
			alpha = 1;
			visible = true;
			
			position();
			
			hideTimer.start();
		}
		
		// Makes sure the hint never goes off the side of the stage.
		internal function position(event:Event = null):void {
			field.x = mouseX + 15;
			if (field.x + field.width > stage.stageWidth) {
				field.x = mouseX - field.width;
			}
			field.y = mouseY + 15;
			if (field.y + field.height > stage.stageHeight) {
				field.y = mouseY - 10 - field.height;
			}
		}
		
		// A while after showing up, or after the mosue has rolled off the subject,
		// the Hint hides.
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