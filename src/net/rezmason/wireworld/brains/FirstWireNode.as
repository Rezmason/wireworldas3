/**
* Wireworld Player by Jeremy Sachs. June 22, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld.brains {
	
	// FirstWireNodes represent individual cells in the FirtModel.
	
	internal final class FirstWireNode {
		
		//---------------------------------------
		// INTERNAL VARIABLES
		//---------------------------------------
		
		internal var x:int, y:int, state:int, firstState:int, nextState:int;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function FirstWireNode(__x:int = 0, __y:int = 0, __firstState:int = 0):void {
			x = __x;
			y = __y;
			firstState = __firstState;
		}
	}
}
