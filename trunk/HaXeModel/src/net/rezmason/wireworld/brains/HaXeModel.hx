/**
* Wireworld Player by Jeremy Sachs. July 25, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld.brains;

// IMPORT STATEMENTS
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.TimerEvent;
import flash.geom.Rectangle;
import flash.utils.Timer;
import flash.events.ErrorEvent;

import net.rezmason.wireworld.WWRefreshFlag;

class HaXeModel extends BaseModel, implements net.rezmason.wireworld.IModel {
	
	private var nodeTable:Array<Array<HaXeNode>>;
	
	// CONSTRUCTOR
	public function new():Void {
		super();
		nodeTable = [];
	}
	
	// PUBLIC METHODS
	
	override public function eraseRect(rect:flash.geom.Rectangle):Void {
		
	}
	
	override public function getState(__x:Int, __y:Int):UInt {
		return 0;
	}
	
	override public function refresh(flags:Int):Void {
		
	}
	
	override public function reset():Void {
		
	}
	
	override public function update():Void {
		
	}
	
	// PRIVATE METHODS
	
	override function addNode(__x:Int, __y:Int, __state:Int):Void {
		
	}
	
	override function finishExtraction(event:flash.events.Event):Void {
		
	}
	
	override function finishParse(event:flash.events.Event):Void {
		
	}
	
	override function refreshHeat(fully:Int):Void {
		
	}
	
	override function refreshImage(fully:Int, freshTails:Int):Void {
		
	}
}