package net.rezmason.gui;

extern class SimpleBridge extends flash.events.EventDispatcher {
	var eventTypes : Dynamic;
	var state : Dynamic;
	function new(?target : flash.events.IEventDispatcher) : Void;
}
