package net.rezmason.utils;

extern class GreenThread extends flash.events.EventDispatcher {
	var alive(default,null) : Bool;
	var condition : Dynamic;
	var delay : Int;
	var epilogue : Dynamic;
	var eventType : String;
	var id(default,null) : UInt;
	var interruptHandler : Dynamic;
	var interrupted(default,null) : Bool;
	var name : String;
	var prologue : Dynamic;
	var running(default,null) : Bool;
	var state(default,null) : Int;
	var taskFragment : Dynamic;
	var waiting(default,null) : Bool;
	function new(?frag : Dynamic, ?cond : Dynamic, ?prlg : Dynamic, ?hand : Dynamic, ?eplg : Dynamic, ?eType : String, ?tick : Int) : Void;
	function interrupt() : Void;
	function resume() : Void;
	function sleep(?ticks : UInt) : Void;
	function start() : Void;
	function suspend() : Void;
	function wait(?otherProcess : flash.events.EventDispatcher, ?etype : String) : Void;
	private function run(?event : flash.events.Event) : Void;
	static var State(default,null) : Class<Dynamic>;
}
