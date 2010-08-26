/**
* Wireworld Player by Jeremy Sachs. August 21, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld {

	//---------------------------------------
	// IMPORT STATEMENTS
	//---------------------------------------
	import flash.events.Event;
	
	public final class WWEvent extends Event {
		
		public static const DATA_PARSED:String = "dataParsed";
		public static const DATA_EXTRACTED:String = "dataExtracted";
		
		public static const MODEL_BUSY:String = "modelBusy";
		public static const MODEL_IDLE:String = "modelidle";
		
		public static const READY:String = "ready";
		
		public var value:*;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function WWEvent( type:String, val:* = null ) { 
			super(type);
			value = val;
		}
		
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		override public function clone():Event { return new WWEvent(type, value); }
		
	}
	
}

