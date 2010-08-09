package net.rezmason.wireworld;

extern interface IView implements flash.events.IEventDispatcher {
	var callback(null,default) : Void;
	var initialized(default,null) : Bool;
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
	function updateFPS(__fps : Int) : Void;
	function updateGeneration(gen : UInt) : Void;
	function updatePaper(?flags : Int) : Void;
}
