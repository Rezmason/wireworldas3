﻿package net.rezmason.gui {		//---------------------------------------	// IMPORT STATEMENTS	//---------------------------------------	import flash.display.DisplayObject;	import flash.display.Sprite;	import flash.geom.Rectangle;		public final class Toolbar extends Sprite {				//---------------------------------------		// CLASS CONSTANTS		//---------------------------------------		private static const GAP:int = 5, KISS_GAP:int = 2;				//---------------------------------------		// PRIVATE VARIABLES		//---------------------------------------		private var _leftMargin:Number = GAP, _rightMargin:Number = GAP;		private var _width:Number = 1, _height:Number = 1;		private var leftContainer:Sprite = new Sprite;		private var rightContainer:Sprite = new Sprite;		private var middleContainer:Sprite = new Sprite;		private var containers:Array = [leftContainer, middleContainer, rightContainer];		private var _backgroundColor:uint = 0xFFFFFF, _backgroundAlpha:Number = 1.0;		private var _scale:Number = 1;				//---------------------------------------		// CONSTRUCTOR		//---------------------------------------		public function Toolbar(__width:Number = 0, __height:Number = 0, __backgroundColor:uint = 0xFFFFFF, __backgroundAlpha:Number = 1.0):void {						_height = __height;			_width = __width;			_backgroundColor = __backgroundColor;			_backgroundAlpha = __backgroundAlpha;						if (backgroundAlpha == 1) opaqueBackground = backgroundColor;						addChild(leftContainer);			addChild(rightContainer);			addChild(middleContainer);						redraw();		}				//---------------------------------------		// GETTER / SETTERS		//---------------------------------------				override public function get width():Number {			return _width;		}				override public function set width(value:Number):void {			if (value > 0) {				_width = value;				redraw();			}		}				override public function get height():Number {			return _height;		}				override public function set height(value:Number):void {			if (value > 0) {				_height = value;				leftContainer.y = _height * 0.5;				middleContainer.y = _height * 0.5;				rightContainer.y = _height * 0.5;				redraw();			}		}				public function get minWidth():Number {			return leftContainer.width + middleContainer.width + rightContainer.width + GAP + 36;		}				public function get rightMargin():Number {			return _rightMargin;		}				public function set rightMargin(value:Number):void {			if (!isNaN(value)) {				_rightMargin = value;			}		}				public function get leftMargin():Number {			return _leftMargin;		}				public function set leftMargin(value:Number):void {			if (!isNaN(value)) {				_leftMargin = value;			}		}				//---------------------------------------		// INTERNAL METHODS		//---------------------------------------				public function addGUIElements(hAlign:Object = null, kiss:Boolean = false, ...elements):void {			var ike:int;			var container:Sprite = containers[int(hAlign || ToolbarAlign.LEFT)]						for (ike = 0; ike < elements.length; ike++) {				var __element:DisplayObject = elements[ike];				__element.x = container.width;				__element.opaqueBackground = backgroundColor;								container.addChild(__element);								if (container.numChildren > 1) {					if (kiss && (ike || elements.length == 1)) {						__element.x += KISS_GAP;					} else {						__element.x += GAP;					}				}			}						redraw();		}				public function get backgroundColor():uint {			return _backgroundColor;		}				public function set backgroundColor(value:uint):void {			if (!isNaN(value)) {				_backgroundColor = value;				redraw();			}		}				public function get backgroundAlpha():Number {			return _backgroundAlpha;		}				public function set backgroundAlpha(value:Number):void {			if (!isNaN(value)) {				_backgroundAlpha = value;				redraw();			}		}				public function get scale():Number {			return _scale;		}				public function set scale(value:Number):void {			if (!isNaN(value)) {				_scale = value;			}			redraw();		}				public function get realHeight():Number {			return super.height;		}				public function get realWidth():Number {			return super.width;		}				//---------------------------------------		// PRIVATE METHODS		//---------------------------------------				private function redraw():void {			graphics.clear();			graphics.beginFill(_backgroundColor, _backgroundAlpha);			graphics.drawRect(0, 0, _width * _scale, _height * _scale)			graphics.endFill();						leftContainer.scaleX = leftContainer.scaleY = _scale;			middleContainer.scaleX = middleContainer.scaleY = _scale;			rightContainer.scaleX = rightContainer.scaleY = _scale;						leftContainer.x = _leftMargin * _scale;			middleContainer.x = (_width * _scale) / 2 - middleContainer.width / 2;			rightContainer.x = (_width * _scale) - (_rightMargin * _scale) - rightContainer.width;						leftContainer.y = _height * 0.5 * scale;			middleContainer.y = _height * 0.5 * scale;			rightContainer.y = _height * 0.5 * scale;		}	}}