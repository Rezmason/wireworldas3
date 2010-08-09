package net.rezmason.text;

extern class Tyro extends flash.display.Sprite {
	var align : String;
	var background : Bool;
	var backgroundAlpha : Float;
	var backgroundColor : Int;
	var border : Float;
	var borderAlpha : Float;
	var borderColor : Int;
	var charSet : String;
	var cursor : flash.display.DisplayObject;
	var defaultColor : Int;
	var defaultText : String;
	var delayedRefresh : Bool;
	var editable : Bool;
	var format : flash.text.engine.ElementFormat;
	var horizontalMargin : Float;
	var maxChars : Int;
	var selectable : Bool;
	var selectedText(default,null) : String;
	var selectionAlpha : Float;
	var selectionColor : Int;
	var text : String;
	var verticalMargin : Float;
	function new(?__text : String, ?__format : flash.text.engine.ElementFormat, ?__width : Float) : Void;
	function setSelection(start : Int, end : Int) : Void;
}
