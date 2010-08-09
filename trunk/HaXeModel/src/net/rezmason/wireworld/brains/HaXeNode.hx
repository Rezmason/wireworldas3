/**
* Wireworld Player by Jeremy Sachs. July 25, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld.brains;

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