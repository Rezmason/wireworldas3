package apparat.math;

extern class IntMath extends apparat.inline.Inlined {
	static function abs(value : Int) : Int;
	static function equalSign(value0 : Int, value1 : Int) : Bool;
	static function isEven(value : Int) : Bool;
	static function isOdd(value : Int) : Bool;
	static function isPow2(value : Int) : Bool;
	static function max(value0 : Int, value1 : Int) : Int;
	static function min(value0 : Int, value1 : Int) : Int;
	static function msbOfPow2(value : UInt) : UInt;
	static function nextPow2(value : UInt) : UInt;
	static function sign(value : Int) : Int;
	static function toARGB(alpha : Int, red : Int, green : Int, blue : Int) : UInt;
	static function toRGB(red : Int, green : Int, blue : Int) : Int;
	static function unequalSign(value0 : Int, value1 : Int) : Bool;
}
