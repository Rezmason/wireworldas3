/**
* Wireworld Player by Jeremy Sachs. August 21, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld.brains;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import net.rezmason.utils.GraphicsUtils;

import net.rezmason.wireworld.IModel;
import net.rezmason.wireworld.WWEvent;
import net.rezmason.wireworld.WWRefreshFlag;

class HaXeBaseModel extends flash.events.EventDispatcher, implements net.rezmason.wireworld.IModel {
	
	private var INT_MAX_VALUE:Int;
	
	private var ORIGIN:Point;

	private var BUSY_EVENT:WWEvent;
	private var IDLE_EVENT:WWEvent;

	private var STEP:Int;
	private var CLEAR:UInt;
	private var BLACK:UInt;
	private var WHITE:UInt;
	private var COMPLETE_EVENT:Event;
	private var INVALID_SIZE_ERROR:String;
	private var INVALID_SIZE_ERROR_EVENT:ErrorEvent;

	private var _width:Int;
	private var _height:Int;
	private var _credit:String;
	private var totalNodes:Int;
	private var _headData:BitmapData;
	private var _tailData:BitmapData;
	private var _wireData:BitmapData;
	private var _heatData:BitmapData;
	private var _generation:UInt;
	private var _baseGraphics:Graphics;
	private var _wireGraphics:Graphics;
	private var _headGraphics:Graphics;
	private var _tailGraphics:Graphics;
	private var _heatGraphics:Graphics;
	private var importer:Importer;
	private var bound:Rectangle;
	private var leftBound:Int;
	private var rightBound:Int;
	private var topBound:Int;
	private var bottomBound:Int;
	private var activeRect:Rectangle;
	private var activeCorner:Point;

	private var heatSpectrum:HeatSpectrum;
	private var spectrum:Spectrum;

	public function new():Void {
		super();
		
		INT_MAX_VALUE = 2147483647;
		ORIGIN = new Point();
		BUSY_EVENT = new WWEvent(WWEvent.MODEL_BUSY);
		IDLE_EVENT = new WWEvent(WWEvent.MODEL_IDLE);
		STEP = 6000;
		CLEAR = 0x00000000;
		BLACK = 0xFF000000;
		WHITE = 0xFFFFFFFF;
		COMPLETE_EVENT = new Event(Event.COMPLETE);
		INVALID_SIZE_ERROR = "Invalid dimensions.";
		INVALID_SIZE_ERROR_EVENT = new ErrorEvent(ErrorEvent.ERROR, false, false, INVALID_SIZE_ERROR);
		totalNodes = 0;
		_generation = 1;
		_baseGraphics = GraphicsUtils.makeGraphics();
		_wireGraphics = GraphicsUtils.makeGraphics();
		_headGraphics = GraphicsUtils.makeGraphics();
		_tailGraphics = GraphicsUtils.makeGraphics();
		_heatGraphics = GraphicsUtils.makeGraphics();
		importer = new Importer();
		bound = new Rectangle(0, 0, INT_MAX_VALUE, INT_MAX_VALUE);
		leftBound = 0;
		rightBound = INT_MAX_VALUE;
		topBound = 0;
		bottomBound = INT_MAX_VALUE;
		activeRect = new Rectangle();
		activeCorner = new Point();
		heatSpectrum = new HeatSpectrum();
		spectrum = new Spectrum();

		importer.addEventListener(WWEvent.DATA_PARSED, finishParse);
		importer.addEventListener(WWEvent.DATA_EXTRACTED, finishExtraction);
	}

	public function width():Int { return _width; }
	public function height():Int { return _height; }
	public function wireData():BitmapData { return _wireData.clone(); }
	public function headData():BitmapData { return _headData.clone(); }
	public function tailData():BitmapData { return _tailData.clone(); }
	public function credit():String { return _credit; }
	public function generation():Float { return _generation; }
	public function baseGraphics():Graphics { return GraphicsUtils.makeGraphics(_baseGraphics); }
	public function wireGraphics():Graphics { return GraphicsUtils.makeGraphics(_wireGraphics); }
	public function headGraphics():Graphics { return GraphicsUtils.makeGraphics(_headGraphics); }
	public function tailGraphics():Graphics { return GraphicsUtils.makeGraphics(_tailGraphics); }
	public function heatGraphics():Graphics { return GraphicsUtils.makeGraphics(_heatGraphics); }

	public function implementsOverdrive():Bool { return false; }
	public function overdriveActive():Bool { return false; }
	public function set_overdriveActive(value:Bool):Void {}

	public function eraseRect(rect:flash.geom.Rectangle):Void;
	public function getState(__x:Int, __y:Int):UInt { return 0; }
	public function init(txt:String, isMCell:Bool):Void { importer.parse(txt, isMCell); }
	
	public function refresh(flags:Int):Void {
		if (flags & WWRefreshFlag.HEAT != 0) {
			refreshHeat((flags & WWRefreshFlag.FULL));
		} else {
			refreshImage(flags & WWRefreshFlag.FULL, flags & WWRefreshFlag.TAIL);
		}
	}
	
	public function reset():Void {}
	
	public function setBounds(top:Int, left:Int, bottom:Int, right:Int):Void {
		topBound = Std.int(Math.max(0, top - activeCorner.y));
		leftBound = Std.int(Math.max(0, left - activeCorner.x));
		bottomBound = Std.int(Math.min(activeRect.height, bottom - activeCorner.y));
		rightBound = Std.int(Math.min(activeRect.width, right - activeCorner.x));

		bound.x = leftBound;
		bound.y = topBound;
		bound.width = rightBound - leftBound;
		bound.height = bottomBound - topBound;
	}
	
	public function update():Void {
		
	}
	
	private function finishParse(event:Event):Void {
		if (importer.width  > WWFormat.MAX_SIZE || importer.height  > WWFormat.MAX_SIZE || importer.width * importer.height < 1) {
			dispatchEvent(INVALID_SIZE_ERROR_EVENT);
		} else {
			_width = importer.width;
			_height = importer.height;
			_credit = importer.credit;
			
			totalNodes = 0;
			importer.extract(addNode);
		}
	}
	
	private function finishExtraction(event:Event):Void {
		//trace(totalNodes, "total nodes");
		dispatchEvent(COMPLETE_EVENT);
	}
	
	private function refreshImage(fully:Int, freshTails:Int):Void {}
	
	private function refreshHeat(fully:Int):Void {}
	
	// Draws the passed BitmapData into a Graphics object.
	private function drawData(graphicsObject:Graphics, rect:Rectangle, data:BitmapData):Void {
		graphicsObject.clear();
		graphicsObject.beginBitmapFill(data, new Matrix(1, 0, 0, 1, rect.x, rect.y), false);
		graphicsObject.drawRect(rect.x, rect.y, rect.width, rect.height);
		graphicsObject.endFill();
	}
	
	// Draws the passed BitmapData into a Graphics object.
	private function drawBackground(graphicsObject:Graphics, w:Float, h:Float, color:Int):Void {
		graphicsObject.clear();
		graphicsObject.beginFill(color);
		graphicsObject.drawRect(0, 0, w, h);
		graphicsObject.endFill();
	}
	
	private function addNode(__x:Int, __y:Int, __state:Int):Void {
		totalNodes++;
	}
}
