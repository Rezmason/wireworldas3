/**
* Wireworld Player by Jeremy Sachs. July 25, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld;

// IMPORT STATEMENTS
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.TimerEvent;
import flash.geom.Rectangle;
import flash.utils.Timer;

class HaXeModel extends HaXeBaseModel {
	
	// PRIVATE PROPERTIES
	private var nodeTable:Array<HaXeNode>;
	
	// CONSTRUCTOR
	public function new():Void {
		super();
		nodeTable = [];
	}
	
}