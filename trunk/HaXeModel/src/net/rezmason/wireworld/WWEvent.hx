package net.rezmason.wireworld;

extern class WWEvent extends flash.events.Event {
	var value : Dynamic;
	function new(type : String, ?val : Dynamic) : Void;
	static var ANNOUNCER_DROP : String;
	static var ANNOUNCER_REMOVE : String;
	static var ANNOUNCER_SELECT : String;
	static var DATA_EXTRACTED : String;
	static var DATA_PARSED : String;
	static var MODEL_BUSY : String;
	static var MODEL_IDLE : String;
	static var READY : String;
}
