package net.rezmason.wireworld.views;

extern class ColorPalette {
	var dead : Int;
	var head : Int;
	var tail : Int;
	var wire : Int;
	function new(?__dead : Int, ?__wire : Int, ?__head : Int, ?__tail : Int) : Void;
	static var appropriatePalette(default,null) : ColorPalette;
}
