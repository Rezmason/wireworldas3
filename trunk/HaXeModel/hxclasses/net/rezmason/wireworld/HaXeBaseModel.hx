package net.rezmason.wireworld;

extern class HaXeBaseModel extends flash.events.EventDispatcher, implements IModel {
	var wait : flash.utils.Timer;
	function new() : Void;
	function baseGraphics() : flash.display.Graphics;
	function credit() : String;
	function done(event : flash.events.Event) : Void;
	function eraseRect(rect : flash.geom.Rectangle) : Void;
	function generation() : Float;
	function getState(__x : Int, __y : Int) : UInt;
	function headData() : flash.display.BitmapData;
	function headGraphics() : flash.display.Graphics;
	function heatGraphics() : flash.display.Graphics;
	function height() : Int;
	function implementsOverdrive() : Bool;
	function init(txt : String, isMCell : Bool) : Void;
	function overdriveActive() : Bool;
	function refresh(flags : Int) : Void;
	function reset() : Void;
	function setBounds(t : Int, l : Int, b : Int, r : Int) : Void;
	function set_overdriveActive(value : Bool) : Void;
	function tailData() : flash.display.BitmapData;
	function tailGraphics() : flash.display.Graphics;
	function update() : Void;
	function width() : Int;
	function wireData() : flash.display.BitmapData;
	function wireGraphics() : flash.display.Graphics;
}
