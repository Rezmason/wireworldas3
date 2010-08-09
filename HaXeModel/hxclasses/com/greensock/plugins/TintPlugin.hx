package com.greensock.plugins;

extern class TintPlugin extends TweenPlugin {
	function new() : Void;
	function init(target : flash.display.DisplayObject, end : flash.geom.ColorTransform) : Void;
	private var _ct : flash.geom.ColorTransform;
	private var _ignoreAlpha : Bool;
	private var _transform : flash.geom.Transform;
	static var API : Float;
}
