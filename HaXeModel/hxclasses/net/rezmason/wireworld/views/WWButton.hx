package net.rezmason.wireworld.views;

extern class WWButton extends WWElement {
	var down : Bool;
	function new(__label : String, ?__content : Dynamic, ?__height : Float, ?__capStyle : String, ?__type : String, ?__setID : String, ?__option : Dynamic) : Void;
	function click(?event : flash.events.Event) : Void;
}
