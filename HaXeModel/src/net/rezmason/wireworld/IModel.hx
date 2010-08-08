package net.rezmason.wireworld;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.events.IEventDispatcher;
import flash.geom.Rectangle;

extern interface IModel implements IEventDispatcher {
	public var width(default, never):Int;
	public var height(default, never):Int;
	public var wireData(default, never):BitmapData;
	public var headData(default, never):BitmapData;
	public var tailData(default, never):BitmapData;
	public var credit(default, never):String;
	public var generation(default, never):Float;
	public var baseGraphics(default, never):Graphics;
	public var wireGraphics(default, never):Graphics;
	public var headGraphics(default, never):Graphics;
	public var tailGraphics(default, never):Graphics;
	public var heatGraphics(default, never):Graphics;
	public var implementsOverdrive(default, never):Bool;
	public var overdriveActive(default, default):Bool;

	public function init(txt:String, ?isMCell:Bool):Void;
	public function setBounds(t:Int, l:Int, b:Int, r:Int):Void;
	public function update():Void;
	public function refresh(?flags:Int):Void;
	public function getState(__x:Int, __y:Int):UInt;
	public function reset():Void;
	public function eraseRect(rect:Rectangle):Void;
}
