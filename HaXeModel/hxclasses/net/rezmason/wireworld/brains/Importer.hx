package net.rezmason.wireworld.brains;

extern class Importer extends flash.events.EventDispatcher {
	var credit(default,null) : String;
	var height(default,null) : Int;
	var totalNodes(default,null) : Int;
	var width(default,null) : Int;
	function new() : Void;
	function dump() : Void;
	function extract(?extractFunc : Dynamic) : Void;
	function parse(txt : String, ?isMCell : Bool, ?callback : Dynamic) : Void;
}
