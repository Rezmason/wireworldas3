package net.rezmason.wireworld;

class HaXeNode {

	public var x:Int;
	public var y:Int;
	public var state:Int;
	public var firstState:Int;
	public var nextState:Int;

	public function new(__x:Int = 0, __y:Int = 0, __firstState:Int = 0):Void {
		x = __x;
		y = __y;
		firstState = __firstState;
	}
}