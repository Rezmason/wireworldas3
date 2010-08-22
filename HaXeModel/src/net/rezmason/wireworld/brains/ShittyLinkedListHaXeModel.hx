/**
* Wireworld Player by Jeremy Sachs. August 21, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld.brains;

// IMPORT STATEMENTS
import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.Lib;

import net.rezmason.wireworld.WWRefreshFlag;
import net.rezmason.utils.GreenThread;

class ShittyLinkedListHaXeModel extends HaXeBaseModel {
	
	inline static var SURVEY_TEMPLATE:Array<Int> = [0, 0, 0, 0, 0, 0, 0, 0, 0];
	
	inline static var NULL:ShittyHaXeNode = new ShittyHaXeNode(-1, -1, -1);
	
	private var neighborLookupTable:Array<ShittyHaXeNode>; // sparse array of all nodes, listed by index
	private var pool:Array<ShittyHaXeNode>; // vector of all nodes
	private var tempVec:Array<ShittyHaXeNode>;
	private var totalHeads:Int;
	private var staticSurvey:Array<Int>;
	private var neighborThread:GreenThread;

	private var heads:List<ShittyHaXeNode>;		// nodes that are currently electron heads
	private var tails:List<ShittyHaXeNode>;		// nodes that are currently electron tails
	private var newHeads:List<ShittyHaXeNode>;	// nodes that are becoming  electron heads
	
	private var pItr:Int;
			
	// CONSTRUCTOR
	public function new():Void {
		super();
		
		neighborLookupTable = [];
		pool = [];
		neighborThread = new GreenThread();
		heads = new List<ShittyHaXeNode>();
		tails = new List<ShittyHaXeNode>();
		newHeads = new List<ShittyHaXeNode>();
		
		neighborThread.taskFragment = partialFindNeighbors;
		neighborThread.condition = checkFindNeighbors;
		neighborThread.prologue = beginFindNeighbors;
		neighborThread.epilogue = finishFindNeighbors;
	}
	
	// PUBLIC METHODS
	
	override public function eraseRect(rect:flash.geom.Rectangle):Void {
		var iNode:ShittyHaXeNode;
		
		// correct the offset
		rect.x -= activeRect.x + 0.5;
		rect.y -= activeRect.y + 0.5;
		
		// clear heads whose centers are within eraseRect
		for (iNode in heads) {
			if (rect.contains(iNode.x, iNode.y)) {
				iNode.isWire = true;
				heads.remove(iNode);
				_heatData.setPixel32(Std.int(iNode.x), Std.int(iNode.y), 0xFF000800);
			}
		}

		// clear tails whose centers are within eraseRect
		for (iNode in tails) {
			if (rect.contains(iNode.x, iNode.y)) {
				iNode.isWire = true;
				tails.remove(iNode);
				_heatData.setPixel32(iNode.x, iNode.y, 0xFF000800);
			}
		}
	}
	
	override public function getState(__x:Int, __y:Int):UInt {
		return super.getState(__x, __y);
	}
	
	override public function reset():Void {
		var iNode:ShittyHaXeNode;
		// empty lists
		heads.clear();
		tails.clear();
		newHeads.clear();

		pItr = 0;
		
		while (pItr < totalNodes) {
			iNode = pool[pItr];
			iNode.timesLit = 0;

			switch (iNode.firstState) {
				case WWFormat.HEAD:
					iNode.isWire = false;
					heads.push(iNode);
					iNode.timesLit++;
				case WWFormat.TAIL:
					iNode.isWire = false;
					tails.push(iNode);
				case WWFormat.WIRE:
					iNode.isWire = true;
			}

			pItr++;
		}
		
		_heatData.fillRect(_heatData.rect, CLEAR);
		refresh(WWRefreshFlag.FULL | WWRefreshFlag.TAIL);

		_generation = 1;
	}
	
	override public function update():Void {
		var ike:Int;
		var iNode:ShittyHaXeNode;
		var jNode:ShittyHaXeNode;
		var scratch:Int;

		// find new heads in current head neighbors (and list them)

		//		first, list all wires that are adjacent to heads
		for (iNode in heads) {
			scratch = iNode.neighbors.length;
			for (ike in 0...scratch) {
				jNode = iNode.neighbors[ike];
				if (jNode.isWire) {
					if (jNode.taps == 0) {
						newHeads.push(jNode);
					}
					jNode.taps++;
				}
			}
		}

		//		then, remove from the list all nodes with more than two head neighbors
		for (iNode in newHeads) {
			if (iNode.taps > 2) {
				newHeads.remove(iNode);
			}
			iNode.taps = 0;
		}

		totalHeads = newHeads.length;
		
		// change states

		for (iNode in tails) {
			iNode.isWire = true;
		}

		for (iNode in newHeads) {
			iNode.isWire = false;
			iNode.timesLit++;
		}

		// swap the linked lists
		var temp:List<ShittyHaXeNode> = tails;
		tails = heads;
		heads = newHeads;
		newHeads = temp;
		newHeads.clear();

		_generation++;
	}
	
	// OVERRIDDEN PRIVATE METHODS
	
	override function addNode(__x:Int, __y:Int, __state:Int):Void {
		pool.push(neighborLookupTable[__x + _width * __y] = new ShittyHaXeNode(__x, __y, __state));
	}
	
	override function finishExtraction(event:flash.events.Event):Void {
		importer.dump();
		totalNodes = pool.length;
		neighborThread.start();
	}
	
	override function finishParse(event:flash.events.Event):Void {
		if (importer.width  > WWFormat.MAX_SIZE || importer.height  > WWFormat.MAX_SIZE || importer.width * importer.height < 1) {
			dispatchEvent(INVALID_SIZE_ERROR_EVENT);
		} else {
			_width = importer.width;
			_height = importer.height;
			_credit = importer.credit;
		
			neighborLookupTable.splice(0, neighborLookupTable.length);
			pItr = 0;
			pool.splice(0, totalNodes);
			
			importer.extract(addNode);
		}
	}
	
	override function refreshHeat(fully:Int):Void {
		var iNode:ShittyHaXeNode;
		var allow:Bool;
		var x_:Int;
		var y_:Int;
		var mult:Float = 2.9 / _generation;
		_heatData.lock();
		for (iNode in heads) {
			x_ = iNode.x;
			y_ = iNode.y;
			allow = (fully > 0) || (x_ >= leftBound && x_ < rightBound && y_ >= topBound && y_ < bottomBound);
			if (allow) _heatData.setPixel32(x_, y_, heatSpectrum.colorOf(iNode.timesLit * mult, false));
		}
		_heatData.unlock();
	}
	
	override function refreshImage(fully:Int, freshTails:Int):Void {
		var iNode:ShittyHaXeNode;
		var allow:Bool;
		var x_:Int;
		var y_:Int;

		_tailData.lock();
		_headData.lock();
		if (freshTails > 0) {

			_tailData.fillRect(fully > 0 ? _tailData.rect : bound, CLEAR);

			for (iNode in tails) {
				x_ = iNode.x;
				y_ = iNode.y;
				allow = (fully > 0) || (x_ >= leftBound && x_ < rightBound && y_ >= topBound && y_ < bottomBound);
				if (allow) _tailData.setPixel32(x_, y_, BLACK);
			}

		} else {
			_tailData.copyPixels(_headData, fully > 0 ? _tailData.rect : bound, fully > 0 ? ORIGIN : bound.topLeft);
		}

		_headData.fillRect(fully > 0 ? _headData.rect : bound, CLEAR);

		for (iNode in heads) {
			x_ = iNode.x;
			y_ = iNode.y;
			allow = (fully > 0) || (x_ >= leftBound && x_ < rightBound && y_ >= topBound && y_ < bottomBound);
			if (allow) _headData.setPixel32(x_, y_, BLACK);
		}
		_tailData.unlock();
		_headData.unlock();
	}
	
	// PRIVATE METHODS
	
	private function beginFindNeighbors():Void {
		staticSurvey = SURVEY_TEMPLATE.slice(0);
		pItr = 0;
	}

	private function checkFindNeighbors():Bool {
		return (pItr < totalNodes);
	}

	private function partialFindNeighbors():Void {
		var ike:Int;
		var iNode:HaXeNode;
		var row:Int;
		var node:HaXeNode;
		var scratch:Int;
		
		ike = 0;
		while (ike < STEP && pItr < totalNodes) {
			iNode = pool[pItr];
			tempVec = iNode.neighbors;
			row = iNode.y;
			scratch = iNode.x + row * _width;

			scratch -= _width; row--;
			node = neighborLookupTable[scratch - 1];	if (node != null && node.y == row) tempVec.push(node);
			node = neighborLookupTable[scratch];		if (node != null && node.y == row) tempVec.push(node);
			node = neighborLookupTable[scratch + 1]; 	if (node != null && node.y == row) tempVec.push(node);

			scratch += _width; row++;
			node = neighborLookupTable[scratch - 1];	if (node != null && node.y == row) tempVec.push(node);
			node = neighborLookupTable[scratch + 1];	if (node != null && node.y == row) tempVec.push(node);

			scratch += _width; row++;
			node = neighborLookupTable[scratch - 1];	if (node != null && node.y == row) tempVec.push(node);
			node = neighborLookupTable[scratch];		if (node != null && node.y == row) tempVec.push(node);
			node = neighborLookupTable[scratch + 1];	if (node != null && node.y == row) tempVec.push(node);
			
			staticSurvey[tempVec.length]++;
			pItr++;
			
			ike += 1;
		}
	}
	
	private function finishFindNeighbors():Void {
		neighborLookupTable.splice(0, neighborLookupTable.length);

		initDrawData(); // This sounds like it should belong in the View, but it really doesn't.

		Lib.trace(totalNodes + " total nodes");
		Lib.trace("staticSurvey: " + staticSurvey);
		Lib.trace("1-2: " + staticSurvey[1] + " " + staticSurvey[2]);
		Lib.trace("3-4: " + staticSurvey[3] + " " + staticSurvey[4]);
		Lib.trace("5-7: " + staticSurvey[5] + " " + staticSurvey[6] + " " + staticSurvey[7]);
		
		dispatchEvent(COMPLETE_EVENT);
	}
	
	private function initDrawData():Void {
		var iNode:ShittyHaXeNode;
		activeRect.setEmpty();
		pItr = 0;
		while (pItr < totalNodes) {
			iNode = pool[pItr];
			if (activeRect.isEmpty()) {
				activeRect.left = iNode.x;
				activeRect.top = iNode.y;
				activeRect.width = 1;
				activeRect.height = 1;
			} else {
				activeRect.left = Math.min(activeRect.left, iNode.x);
				activeRect.top = Math.min(activeRect.top, iNode.y);
				activeRect.right = Math.max(activeRect.right, iNode.x + 1);
				activeRect.bottom = Math.max(activeRect.bottom, iNode.y + 1);
			}

			activeCorner.x = activeRect.left;
			activeCorner.y = activeRect.top;

			pItr++;
		}

		if (_wireData != null) _wireData.dispose();
		if (_headData != null) _wireData.dispose();
		if (_tailData != null) _wireData.dispose();
		if (_heatData != null) _wireData.dispose();
		
		// The BitmapData objects only need to be as large as the active rectangle.
		_wireData = new BitmapData(Std.int(activeRect.width), Std.int(activeRect.height), true, CLEAR);
		_headData = new BitmapData(Std.int(activeRect.width), Std.int(activeRect.height), true, CLEAR);
		_tailData = new BitmapData(Std.int(activeRect.width), Std.int(activeRect.height), true, CLEAR);
		_heatData = new BitmapData(Std.int(activeRect.width), Std.int(activeRect.height), true, CLEAR);

		drawBackground(_baseGraphics, _width, _height, BLACK);
		drawData(_wireGraphics, activeRect, _wireData);
		drawData(_headGraphics, activeRect, _headData);
		drawData(_tailGraphics, activeRect, _tailData);
		drawData(_heatGraphics, activeRect, _heatData);

		pItr = 0;
		while (pItr < totalNodes) {
			iNode = pool[pItr];
			iNode.x -= Std.int(activeRect.x);
			iNode.y -= Std.int(activeRect.y);
			_wireData.setPixel32(iNode.x, iNode.y, BLACK);
			pItr++;
		}
	}
}