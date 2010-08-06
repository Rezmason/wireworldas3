package net.rezmason.wireworld;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.events.IEventDispatcher;
import flash.geom.Rectangle;

extern interface IModel implements IEventDispatcher {
	public var width(get_width, never):Int;
	public var height(get_height, never):Int;
	public var wireData(get_wireData, never):BitmapData;
	public var headData(get_headData, never):BitmapData;
	public var tailData(get_tailData, never):BitmapData;
	public var credit(get_credit, never):String;
	public var generation(get_generation, never):Float;
	public var baseGraphics(get_baseGraphics, never):Graphics;
	public var wireGraphics(get_wireGraphics, never):Graphics;
	public var headGraphics(get_headGraphics, never):Graphics;
	public var tailGraphics(get_tailGraphics, never):Graphics;
	public var heatGraphics(get_heatGraphics, never):Graphics;
	public var implementsOverdrive(get_implementsOverdrive, never):Bool;
	public var overdriveActive(get_overdriveActive, set_overdriveActive):Bool;

	public function init(txt:String, ?isMCell:Bool = false):Void;
	public function setBounds(t:Int, l:Int, b:Int, r:Int):Void;
	public function update():Void;
	public function refresh(?flags:Int = 0):Void;
	public function getState(__x:Int, __y:Int):UInt;
	public function reset():Void;
	public function eraseRect(rect:Rectangle):Void;
}
