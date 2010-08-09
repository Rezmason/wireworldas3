/**
* Wireworld Player by Jeremy Sachs. July 25, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld;

// IMPORT STATEMENTS
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Timer;

import net.rezmason.wireworld.brains.Importer;
import net.rezmason.wireworld.brains.HeatSpectrum;
import net.rezmason.wireworld.brains.Spectrum;
import net.rezmason.utils.GraphicsUtils;

class HaXeBaseModel extends EventDispatcher, implements IModel {

	// PRIVATE PROPERTIES
	inline static var INT_MAX_VALUE:Int = 0x7fffffff;
	
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

	// GETTERS & SETTERS


	public function width():Int {
		return 0;
	}

	public function height():Int {
		return 0;
	}

	public function wireData():flash.display.BitmapData {
		return null;
	}

	public function headData():flash.display.BitmapData {
		return null;
	}

	public function tailData():flash.display.BitmapData {
		return null;
	}

	public function credit():String {
		return "";
	}

	public function baseGraphics():flash.display.Graphics {
		return null;
	}

	public function generation():Float {
		return 0;
	}

	public function headGraphics():flash.display.Graphics {
		return null;
	}

	public function heatGraphics():flash.display.Graphics {
		return null;
	}

	public function implementsOverdrive():Bool {
		return false;
	}

	public function overdriveActive():Bool {
		return false;
	}

	public function set_overdriveActive(value:Bool):Void {

	}

	public function tailGraphics():flash.display.Graphics {
		return null;
	}

	public function wireGraphics():flash.display.Graphics {
		return null;
	}


	// PUBLIC METHODS

	public function eraseRect(rect:flash.geom.Rectangle):Void;
	public function getState(__x:Int, __y:Int):UInt {
		return 0;
	}
	public function init(txt:String, isMCell:Bool):Void {
		wait.start();
	}
	public function refresh(flags:Int):Void;
	public function reset():Void;
	public function setBounds(t:Int, l:Int, b:Int, r:Int):Void;
	public function update():Void;

	// PRIVATE METHODS

	private function done(event:Event):Void {
		dispatchEvent(new Event(Event.COMPLETE));
	}
}