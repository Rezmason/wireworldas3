package net.rezmason.wireworld;

// IMPORT STATEMENTS
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.TimerEvent;
import flash.geom.Rectangle;
import flash.utils.Timer;

class HaXeModel extends EventDispatcher, implements IModel {
	
	// PRIVATE PROPERTIES
	private var nodeTable:Array<HaXeNode>;
	private var wait:Timer;
	
	// CONSTRUCTOR
	public function new():Void {
		super();
		nodeTable = [];
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