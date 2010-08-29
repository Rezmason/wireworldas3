﻿/*** Wireworld Player by Jeremy Sachs. August 21, 2010** Feel free to distribute the source, just try not to hand it off to some douchebag.* Keep this header here.** Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.*/package net.rezmason.wireworld.views {		//---------------------------------------	// IMPORT STATEMENTS	//---------------------------------------		import apparat.math.FastMath;		import com.greensock.TweenLite;	import com.greensock.easing.Cubic;		import flash.display.BitmapData;	import flash.display.Graphics;	import flash.display.Shape;	import flash.display.Sprite;	import flash.events.Event;	import flash.geom.ColorTransform;	import flash.geom.Matrix;	import flash.geom.Rectangle;		// The Paper is used to display information from the current model,	// as well as other information that should be "connected" to it.		internal final class Paper extends Sprite {				//---------------------------------------		// PRIVATE VARIABLES		//---------------------------------------		private static const POWER_BASE:Number = 1000;		private var initialized:Boolean = false;		private var dragging:Boolean = false;		private var animating:Boolean = false;		private var limitWidth:int, limitHeight:int;		private var homeScale:Number = 1;		private var displayBase:Shape;		private var displayWires:Shape;		private var displayHeads:Shape;		private var displayTails:Shape;		private var displayHeat:Shape;		private var displayGraph:Sprite = new Sprite;		private var _minZoom:Number = 0.1, _maxZoom:Number = 350;		private var topBound:int, leftBound:int, bottomBound:int, rightBound:int;		private var _setBounds:Function;		private var oppScale:Number;		private var _ratio:Number;		private var _palette:ColorPalette;				//---------------------------------------		// CONSTRUCTOR		//---------------------------------------		public function Paper(__width:int = 0, __height:int = 0, __setBounds:Function = null):void {			limitWidth = __width;			limitHeight = __height;			_setBounds = __setBounds;						displayBase = new Shape();			displayWires = new Shape();			displayHeads = new Shape();			displayTails = new Shape();			displayHeat = new Shape();		}				//---------------------------------------		// GETTER / SETTERS		//---------------------------------------				internal function get paperWidth():int { return limitWidth; }		internal function get paperHeight():int { return limitHeight; }		internal function get zoomRatio():Number { return _ratio; }		internal function set zoomRatio(value:Number):void { if (!isNaN(value)) zoom(value, false); }		internal function get showHeat():Boolean { return displayHeat.visible; }		internal function set showHeat(value:Boolean):void { displayGraph.visible = !(displayHeat.visible = value); }				//---------------------------------------		// INTERNAL METHODS		//---------------------------------------				// Connects the Paper to the Model.				internal function init(base:Graphics, wire:Graphics, head:Graphics, tail:Graphics, heat:Graphics, palette:ColorPalette):void {			initialized = true;						copyData(displayBase, base);			copyData(displayWires, wire);			copyData(displayHeads, head);			copyData(displayTails, tail);			copyData(displayHeat, heat);						_palette = palette;			changeColor(_palette);						addChild(displayBase);			addChild(displayGraph);			displayGraph.addChild(displayWires);			displayGraph.addChild(displayTails);			displayGraph.addChild(displayHeads);			addChild(displayHeat);						opaqueBackground = palette.dead;			showHeat = false;			reset();		}				internal function reset(animate:Boolean = false):void {			animating = animate;			TweenLite.killTweensOf(this, false);			var tween:Object;			if (animate) tween = {x:x, y:y, scaleX:scaleX, scaleY:scaleY, ease:Cubic.easeInOut, onComplete:finishAnimating};						homeScale = scaleX = scaleY = 1;			if (width * height < limitWidth * limitHeight * 0.4) {				if (height / width > limitHeight / limitWidth) {					height = limitHeight;					scaleX = scaleY;				} else {					width = limitWidth;					scaleY = scaleX;				}				homeScale = FastMath.max(_minZoom, scaleX);			}						x = (limitWidth - width ) / 2;						if (height <= limitHeight) {				y = (limitHeight - height) / 2;			} else {				y = 0;			}			oppScale = 1 / scaleX;			_ratio = 0;			if (initialized) updateBounds();			if (animate) TweenLite.from(this, 0.25, tween);		}				internal function reposition(__width:int, __height:int):void {			if (animating) return;						x -= limitWidth / 2;			y -= limitHeight / 2;			limitWidth = __width;			limitHeight = __height;			x += limitWidth / 2;			y += limitHeight / 2;						if (initialized) updateBounds();		}				internal function zoom(delta:Number = NaN, incremental:Boolean = true, underX:Number = NaN, underY:Number = NaN):void {			if (animating) return;						delta = FastMath.min(FastMath.max(((incremental ? _ratio : 0) + delta), 0), 1);						if (_ratio != delta) {				_ratio = delta;								if (isNaN(underX)) underX = limitWidth  * 0.5;				if (isNaN(underY)) underY = limitHeight * 0.5;								underX = (underX - x) / scaleX, underY = (underY - y) / scaleY;				x += underX * scaleX, y += underY * scaleX;				scaleX = scaleY = homeScale + (Math.pow(POWER_BASE, _ratio) - 1) / (POWER_BASE - 1) * (_maxZoom - homeScale);				x -= underX * scaleX, y -= underY * scaleX;								oppScale = 1 / scaleX;			}			updateBounds();		}				// Spits out a snapshot of itself.		internal function print():BitmapData {			var bounds:Rectangle = displayGraph.getBounds(displayGraph);			var mat:Matrix = new Matrix(homeScale, 0, 0, homeScale, -bounds.x * homeScale, -bounds.y * homeScale);			var output:BitmapData = new BitmapData(displayGraph.width * mat.a, displayGraph.height * mat.d, false, _palette.dead);			output.draw(displayGraph, mat);			return output;		}				// Switches between the normal and heat views.		internal function toggleHeat(event:Event = null):void {			showHeat = !showHeat;		}				// Dragging functions				internal function beginDrag(event:Event = null):void {			if (animating || dragging) return;			dragging = true;			startDrag();		}				internal function endDrag(event:Event = null):void {			if (!dragging) return;			dragging = false;			updateBounds();			stopDrag();		}				//---------------------------------------		// PRIVATE METHODS		//---------------------------------------				// Some small helper functions				private function copyData(shape:Shape, graphicsObject:Graphics):void {			shape.graphics.clear();			shape.graphics.copyFrom(graphicsObject);		}				private function changeColor(_colorPalette:ColorPalette):void {			var colorTransform:ColorTransform = new ColorTransform;						colorTransform.color = _colorPalette.dead;			displayBase.transform.colorTransform = colorTransform;						colorTransform.color = _colorPalette.wire;			displayWires.transform.colorTransform = colorTransform;						colorTransform.color = _colorPalette.head;			displayHeads.transform.colorTransform = colorTransform;						colorTransform.color = _colorPalette.tail;			displayTails.transform.colorTransform = colorTransform;		}				// finds the rectangle which contains all pixels that are onscreen				private function updateBounds(event:Event = null):void {			if (_setBounds == null) return;			topBound = 		int(FastMath.max(-y, 0) * oppScale) - 2;			leftBound = 	int(FastMath.max(-x, 0) * oppScale) - 2;			bottomBound =	int(FastMath.min(height, stage.stageHeight - y) * oppScale) + 2;			rightBound = 	int(FastMath.min(width, stage.stageWidth - x) * oppScale) + 2;						_setBounds(topBound, leftBound, bottomBound, rightBound);		}				private function finishAnimating():void { animating = false; }	}}