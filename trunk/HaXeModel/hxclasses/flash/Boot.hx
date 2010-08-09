package flash;

extern class Boot extends flash.display.MovieClip {
	static var init : Dynamic;
	static var lastError : flash.Error;
	static var lines : Array<Dynamic>;
	static var skip_constructor : Bool;
	static var tf : flash.text.TextField;
	static function __clear_trace() : Void;
	static function __instanceof(v : Dynamic, t : Dynamic) : Bool;
	static function __set_trace_color(rgb : UInt) : Void;
	static function __string_rec(v : Dynamic, str : String) : String;
	static function __trace(v : Dynamic, pos : Dynamic) : Void;
	static function __unprotect__(s : String) : String;
	static function enum_to_string(e : Dynamic) : String;
	static function getTrace() : flash.text.TextField;
}
