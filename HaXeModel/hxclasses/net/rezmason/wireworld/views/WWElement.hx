package net.rezmason.wireworld.views;

extern class WWElement extends flash.display.Sprite {
	var label(default,null) : String;
	function new(__label : String, ?__content : flash.display.DisplayObject, ?__width : Float, ?__height : Float, ?__capStyle : String) : Void;
	function bind(?func : Dynamic, ?addParams : Bool, ?p1 : Dynamic, ?p2 : Dynamic, ?p3 : Dynamic, ?p4 : Dynamic, ?p5 : Dynamic ) : Void;
	private var _addParams : Bool;
	private var _content : Dynamic;
	private var _height : Float;
	private var _label : String;
	private var _params : Array<Dynamic>;
	private var _specifiedWidth : Float;
	private var _trigger : Dynamic;
	private var _width : Float;
	private var backing : flash.display.Shape;
	private var endX : Float;
	private var leftCap : Bool;
	private var rightCap : Bool;
	private var startX : Float;
	private function redraw() : Void;
	static function releaseInstances(?event : flash.events.Event) : Void;
}
