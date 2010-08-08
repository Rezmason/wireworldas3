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
	
	public var baseGraphics(default,null) : flash.display.Graphics;
	public var credit(default,null) : String;
	public var generation(default,null) : Float;
	public var headData(default,null) : flash.display.BitmapData;
	public var headGraphics(default,null) : flash.display.Graphics;
	public var heatGraphics(default,null) : flash.display.Graphics;
	public var height(default,null) : Int;
	public var implementsOverdrive(default,null) : Bool;
	public var overdriveActive : Bool;
	public var tailData(default,null) : flash.display.BitmapData;
	public var tailGraphics(default,null) : flash.display.Graphics;
	public var width(default,null) : Int;
	public var wireData(default,null) : flash.display.BitmapData;
	public var wireGraphics(default,null) : flash.display.Graphics;
	
	// PUBLIC METHODS
	
	public function eraseRect(rect : flash.geom.Rectangle) : Void;
	public function getState(__x : Int, __y : Int) : UInt {
		return 0;
	}
	public function init(txt : String, ?isMCell : Bool) : Void {
		wait.start();
	}
	public function refresh(?flags : Int) : Void;
	public function reset() : Void;
	public function setBounds(t : Int, l : Int, b : Int, r : Int) : Void;
	public function update() : Void;
	
	// PRIVATE METHODS
	
	private function done(event:Event):Void {
		dispatchEvent(new Event(Event.COMPLETE));
	}
}