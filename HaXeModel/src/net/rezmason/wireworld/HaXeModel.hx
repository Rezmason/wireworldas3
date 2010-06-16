package net.rezmason.wireworld;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

class HaXeModel extends EventDispatcher, implements IModel {
	
	public var base(default, null): BitmapData;
	public var baseGraphics(default, null): Graphics;
	public var credit: String;
	public var generation(default, null): Float;
	public var headData(default, null): BitmapData;
	public var headGraphics(default, null): Graphics;
	public var height(default, null): Int;
	public var historyGraphics(default, null): Graphics;
	public var implementsOverdrive(default, null): Bool;
	public var overdriveActive: Bool;
	public var tailData(default, null): BitmapData;
	public var tailGraphics(default, null): Graphics;
	public var width(default, null): Int;
	public var wireData(default, null): BitmapData;
	public var wireGraphics(default, null): Graphics;
	
	public function getState(__x: Int,  __y: Int): UInt {
		return 0;
	}
	
	public function init(txt: String,  ?isMCell: Bool): Void {
		
	}
	
	public function refreshAll(): Void {
		
	}
	
	public function refreshHistory(): Void {
		
	}
	
	public function refreshImage(): Void {
		
	}
	
	public function reset(): Void {
		
	}
	
	public function update(): Void {
		
	}
	
	public function new() { super(); }
}