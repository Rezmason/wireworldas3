﻿/*** Wireworld Player by Jeremy Sachs. June 22, 2010** Feel free to distribute the source, just try not to hand it off to some douchebag.* Keep this header here.** Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.*/package net.rezmason.wireworld.views {		//---------------------------------------	// IMPORT STATEMENTS	//---------------------------------------		import flash.display.MovieClip;	import flash.display.Sprite;	import flash.events.Event;	import flash.events.MouseEvent;	import flash.events.TimerEvent;	import flash.external.ExternalInterface;	import flash.utils.Timer;		import com.greensock.TweenLite;		import net.rezmason.net.Syphon;		import net.rezmason.wireworld.IModel;	import net.rezmason.wireworld.WWEvent;		// Announcers are cool. They swell up and blink when	// the state of the node beneath them changes. Very userful	// for keeping track of small events in a big Wireworld instance.		// Announcers have one other trick; when the player is running in	// a JavaScript-augmented environment, they belch out their names	// when they swell. You could technically link Wireworld to other	// systems this way.	internal final class Announcer extends Sprite {				//---------------------------------------		// CLASS CONSTANTS		//---------------------------------------		private static const SELECT_EVENT:WWEvent = new WWEvent(WWEvent.ANNOUNCER_SELECT);		private static const REMOVE_EVENT:WWEvent = new WWEvent(WWEvent.ANNOUNCER_REMOVE);		private static const DROP_EVENT:WWEvent = new WWEvent(WWEvent.ANNOUNCER_DROP);				//---------------------------------------		// PRIVATE VARIABLES		//---------------------------------------		private var active:Boolean = true;		private var ike:int, jen:int;		private var savedState:uint;		private var checkState:uint;		private var perkTimer:Timer = new Timer(5000, 1);		private var _model:IModel;		private var bubble:MovieClip;		private var _x:int, _y:int;				//---------------------------------------		// CONSTRUCTOR		//---------------------------------------		public function Announcer(__paper:Paper, __model:IModel):void {						bubble = new Syphon.library.AnnouncerBubble;			bubble.gotoAndStop("dormant");						__paper.addChild(this);			_model = __model;			_x = (__paper.paperWidth  / 2 - __paper.x) / __paper.scaleX;			_y = (__paper.paperHeight / 2 - __paper.y) / __paper.scaleY;						x = _x + 0.5;			y = _y + 0.5;						position();			bubble.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag, false, 0, true);			bubble.addEventListener(MouseEvent.MOUSE_UP, endDrag, false, 0, true);			stage.addEventListener(Event.MOUSE_LEAVE, endDrag, false, 0, true);			perkTimer.addEventListener(TimerEvent.TIMER, dieDown, false, 0, true);			active = true;			cacheAsBitmap = true;						addChild(bubble);		}				//---------------------------------------		// INTERNAL METHODS		//---------------------------------------				// if the state of the pixel under it has changed since it last checked, it will perk up		internal function update():void {			if (active) {				checkState = _model.getState(_x, _y);				if (checkState != savedState) {					savedState = checkState;					perkUp();					perkTimer.reset();					try {						ExternalInterface.call("dispatchAnnouncerEvent", name, _x, _y);					} catch (error:Error) {											}				}			}		}				// Announcers disappear when they're dropped off the edge of the paper.		internal function fadeAway():void {			TweenLite.killTweensOf(bubble);			TweenLite.to(bubble, 0.4, {alpha:0, onComplete:goodbye});		}				internal static function zSort(announcer1:Announcer, announcer2:Announcer):Number {			return announcer1.y - announcer2.y;		}				//---------------------------------------		// PRIVATE METHODS		//---------------------------------------				private function beginDrag(event:Event):void {			event.stopPropagation();			startDrag();			dispatchEvent(SELECT_EVENT);			active = false;		}				private function endDrag(event:Event):void {			stopDrag();			position();			active = true;			if (_x > _model.width || _y > _model.height || _x < 0 || _y < 0) {				active = false;				fadeAway();			} else {				dispatchEvent(DROP_EVENT);			}		}				private function startTimer(event:Event = null):void {			perkTimer.start();		}				// ensures that the announcer is positioned correctly over its pixel		private function position():void {			_x = int(x);			_y = int(y);			savedState = _model.getState(_x, _y);			x = _x + 0.5;			y = _y + 0.5;		}		private function perkUp():void {			if (bubble.currentLabel == "dormant") {				bubble.gotoAndPlay("hit");			}			TweenLite.killTweensOf(bubble);			TweenLite.to(bubble, 0.4, {scaleX:1.8, scaleY:1.8, onComplete:startTimer});		}				private function dieDown(event:TimerEvent):void {			TweenLite.killTweensOf(bubble);			TweenLite.to(bubble, 0.4, {scaleX:1, scaleY:1, onComplete:bubble.gotoAndStop, onCompleteParams:["dormant"]});		}				private function goodbye(event:Event = null):void {			dispatchEvent(REMOVE_EVENT);		}	}}