/**
* Wireworld Player by Jeremy Sachs. August 21, 2010
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
	import apparat.math.FastMath;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	
	// WWElements are interactive objects with oblong
	// background shapes that indicate their nature
	// to the user. They can be bound to functions, 
	// so that when they change state, they can trigger
	// an action.
	
	internal class WWElement extends Sprite {
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		protected var _label:String;
		
		protected static const MARGIN:Number = 2;
		
		protected var _trigger:Function, _params:Array, _addParams:Boolean;
		
		protected var _width:Number, _specifiedWidth:Number, _height:Number;
		protected var leftCap:Boolean, rightCap:Boolean;
		protected var _content:*;
		
		protected var backing:Shape = new Shape();
		
		private static const RELEASE_EVENT:MouseEvent = new MouseEvent(MouseEvent.MOUSE_UP, false);
		
		private var subscribed:Boolean = false;
		private static const INSTANCES:Array = [];
		
		protected var startX:Number, endX:Number;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function WWElement(__label:String, __content:DisplayObject = null, __width:Number = NaN, __height:Number = NaN, __capStyle:String = null):void {
			super();
			if (__label) _label = __label;
			
			cacheAsBitmap = true;
			
			_content = __content;
			_height = __height;
			_specifiedWidth = __width;
			__capStyle ||= "()";
			leftCap = __capStyle.charAt(0) == "(";
			rightCap = __capStyle.charAt(1) == ")";
			if (__capStyle.indexOf("-") != -1) backing.visible = false;
			redraw();
			
			addEventListener(MouseEvent.MOUSE_DOWN, subscribe);
			addEventListener(MouseEvent.MOUSE_UP, unsubscribe);
			addEventListener(Event.REMOVED, unsubscribe);
		}
		
		//---------------------------------------
		// GETTERS & SETTERS
		//---------------------------------------
		
		public function get label():String {
			return _label;
		}
		
		override public function set width(value:Number):void {
			_specifiedWidth = FastMath.max(0, value);
			redraw();
		}
		
		override public function set height(value:Number):void {
			_height = FastMath.max(0, value);
			redraw();
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		public function bind(func:Function = null, addParams:Boolean = false, ...params):void {
			_trigger = func;
			_params = params;
			_addParams = addParams;
		}
		
		// This is used to tell ALL WWElements that have recently received down events
		// that the user has released the mouse, someplace else, typically nullifying
		// whatever change in state would have occurred.
		public static function releaseInstances(event:Event = null):void {
			while (INSTANCES.length) INSTANCES.pop().release();
		}
		
		//---------------------------------------
		// PRIVATE METHODS
		//---------------------------------------
		
		protected function redraw():void {
			while (numChildren) removeChildAt(0);
			
			var bounds:Rectangle;
			
			if (_content) {
				_content.transform.matrix = new Matrix();
				//_content.scaleX = _content.scaleY = 0.35;
				bounds = _content.getBounds(_content);
				_width = _content.width + _height * 0.5;
				if (_width < _height * 1.5) _width = _height;
				_content.transform.colorTransform = WWGUIPalette.BACK_MED_CT;
				addChild(_content);
			} else {
				_width = _specifiedWidth;
			}
			
			backing.graphics.clear();
			startX = 0;
			endX = _width;
			
			if (leftCap) {
				backing.graphics.beginFill(0x0);
				backing.graphics.drawCircle(startX + _height * 0.5, 0, _height * 0.5);
				backing.graphics.endFill();
				startX += _height * 0.5;
				if (!rightCap) endX += _height * 0.25; // making it wider
			}
			
			if (rightCap) {
				if (!leftCap) endX += _height * 0.25; // making it wider
				backing.graphics.beginFill(0x0);
				backing.graphics.drawCircle(endX - _height * 0.5, 0, _height * 0.5);
				backing.graphics.endFill();
				endX -= _height * 0.5;
			}
			
			backing.graphics.beginFill(0x0);
			backing.graphics.drawRect(startX, -_height * 0.5, endX - startX, _height);
			backing.graphics.endFill();
			
			if (_content) {
				_content.x = (startX + endX  - bounds.left - bounds.right ) * 0.5;
				if (leftCap && !rightCap) _content.x -= _height * 0.25;
				else if (rightCap && !leftCap) _content.x += _height * 0.25;
				_content.y = -(bounds.top + bounds.bottom) * 0.5;
			}
			
			addChildAt(backing, 0);
		}
		
		// These functions are how WWElements respond 
		// to a mouse up event elsewhere in the GUI.
		
		private function subscribe(event:Event):void {
			if (!subscribed) {
				subscribed = true;
				INSTANCES.push(this);
			}
		}
		
		private function unsubscribe(event:Event):void {
			if (subscribed) {
				subscribed = false;
				INSTANCES.splice(INSTANCES.indexOf(this), 1);
			}
		}
		
		private function release():void {
			subscribed = false;
			dispatchEvent(RELEASE_EVENT);
		}
	}
}