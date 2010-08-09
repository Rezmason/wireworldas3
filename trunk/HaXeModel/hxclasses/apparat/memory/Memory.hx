package apparat.memory;

extern class Memory {
	static function readDouble(address : Int) : Float;
	static function readFloat(address : Int) : Float;
	static function readInt(address : Int) : Int;
	static function readUnsignedByte(address : Int) : Int;
	static function readUnsignedShort(address : Int) : Int;
	static function select(byteArray : flash.utils.ByteArray) : Void;
	static function signExtend1(value : Int) : Int;
	static function signExtend16(value : Int) : Int;
	static function signExtend8(value : Int) : Int;
	static function writeByte(value : Int, address : Int) : Void;
	static function writeDouble(value : Float, address : Int) : Void;
	static function writeFloat(value : Float, address : Int) : Void;
	static function writeInt(value : Int, address : Int) : Void;
	static function writeShort(value : Int, address : Int) : Void;
}
