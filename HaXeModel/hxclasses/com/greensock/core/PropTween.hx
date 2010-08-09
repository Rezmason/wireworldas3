package com.greensock.core;

extern class PropTween {
	var change : Float;
	var isPlugin : Bool;
	var name : String;
	var nextNode : PropTween;
	var prevNode : PropTween;
	var priority : Int;
	var property : String;
	var start : Float;
	var target : Dynamic;
	function new(target : Dynamic, property : String, start : Float, change : Float, name : String, isPlugin : Bool, ?nextNode : PropTween, ?priority : Int) : Void;
}
