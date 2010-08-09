package net.rezmason.utils {
	
	import flash.display.Shape;
	import flash.display.Graphics;
	
	public final class GraphicsUtils {
		
		// A utility function for making Graphics objects to store data.
		
		public static function makeGraphics(source:Graphics = null):Graphics {
			var returnVal:Graphics = new Shape().graphics;
			if (source)
				returnVal.copyFrom(source);
			return returnVal;
		}
	}
}