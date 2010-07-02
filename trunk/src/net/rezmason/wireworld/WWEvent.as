/**
* Wireworld Player by Jeremy Sachs. June 22, 2010
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
	
	internal final class WWEvent extends Event {
		
		internal static const ANNOUNCER_SELECT:String = "announcerSelect";
		internal static const ANNOUNCER_REMOVE:String = "announcerRemove";
		internal static const ANNOUNCER_DROP  :String = "announcerDrop";
		
		internal static const DATA_PARSED:String = "dataParsed";
		internal static const DATA_EXTRACTED:String = "dataExtracted";
		
		internal static const MODEL_BUSY:String = "modelBusy";
		internal static const MODEL_IDLE:String = "modelidle";
		
		internal static const READY:String = "ready";
		
		internal var value:*;
		
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

