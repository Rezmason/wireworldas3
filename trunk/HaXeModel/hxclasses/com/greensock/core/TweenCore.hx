package com.greensock.core;

extern class TweenCore {
	var active : Bool;
	var cacheIsDirty : Bool;
	var cachedDuration : Float;
	var cachedOrphan : Bool;
	var cachedPaused : Bool;
	var cachedReversed : Bool;
	var cachedStartTime : Float;
	var cachedTime : Float;
	var cachedTimeScale : Float;
	var cachedTotalDuration : Float;
	var cachedTotalTime : Float;
	var currentTime : Float;
	var data : Dynamic;
	var delay : Float;
	var duration : Float;
	var gc : Bool;
	var initted : Bool;
	var nextNode : TweenCore;
	var paused : Bool;
	var prevNode : TweenCore;
	var reversed : Bool;
	var startTime : Float;
	var timeline : SimpleTimeline;
	var totalDuration : Float;
	var totalTime : Float;
	var vars : Dynamic;
	function new(?duration : Float, ?vars : Dynamic) : Void;
	function complete(?skipRender : Bool, ?suppressEvents : Bool) : Void;
	function invalidate() : Void;
	function kill() : Void;
	function pause() : Void;
	function play() : Void;
	function renderTime(time : Float, ?suppressEvents : Bool, ?force : Bool) : Void;
	function restart(?includeDelay : Bool, ?suppressEvents : Bool) : Void;
	function resume() : Void;
	function reverse(?forceResume : Bool) : Void;
	function setEnabled(enabled : Bool, ?ignoreTimeline : Bool) : Bool;
	private var _delay : Float;
	private var _hasUpdate : Bool;
	private var _pauseTime : Float;
	private var _rawPrevTime : Float;
	private function setDirtyCache(?includeSelf : Bool) : Void;
	private function setTotalTime(time : Float, ?suppressEvents : Bool) : Void;
	static var version : Float;
}