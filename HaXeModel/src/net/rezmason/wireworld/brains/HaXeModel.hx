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

class HaXeModel extends HaXeBaseModel {
	
	private var nodeTable:Array<Array<HaXeNode>>;
	
	// CONSTRUCTOR
	public function new():Void {
		super();
		nodeTable = [];
	}
	
	// PUBLIC METHODS
	
	override public function eraseRect(rect:flash.geom.Rectangle):Void {
		super.eraseRect(rect);
	}
	
	override public function getState(__x:Int, __y:Int):UInt {
		return super.getState(__x, __y);
	}
	
	override public function refresh(flags:Int):Void {
		super.refresh(flags);
	}
	
	override public function reset():Void {
		super.reset();
	}
	
	override public function update():Void {
		super.update();
	}
	
	// PRIVATE METHODS
	
	override function addNode(__x:Int, __y:Int, __state:Int):Void {
		super.addNode(__x, __y, __state);
	}
	
	override function finishExtraction(event:flash.events.Event):Void {
		super.finishExtraction(event);
	}
	
	override function finishParse(event:flash.events.Event):Void {
		super.finishParse(event);
	}
	
	override function refreshHeat(fully:Int):Void {
		super.refreshHeat(fully);
	}
	
	override function refreshImage(fully:Int, freshTails:Int):Void {
		super.refreshImage(fully, freshTails);
	}
}