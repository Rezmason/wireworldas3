package net.rezmason.gui;

extern class Toolbar extends flash.display.Sprite {
	var backgroundAlpha : Float;
	var backgroundColor : UInt;
	var leftMargin : Float;
	var minWidth(default,null) : Float;
	var realHeight(default,null) : Float;
	var realWidth(default,null) : Float;
	var rightMargin : Float;
	var scale : Float;
	function new(?__width : Float, ?__height : Float, ?__backgroundColor : UInt, ?__backgroundAlpha : Float) : Void;
	function addGUIElements(?hAlign : Dynamic, ?kiss : Bool, ?p1 : Dynamic, ?p2 : Dynamic, ?p3 : Dynamic, ?p4 : Dynamic, ?p5 : Dynamic ) : Void;
}
