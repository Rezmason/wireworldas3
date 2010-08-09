package com.greensock.plugins;

extern class TweenPlugin {
	var activeDisable : Bool;
	var changeFactor : Float;
	var onComplete : Dynamic;
	var onDisable : Dynamic;
	var onEnable : Dynamic;
	var overwriteProps : Array<Dynamic>;
	var priority : Int;
	var propName : String;
	var round : Bool;
	function new() : Void;
	function killProps(lookup : Dynamic) : Void;
	function onInitTween(target : Dynamic, value : Dynamic, tween : com.greensock.TweenLite) : Bool;
	private var _changeFactor : Float;
	private var _tweens : Array<Dynamic>;
	private function addTween(object : Dynamic, propName : String, start : Float, end : Dynamic, ?overwriteProp : String) : Void;
	private function updateTweens(changeFactor : Float) : Void;
	static var API : Float;
	static var VERSION : Float;
	static function activate(plugins : Array<Dynamic>) : Bool;
}
