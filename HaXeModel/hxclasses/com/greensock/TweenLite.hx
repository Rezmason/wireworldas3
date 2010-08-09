package com.greensock;

extern class TweenLite extends com.greensock.core.TweenCore {
	var cachedPT1 : com.greensock.core.PropTween;
	var propTweenLookup : Dynamic;
	var ratio : Float;
	var target : Dynamic;
	function new(target : Dynamic, duration : Float, vars : Dynamic) : Void;
	function killVars(vars : Dynamic, ?permanent : Bool) : Bool;
	private var _ease : Dynamic;
	private var _hasPlugins : Bool;
	private var _notifyPluginsOfEnabled : Bool;
	private var _overwrite : UInt;
	private var _overwrittenProps : Dynamic;
	private function easeProxy(t : Float, b : Float, c : Float, d : Float) : Float;
	private function init() : Void;
	static var defaultEase : Dynamic;
	static var fastEaseLookup : flash.utils.Dictionary;
	static var killDelayedCallsTo : Dynamic;
	static var masterList : flash.utils.Dictionary;
	static var onPluginEvent : Dynamic;
	static var overwriteManager : Dynamic;
	static var plugins : Dynamic;
	static var rootFrame : Float;
	static var rootFramesTimeline : com.greensock.core.SimpleTimeline;
	static var rootTimeline : com.greensock.core.SimpleTimeline;
	static var version : Float;
	static function delayedCall(delay : Float, onComplete : Dynamic, ?onCompleteParams : Array<Dynamic>, ?useFrames : Bool) : TweenLite;
	static function from(target : Dynamic, duration : Float, vars : Dynamic) : TweenLite;
	static function initClass() : Void;
	static function killTweensOf(target : Dynamic, ?complete : Bool, ?vars : Dynamic) : Void;
	static function to(target : Dynamic, duration : Float, vars : Dynamic) : TweenLite;
}
