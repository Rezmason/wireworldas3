/**
* Wireworld Player by Jeremy Sachs. July 25, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld.brains;

// IMPORT STATEMENTS
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.events.Event;
import flash.events.ErrorEvent;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.TimerEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Timer;

import net.rezmason.wireworld.IModel;
import net.rezmason.wireworld.WWEvent;
import net.rezmason.wireworld.WWRefreshFlag;
import net.rezmason.utils.GraphicsUtils;

class HaXeBaseModel extends EventDispatcher, implements IModel {

	// PRIVATE PROPERTIES
	inline static var INT_MAX_VALUE:Int = 0x7fffffff;
	inline static var MAX_SIZE:Int = 2880;
	
	inline static var ORIGIN:Point = new Point();

	inline static var BUSY_EVENT:WWEvent = new WWEvent(WWEvent.MODEL_BUSY);
	inline static var IDLE_EVENT:WWEvent = new WWEvent(WWEvent.MODEL_IDLE);

	inline static var STEP:Int = 6000;
	inline static var CLEAR:UInt = 0x00000000;
	inline static var BLACK:UInt = 0xFF000000;
	inline static var WHITE:UInt = 0xFFFFFFFF;
	inline static var COMPLETE_EVENT:Event = new Event(Event.COMPLETE);
	inline static var INVALID_SIZE_ERROR:String = "Invalid dimensions.";
	inline static var INVALID_SIZE_ERROR_EVENT:ErrorEvent = new ErrorEvent(ErrorEvent.ERROR, false, false, INVALID_SIZE_ERROR);
	
	
	private var wait:Timer;

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

	// These are useful for certain kinds of drawing. 
	// They're color gradient lookup tables.
	private var heatSpectrum:HeatSpectrum;
	private var spectrum:Spectrum;

	// CONSTRUCTOR
	public function new():Void {
		super();
		
		totalNodes = 0;
		_generation = 1;
		_baseGraphics = GraphicsUtils.makeGraphics();
		_wireGraphics = GraphicsUtils.makeGraphics();
		_headGraphics = GraphicsUtils.makeGraphics();
		_tailGraphics = GraphicsUtils.makeGraphics();
		_heatGraphics = GraphicsUtils.makeGraphics();
		
		importer = new Importer();
		importer.addEventListener(WWEvent.DATA_PARSED, finishParse);
		importer.addEventListener(WWEvent.DATA_EXTRACTED, finishExtraction);
		
		bound = new Rectangle(0, 0, INT_MAX_VALUE, INT_MAX_VALUE);
		leftBound = INT_MAX_VALUE;
		topBound = INT_MAX_VALUE;
		activeRect = new Rectangle();
		activeCorner = new Point();
		heatSpectrum = new HeatSpectrum();
		spectrum = new Spectrum();

		wait = new Timer(1000, 1);
		wait.addEventListener(TimerEvent.TIMER, done);
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

	public function init(txt:String, isMCell:Bool):Void { importer.parse(txt, isMCell); }
	public function update():Void {}
	public function getState(__x:Int, __y:Int):UInt { return 0; }
	public function reset():Void {}
	public function eraseRect(rect:Rectangle):Void {}

	public function refresh(flags:Int):Void {
		if (flags & WWRefreshFlag.HEAT != 0) {
			refreshHeat((flags & WWRefreshFlag.FULL));
		} else {
			refreshImage(flags & WWRefreshFlag.FULL, flags & WWRefreshFlag.TAIL);
		}
	}

	public function setBounds(top:Int, left:Int, bottom:Int, right:Int):Void {
		topBound = top - Std.int(activeCorner.y);
		leftBound = left - Std.int(activeCorner.x);
		bottomBound = bottom - Std.int(activeCorner.y);
		rightBound = right - Std.int(activeCorner.x);

		bound.x = leftBound;
		bound.y = topBound;
		bound.width = rightBound - leftBound;
		bound.height = bottomBound - topBound;
	}

	private function finishParse(event:Event):Void {
		if (importer.width  > MAX_SIZE || importer.height  > MAX_SIZE || importer.width * importer.height < 1) {
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

	private function refreshImage(fully:Int = 0, freshTails:Int = 0):Void {}

	private function refreshHeat(fully:Int = 0):Void {}

	private function drawData(graphicsObject:Graphics, rect:Rectangle, data:BitmapData):Void {
		graphicsObject.clear();
		graphicsObject.beginBitmapFill(data, new Matrix(1, 0, 0, 1, rect.x, rect.y), false);
		graphicsObject.drawRect(rect.x, rect.y, rect.width, rect.height);
		graphicsObject.endFill();
	}

	private function drawBackground(graphicsObject:Graphics, w:Float, h:Float, color:Int):Void {
		graphicsObject.clear();
		graphicsObject.beginFill(color);
		graphicsObject.drawRect(0, 0, w, h);
		graphicsObject.endFill();
	}

	private function addNode(__x:Int, __y:Int, __state:Int):Void {
		totalNodes++;
	}

	private function heatColorOf(input:Float):UInt {
		if (input > 1) return heatSpectrum.getPixel(heatSpectrum.width, 0);
		return heatSpectrum.getPixel32(Std.int(input * heatSpectrum.width), 0);
	}

	private function colorOf(input:Float):UInt {
		if (input > 1) return spectrum.getPixel(spectrum.width, 0);
		return spectrum.getPixel32(Std.int(input * spectrum.width), 0);
	}

	private function done(event:Event):Void {
		dispatchEvent(new Event(Event.COMPLETE));
	}
}