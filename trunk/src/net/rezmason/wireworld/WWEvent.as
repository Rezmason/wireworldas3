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
	
	internal final class WWEvent extends Event {
		
		public static const ANNOUNCER_SELECT:String = "announcerSelect";
		public static const ANNOUNCER_REMOVE:String = "announcerRemove";
		public static const ANNOUNCER_DROP  :String = "announcerDrop";
		
		public static const DATA_PARSED:String = "dataParsed";
		public static const DATA_EXTRACTED:String = "dataExtracted";
		
		public static const MODEL_BUSY:String = "modelBusy";
		public static const MODEL_IDLE:String = "modelidle";
		
		public static const READY:String = "ready";
		public static const PAUSE:String = "pause";
		public static const SAVE:String = "save";
		public static const STEP:String = "step";
		public static const TOGGLE_OVERDRIVE:String = "toggleOverdrive";
		public static const TOGGLE_PLAY_PAUSE:String = "togglePlayPause";
		public static const TOGGLE_HEAT:String = "toggleHeat";
		public static const ADJUST_SPEED:String = "adjustSpeed";
		public static const LOAD_FROM_DISK:String = "loadFromDisk";
		public static const LOAD_FROM_WEB:String = "loadFromWeb";
		public static const RESET:String = "reset";
		
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

