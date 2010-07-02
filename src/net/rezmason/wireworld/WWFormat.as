/**
* Wireworld Player by Jeremy Sachs. June 22, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld {
	
	// A bunch of constants used in various places.
	
	public final class WWFormat {

		internal static const WIRE:int = 0, HEAD:int = 1, TAIL:int = 2;
		
		internal static const WIRE_CHAR:String = '#', HEAD_CHAR:String = '@', TAIL_CHAR:String = '~', DEAD_CHAR:String = " ";
		internal static const ALIVE_REG_EXP:RegExp = new RegExp("[" + WIRE_CHAR + HEAD_CHAR + TAIL_CHAR + "]", "g");
		
		internal static const MAX_SIZE:int = 2880;
		
		internal static const CHAR_MAP:Object = {
			(WIRE_CHAR as String):WIRE,
			(HEAD_CHAR as String):HEAD,
			(TAIL_CHAR as String):TAIL
		}
		
		internal static const RED:uint = 0xFFFF0000, GREEN:uint = 0xFF00FF00, BLUE:uint = 0xFF0000FF;
		internal static const COLOR_MAP:Object = {
			(WIRE as int):RED,
			(HEAD as int):GREEN,
			(TAIL as int):BLUE
		}
		
		internal static const MCL_CONVERSION_TABLE:Object = {
			("A" as String):HEAD_CHAR,
			("B" as String):TAIL_CHAR,
			("C" as String):WIRE_CHAR,
			("." as String):DEAD_CHAR,
			("$" as String):"*"
		};
	}
}
