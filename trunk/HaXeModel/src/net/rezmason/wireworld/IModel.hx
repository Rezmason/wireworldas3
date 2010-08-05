package net.rezmason.wireworld;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.events.IEventDispatcher;

extern interface IModel implements IEventDispatcher {
	var base(default, null):BitmapData;
	var baseGraphics(default, null):Graphics;
	var credit:String;
	var generation(default, null):Float;
	var headData(default, null):BitmapData;
	var headGraphics(default, null):Graphics;
	var height(default, null):Int;
	var historyGraphics(default, null):Graphics;
	var implementsOverdrive(default, null):Bool;
	var overdriveActive:Bool;
	var tailData(default, null):BitmapData;
	var tailGraphics(default, null):Graphics;
	var width(default, null):Int;
	var wireData(default, null):BitmapData;
	var wireGraphics(default, null):Graphics;
	
	function getState(__x:Int,  __y:Int):UInt;
	function init(txt:String,  ?isMCell:Bool):Void;
	function refreshAll():Void;
	function refreshHistory():Void;
	function refreshImage():Void;
	function reset():Void;
	function update():Void;
}
