package com.flashdynamix.utils;

extern class SWFProfiler {
	static var averageFps(default,null) : Float;
	static var currentFps(default,null) : Float;
	static var currentMem(default,null) : Float;
	static var fpsList : Array<Dynamic>;
	static var history : Int;
	static var maxFps : Float;
	static var maxMem : Float;
	static var memList : Array<Dynamic>;
	static var minFps : Float;
	static var minMem : Float;
	static function gc() : Void;
	static function init(swf : flash.display.Stage, context : flash.display.InteractiveObject) : Void;
	static function start() : Void;
	static function stop() : Void;
}
