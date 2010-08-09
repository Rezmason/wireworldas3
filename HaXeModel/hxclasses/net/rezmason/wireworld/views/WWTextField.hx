package net.rezmason.wireworld.views;

extern class WWTextField extends WWElement {
	var text : String;
	function new(__label : String, ?__width : Float, ?__height : Float, ?__maxChars : Int, ?__capStyle : String, ?__acceptsInput : Bool, ?__labelText : String) : Void;
	function grabFocus() : Void;
}
