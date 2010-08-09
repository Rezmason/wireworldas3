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
	
	// PRIVATE PROPERTIES
	
	inline static var CLEAR:UInt = 0x00000000;
	inline static var BLACK:UInt = 0xFF000000;
	inline static var WHITE:UInt = 0xFFFFFFFF;
	
	inline static var INVALID_SIZE_ERROR:String = "Invalid dimensions.";
	inline static var INVALID_SIZE_ERROR_EVENT:ErrorEvent = new ErrorEvent(ErrorEvent.ERROR, false, false, INVALID_SIZE_ERROR);
	inline static var COMPLETE_EVENT:Event = new Event(Event.COMPLETE);
	
	inline static var MAX_SIZE:Int = 2880;
	
	inline static var WIRE:Int = 0;
	inline static var HEAD:Int = 1;
	inline static var TAIL:Int = 2;
	
	private var nodeTable:Array<Array<HaXeNode>>;
	
	// CONSTRUCTOR
	public function new():Void {
		super();
		nodeTable = [];
	}
	
	override public function update():Void {
		var ike:Int;
		var jen:Int;
		var ken:Int;
		var leo:Int;
		var scratch:Int;
		var iNode:HaXeNode;
		for (ike in 0..._height) {
			if (nodeTable[ike] == null) continue;
			for (jen in 0..._width) {
				iNode = nodeTable[ike][jen];
				if (iNode == null) continue;

				switch (iNode.state) {
					case WIRE:
						// count head neighbors; if it's one or two, nextState = HEAD
						scratch = 0;
						var broken:Bool = false;
						for (ken in Std.int(Math.max(0, ike - 1))...Std.int(Math.min(_height - 1, ike + 2))) {
							if (nodeTable[ken] == null) continue;
							broken = false;
							for (leo in Std.int(Math.max(0, jen - 1))...Std.int(Math.min(_width - 1, jen + 2))) {
								if (nodeTable[ken][leo] != null && nodeTable[ken][leo].state == HEAD) scratch++;
								if (scratch > 2) {
									broken = true;
									break;
								}
							}
							if (broken) break;
						}
						if (scratch == 1 || scratch == 2) iNode.nextState = HEAD;
					break;
					case HEAD: iNode.nextState = TAIL; break;
					case TAIL: iNode.nextState = WIRE; break;
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

	override public function eraseRect(rect:Rectangle):Void {
		// not implemented. Boo!
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

	override private function finishParse(event:Event):Void {
		var ike:Int;
		if (importer.width  > MAX_SIZE || importer.height  > MAX_SIZE || importer.width * importer.height < 1) {
			dispatchEvent(INVALID_SIZE_ERROR_EVENT);
			return;
		} else {
			_width = importer.width;
			_height = importer.height;
			_credit = importer.credit;

			// empty everything
			nodeTable = [];

			importer.extract(addNode);
		}
	}

	override private function finishExtraction(event:Event):Void {
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

	override private function addNode(__x:Int, __y:Int, __state:Int):Void {
		if (nodeTable[__y] == null) nodeTable[__y] = [];
		nodeTable[__y][__x] = new HaXeNode(__x, __y, __state);
	}

	override private function refreshHeat(fully:Int = 0):Void {
		// not implemented. Nyaahh!
	}

	override private function refreshImage(fully:Int = 0, freshTails:Int = 0):Void {
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
				if (iNode.state == HEAD) {
					_headData.setPixel32(jen, ike, BLACK);
				} else if (iNode.state == TAIL) {
					_tailData.setPixel32(jen, ike, BLACK);
				}
			}
		}
		_tailData.unlock();
		_headData.unlock();
	}
}