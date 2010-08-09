package net.rezmason.wireworld.views;

extern class View extends flash.events.EventDispatcher, implements net.rezmason.wireworld.IView {
	var callback(null,default) : Void;
	var initialized(default,null) : Bool;
	function new(__model : net.rezmason.wireworld.IModel, __scene : flash.display.Sprite, __bridge : net.rezmason.gui.SimpleBridge) : Void;
	function addGUIEventListeners() : Void;
	function giveAlert(?titleText : String, ?messageText : String, ?interactive : Bool) : Void;
	function hideDialog(?target : flash.display.DisplayObject) : Void;
	function hideDisabler(?event : flash.events.Event, ?instantly : Bool) : Void;
	function prime() : Void;
	function resetState(?event : flash.events.Event) : Void;
	function resetView(?event : flash.events.Event) : Void;
	function resize(?event : flash.events.Event) : Void;
	function setFileName(__fileName : String) : Void;
	function showAbout(?event : flash.events.Event, ?interactive : Bool) : Void;
	function showDisabler(?event : flash.events.Event, ?instantly : Bool) : Void;
	function showLoading() : Void;
	function snapshot() : Void;
	function updateFPS(__fps : Int) : Void;
	function updateGeneration(gen : UInt) : Void;
	function updatePaper(?flags : Int) : Void;
}
