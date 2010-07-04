/**
* Wireworld Player by Jeremy Sachs. June 22, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld {
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;
	
	// Every model implements these methods, getters and setters.
	
	public interface IModel extends IEventDispatcher {
		function get initialized():Boolean;							// true if the Model has been inited at least once
		function get width():int;
		function get height():int;
		function get wireData():BitmapData; 						// black sillhouette of non-dead pixels
		function get headData():BitmapData; 						// black sillhouette of head pixels
		function get tailData():BitmapData; 						// black sillhouette of tail pixels
		function get credit():String
		function get generation():Number;
		function get baseGraphics():Graphics; 						// returns drawing procedure for default image
		function get wireGraphics():Graphics; 						// returns drawing procedure for dedicated wire image
		function get headGraphics():Graphics; 						// returns drawing procedure for dedicated head image
		function get tailGraphics():Graphics; 						// returns drawing procedure for dedicated tail image
		function get heatGraphics():Graphics;					 	// returns drawing procedure for dedicated heat image
		
		function get implementsOverdrive():Boolean; 				// returns true if the model has its own overdrive implementation
		function get overdriveActive():Boolean;
		function set overdriveActive(value:Boolean):void;
		
		function init(txt:String, isMCell:Boolean = false):void;
		function setBounds(t:int, l:int, b:int, r:int):void;		// changes the draw bounds
		function update():void; 									// creates the new state of the patch, increments the gen
		function refresh(flags:int = 0):void;			 			// redraws various data to the proper bitmaps
		function getState(__x:int, __y:int):uint; 					// returns the color of the patch at the specified point
		function reset():void; 										// sets the conditions of the IModel to their initial states, including the gen
		function eraseRect(rect:Rectangle):void;					// finds nodes in the region indicated by the Rectangle, and sets their state to WIRE
	}
}