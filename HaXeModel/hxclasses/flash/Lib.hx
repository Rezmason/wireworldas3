package flash;

extern class Lib {
	static var current : flash.display.MovieClip;
	static function as(v : Dynamic, c : Class<Dynamic>) : Dynamic;
	static function attach(name : String) : flash.display.MovieClip;
	static function eval(path : String) : Dynamic;
	static function fscommand(cmd : String, ?param : String) : Void;
	static function getTimer() : Int;
	static function getURL(url : flash.net.URLRequest, ?target : String) : Void;
	static function trace(arg : Dynamic) : Void;
}
