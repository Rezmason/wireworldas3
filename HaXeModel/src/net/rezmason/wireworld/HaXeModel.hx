package net.rezmason.wireworld;

// IMPORT STATEMENTS
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.geom.Rectangle;

class HaXeModel extends EventDispatcher, implements IModel {
	
	// PRIVATE PROPERTIES
	private var nodeTable:Array<HaXeNode>;
	
	// CONSTRUCTOR
	public function new():Void {
		super();
		nodeTable = [];
	}
	
	// GETTERS & SETTERS
	
	public var width(get_width, never):Int;
	private function get_width():Int {
		return 0;
	}
	
	public var height(get_height, never):Int;
	private function get_height():Int {
		return 0;
	}
	
	public var wireData(get_wireData, never):BitmapData;
	private function get_wireData():BitmapData {
		return null;
	}
	
	public var headData(get_headData, never):BitmapData;
	private function get_headData():BitmapData {
		return null;
	}
	
	public var tailData(get_tailData, never):BitmapData;
	private function get_tailData():BitmapData {
		return null;
	}
	
	public var credit(get_credit, never):String;
	private function get_credit():String {
		return "";
	}
	
	public var generation(get_generation, never):Float;
	private function get_generation():Float {
		return 0;
	}
	
	public var baseGraphics(get_baseGraphics, never):Graphics;
	private function get_baseGraphics():Graphics {
		return null;
	}
	
	public var wireGraphics(get_wireGraphics, never):Graphics;
	private function get_wireGraphics():Graphics {
		return null;
	}
	
	public var headGraphics(get_headGraphics, never):Graphics;
	private function get_headGraphics():Graphics {
		return null;
	}
	
	public var tailGraphics(get_tailGraphics, never):Graphics;
	private function get_tailGraphics():Graphics {
		return null;
	}
	
	public var heatGraphics(get_heatGraphics, never):Graphics;
	private function get_heatGraphics():Graphics {
		return null;
	}
	
	public var implementsOverdrive(get_implementsOverdrive, never):Bool;
	private function get_implementsOverdrive():Bool {
		return false;
	}
	
	public var overdriveActive(get_overdriveActive, set_overdriveActive):Bool;
	private function get_overdriveActive():Bool {
		return false;
	}
	private function set_overdriveActive(value:Bool):Bool {
		return value;
	}
	
	// PUBLIC METHODS
	
	public function init(txt:String, ?isMCell:Bool = false):Void {
		
	}
	
	public function setBounds(t:Int, l:Int, b:Int, r:Int):Void {
		
	}
	
	public function update():Void {
		
	}
	
	public function refresh(?flags:Int = 0):Void {
		
	}
	
	public function getState(__x:Int, __y:Int):UInt {
		return 0;
	}
	
	public function reset():Void {
		
	}
	
	public function eraseRect(rect:Rectangle):Void {
		
	}
	
	// PRIVATE METHODS
}