/**
* Wireworld Player by Jeremy Sachs. June 8, 2010
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
	
	internal final class WireworldEvent extends Event {
		
		public static const ANNOUNCER_SELECT:String = "announcerSelect";
		public static const ANNOUNCER_REMOVE:String = "announcerRemove";
		public static const ANNOUNCER_DROP  :String = "announcerDrop";
		
		public static const DATA_PARSED:String = "dataParsed";
		public static const DATA_EXTRACTED:String = "dataExtracted";
		
		public static const MODEL_BUSY:String = "modelBusy";
		public static const MODEL_IDLE:String = "modelidle";
		
		public var value:Number;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function WireworldEvent( type:String, val:Number = NaN) { super(type); value = val; }
		
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		override public function clone():Event { return new WireworldEvent(type, value); }
		
	}
	
}

