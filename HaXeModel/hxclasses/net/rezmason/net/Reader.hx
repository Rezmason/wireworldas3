package net.rezmason.net;

extern class Reader {
	static var LOAD_ERROR : String;
	static var PATH_ERROR : String;
	static var PATH_ERROR_EVENT : flash.events.ErrorEvent;
	static var data(default,null) : String;
	static function addEventListener(type : String, listener : Dynamic, ?useCapture : Bool, ?priority : Int, ?useWeakReference : Bool) : Void;
	static function hasEventListener(type : String) : Bool;
	static function load(__url : String) : Void;
	static function loadBytes(data : flash.utils.ByteArray) : Void;
	static function removeEventListener(type : String, listener : Dynamic, ?useCapture : Bool) : Void;
}
