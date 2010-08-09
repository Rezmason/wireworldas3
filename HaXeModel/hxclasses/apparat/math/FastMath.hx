package apparat.math;

extern class FastMath extends apparat.inline.Inlined {
	static function abs(value : Float) : Float;
	static function cos(angleRadians : Float) : Float;
	static function initMemory() : Void;
	static function isNaN(n : Float) : Bool;
	static function max(value0 : Float, value1 : Float) : Float;
	static function min(value0 : Float, value1 : Float) : Float;
	static function rint(value : Float) : Int;
	static function rsqrt(value : Float) : Float;
	static function rsqrt2(value : Float, address : Int) : Float;
	static function sign(value : Float) : Float;
	static function sin(angleRadians : Float) : Float;
	static function sqrt(value : Float) : Float;
	static function sqrt2(value : Float, address : Int) : Float;
}
