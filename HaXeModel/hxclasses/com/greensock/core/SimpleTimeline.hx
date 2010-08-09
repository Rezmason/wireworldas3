package com.greensock.core;

extern class SimpleTimeline extends TweenCore {
	var autoRemoveChildren : Bool;
	var rawTime(default,null) : Float;
	function new(?vars : Dynamic) : Void;
	function addChild(tween : TweenCore) : Void;
	function remove(tween : TweenCore, ?skipDisable : Bool) : Void;
	private var _firstChild : TweenCore;
	private var _lastChild : TweenCore;
}
