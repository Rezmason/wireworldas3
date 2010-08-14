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

class FirstHaXeModel extends HaXeBaseModel {
	
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
		var ike:Int;
		var jen:Int;
		var iNode:HaXeNode;
		for (ike in 0..._height) {
			for (jen in 0..._width) {
				if (nodeTable[ike] == null) continue;
				iNode = nodeTable[ike][jen];
				if (iNode != null) iNode.state = iNode.firstState;
			}
		}
		refresh(WWRefreshFlag.FULL | WWRefreshFlag.TAIL);

		_generation = 1;
	}
	
	override public function update():Void {
		var ike:Int;
		var jen:Int;
		var ken:Int;
		var leo:Int;
		var scratch:Int;
		var iNode:HaXeNode;
		var forgetIt:Bool;

		for (ike in 0..._height) {
			if (nodeTable[ike] == null) continue;
			for (jen in 0..._width) {
				iNode = nodeTable[ike][jen];
				if (iNode == null) continue;
				if (iNode.state == WWFormat.WIRE) {
					// count head neighbors; if it's one or two, nextState = HEAD
					scratch = 0;
					forgetIt = false;
					for (ken in Std.int(Math.max(0, ike - 1))...Std.int(Math.min(_height - 1, ike + 2))) {
						if (nodeTable[ken] == null) continue;
						for (leo in Std.int(Math.max(0, jen - 1))...Std.int(Math.min(_width - 1, jen + 2))) {
							if (nodeTable[ken][leo] != null && nodeTable[ken][leo].state == WWFormat.HEAD) scratch++;
							if (scratch > 2) {
								forgetIt = true;
								break;
							}
						}
						if (forgetIt) break;
					}
					if (scratch == 1 || scratch == 2) {
						iNode.nextState = WWFormat.HEAD;
					} else {
						iNode.nextState = WWFormat.WIRE;
					}
				} else if (iNode.state == WWFormat.HEAD) {
					iNode.nextState = WWFormat.TAIL;
				} else if (iNode.state == WWFormat.TAIL) {
					iNode.nextState = WWFormat.WIRE;
				}
			}
		}
		
		for (ike in 0..._height) {
			if (nodeTable[ike] == null) continue;
			for (jen in 0..._width) {
				iNode = nodeTable[ike][jen];
				if (iNode != null) {
					iNode.state = iNode.nextState;
				}
			}
		}

		_generation++;
	}
	
	// PRIVATE METHODS
	
	override function addNode(__x:Int, __y:Int, __state:Int):Void {
		if (nodeTable[__y] == null) nodeTable[__y] = [];
		nodeTable[__y][__x] = new HaXeNode(__x, __y, __state);
		totalNodes++;
	}
	
	override function finishExtraction(event:flash.events.Event):Void {
		var ike:Int;
		var jen:Int;

		if (_wireData != null) _wireData.dispose();
		if (_headData != null) _wireData.dispose();
		if (_tailData != null) _wireData.dispose();
		if (_heatData != null) _wireData.dispose();

		_wireData = new BitmapData(_width, _height, true, CLEAR);
		_headData = _wireData.clone();
		_tailData = _wireData.clone();

		drawBackground(_baseGraphics, _width, _height, BLACK);
		drawData(_wireGraphics, _wireData.rect, _wireData);
		drawData(_headGraphics, _headData.rect, _headData);
		drawData(_tailGraphics, _tailData.rect, _tailData);

		// draw wires
		for (ike in 0..._height) {
			for (jen in 0..._width) {
				if (nodeTable[ike] != null && nodeTable[ike][jen] != null) {
					_wireData.setPixel32(jen, ike, BLACK);
				}
			}
		}

		dispatchEvent(COMPLETE_EVENT);
	}
	
	override function finishParse(event:flash.events.Event):Void {
		var ike:Int;
		if (importer.width  > WWFormat.MAX_SIZE || importer.height  > WWFormat.MAX_SIZE || importer.width * importer.height < 1) {
			dispatchEvent(INVALID_SIZE_ERROR_EVENT);
			return;
		} else {
			_width = importer.width;
			_height = importer.height;
			_credit = importer.credit;

			// empty everything
			while (nodeTable.length > 0) {
				var row:Array<HaXeNode> = nodeTable.pop();
				row.splice(0, row.length);
			}
			
			importer.extract(addNode);
		}
	}
	
	override function refreshHeat(fully:Int):Void {
		super.refreshHeat(fully);
	}
	
	override function refreshImage(fully:Int, freshTails:Int):Void {
		var ike:Int;
		var jen:Int;
		var iNode:HaXeNode;

		_tailData.lock();
		_headData.lock();

		_headData.fillRect(_headData.rect, 0x0);
		_tailData.fillRect(_tailData.rect, 0x0);

		for (ike in 0..._height) {
			if (nodeTable[ike] == null) continue;
			for (jen in 0..._width) {
				iNode = nodeTable[ike][jen];
				if (iNode == null) continue;
				if (iNode.state == WWFormat.HEAD) {
					_headData.setPixel32(jen, ike, BLACK);
				} else if (iNode.state == WWFormat.TAIL) {
					_tailData.setPixel32(jen, ike, BLACK);
				}
			}
		}
		_tailData.unlock();
		_headData.unlock();
	}
}