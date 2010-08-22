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

class LinkedListHaXeModel extends HaXeBaseModel {
	
	private var SURVEY_TEMPLATE:Array<Int>;
	private var NULL:HaXeNode;
	
	private var neighborLookupTable:Array<HaXeNode>; // sparse array of all nodes, listed by index
	private var pool:Array<HaXeNode>; // vector of all nodes
	private var tempVec:Array<HaXeNode>;
	private var totalHeads:Int;
	private var staticSurvey:Array<Int>;
	private var neighborThread:GreenThread;
	
	// linked list of nodes that are currently electron heads
	private var headFront:HaXeNode;
	private var headBack:HaXeNode;
	
	// linked list of nodes that are currently electron tails
	private var tailFront:HaXeNode;
	private var tailBack:HaXeNode;
	
	// linked list of nodes that are becoming electron heads
	private var newHeadFront:HaXeNode;
	private var newHeadBack:HaXeNode;
	
	private var pItr:Int;
			
	// CONSTRUCTOR
	public function new():Void {
		super();
		
		SURVEY_TEMPLATE = [0, 0, 0, 0, 0, 0, 0, 0, 0];
		NULL = new HaXeNode(-1, -1, -1);
		
		neighborLookupTable = [];
		pool = [];
		neighborThread = new GreenThread();
		
		headFront = NULL;
		headBack = NULL;
		tailFront = NULL;
		tailBack = NULL;
		newHeadFront = NULL;
		newHeadBack = NULL;
		
		neighborThread.taskFragment = partialFindNeighbors;
		neighborThread.condition = checkFindNeighbors;
		neighborThread.prologue = beginFindNeighbors;
		neighborThread.epilogue = finishFindNeighbors;
	}
	
	// PUBLIC METHODS
	
	override public function eraseRect(rect:flash.geom.Rectangle):Void {
		var iNode:HaXeNode;
		var jNode:HaXeNode;
		
		// correct the offset
		rect.x -= activeRect.x + 0.5;
		rect.y -= activeRect.y + 0.5;
		
		// clear heads whose centers are within eraseRect
		iNode = headFront;
		while (iNode.next != NULL) {
			jNode = iNode.next;
			if (rect.contains(jNode.x, jNode.y)) {
				jNode.isWire = true;
				iNode.next = jNode.next;
				_heatData.setPixel32(jNode.x, jNode.y, 0xFF008000);
			} else {
				iNode = jNode;
			}
		}
		
		// clear tails whose centers are within eraseRect
		iNode = tailFront;
		while (iNode.next != NULL) {
			jNode = iNode.next;
			if (rect.contains(jNode.x, jNode.y)) {
				jNode.isWire = true;
				iNode.next = jNode.next;
				_heatData.setPixel32(jNode.x, jNode.y, 0xFF008000);
			} else {
				iNode = jNode;
			}
		}
	}
	
	override public function getState(__x:Int, __y:Int):UInt {
		__x -= Std.int(activeRect.x);
		__y -= Std.int(activeRect.y);
		return _headData.getPixel32(__x, __y) | _tailData.getPixel32(__x, __y);
	}
	
	override public function reset():Void {
		var iNode:HaXeNode;
		// empty lists
		emptyList(headFront);
		emptyList(tailFront);
		emptyList(newHeadFront);
		// repopulate
		headBack = headFront = NULL;
		tailBack = tailFront = NULL;
		
		pItr = 0;
		while (pItr < totalNodes) {
			iNode = pool[pItr];
			iNode.timesLit = 0;
			
			switch (iNode.firstState) {
				case WWFormat.HEAD:
					iNode.isWire = false;
					if (headFront == NULL) {
						headFront = iNode;
					} else {
						headBack.next = iNode;
					}
					headBack = iNode;
					iNode.timesLit++;
				case WWFormat.TAIL:
					iNode.isWire = false;
					if (tailFront == NULL) {
						tailFront = iNode;
					} else {
						tailBack.next = iNode;
					}
					tailBack = iNode;
				case WWFormat.WIRE:
					iNode.isWire = true;
			}
			
			pItr++;
		}
		
		if (headBack != NULL) {
			headBack.next = NULL;
		}
		if (tailBack != NULL) {
			tailBack.next = NULL;
		}

		_heatData.fillRect(_heatData.rect, CLEAR);
		refresh(WWRefreshFlag.FULL | WWRefreshFlag.TAIL);
		
		_generation = 1;
	}
	
	override public function update():Void {
		var ike:Int;
		var iNode:HaXeNode;
		var jNode:HaXeNode;
		var scratch:Int;
		
		// find new heads in current head neighbors (and list them)
		
		//		first, list all wires that are adjacent to heads
		iNode = headFront;
		while (iNode != NULL) {
			scratch = iNode.neighbors.length;
			for (ike in 0...scratch) {
				jNode = iNode.neighbors[ike];
				if (jNode.isWire) {
					if (jNode.taps == 0) {
						if (newHeadFront == NULL) {
							newHeadFront = jNode;
						} else {
							newHeadBack.next = jNode;
						}
						newHeadBack = jNode;
					}
					jNode.taps++;
				}
			}
			iNode = iNode.next;
		}
		if (newHeadBack != NULL) {
			newHeadBack.next = NULL;
		}
		
		//		then, remove from the list all nodes with more than two head neighbors
		iNode = newHeadFront;
		while (iNode != NULL) {
			if (iNode.taps > 2) {
				newHeadFront = iNode.next;
				iNode.taps = 0;
				iNode = iNode.next;
			} else {
				iNode.taps = 0;
				break;
			}
		}
		
		totalHeads = 0;
		
		if (iNode != NULL) {
			jNode = iNode.next;
			while (jNode != NULL) {
				if (jNode.taps > 2) {
					iNode.next = jNode.next;
				} else {
					totalHeads++;
					iNode = jNode;
				}
				jNode.taps = 0;
				jNode = jNode.next;
			}
		}
		
		// change states
		
		iNode = tailFront;
		while (iNode != NULL) {
			iNode.isWire = true;
			iNode = iNode.next;
		}
		
		iNode = newHeadFront;
		while (iNode != NULL) {
			iNode.isWire = false;
			iNode.timesLit++;
			iNode = iNode.next;
		}
		
		// swap the linked lists
		tailFront = headFront;
		headFront = newHeadFront;
		newHeadBack = newHeadFront = NULL;
		
		_generation++;
	}
	
	// OVERRIDDEN PRIVATE METHODS
	
	override function addNode(__x:Int, __y:Int, __state:Int):Void {
		pool.push(neighborLookupTable[__x + _width * __y] = new HaXeNode(__x, __y, __state));
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
			while (pItr < totalNodes) {
				pool[pItr].next = NULL;
				pItr++;
			}
			pool.splice(0, totalNodes);
			
			importer.extract(addNode);
		}
	}
	
	override function refreshHeat(fully:Int):Void {
		var iNode:HaXeNode;
		var allow:Bool;
		var x_:Int;
		var y_:Int;
		var mult:Float = 2.9 / _generation;
		_heatData.lock();
		iNode = headFront;
		while (iNode != NULL) {
			x_ = iNode.x;
			y_ = iNode.y;
			allow = (fully > 0) || (x_ >= leftBound && x_ < rightBound && y_ >= topBound && y_ < bottomBound);
			if (allow) _heatData.setPixel32(x_, y_, heatSpectrum.colorOf(iNode.timesLit * mult, false));
			iNode = iNode.next;
		}
		_heatData.unlock();
	}
	
	override function refreshImage(fully:Int, freshTails:Int):Void {
		var iNode:HaXeNode;
		var allow:Bool;
		var x_:Int;
		var y_:Int;
		
		_tailData.lock();
		_headData.lock();
		if (freshTails > 0) {
			
			_tailData.fillRect((fully > 0) ? _tailData.rect : bound, CLEAR);
			
			iNode = tailFront;
			while (iNode != NULL) {
				x_ = iNode.x;
				y_ = iNode.y;
				allow = (fully > 0) || (x_ >= leftBound && x_ < rightBound && y_ >= topBound && y_ < bottomBound);
				if (allow) _tailData.setPixel32(x_, y_, BLACK);
				iNode = iNode.next;
			}
			
		} else {
			_tailData.copyPixels(_headData, (fully > 0) ? _tailData.rect : bound, (fully > 0) ? ORIGIN : bound.topLeft);
		}
		
		_headData.fillRect((fully > 0) ? _headData.rect : bound, CLEAR);
		
		iNode = headFront;
		while (iNode != NULL) {
			x_ = iNode.x;
			y_ = iNode.y;
			allow = (fully > 0) || (x_ >= leftBound && x_ < rightBound && y_ >= topBound && y_ < bottomBound);
			if (allow) _headData.setPixel32(x_, y_, BLACK);
			iNode = iNode.next;
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
		
		//Lib.trace(totalNodes + " total nodes");
		Lib.trace("staticSurvey: " + staticSurvey);
		Lib.trace("1-2: " + Std.int(staticSurvey[1] + staticSurvey[2]));
		Lib.trace("3-4: " + Std.int(staticSurvey[3] + staticSurvey[4]));
		Lib.trace("5-7: " + Std.int(staticSurvey[5] + staticSurvey[6] + staticSurvey[7]));
		
		dispatchEvent(COMPLETE_EVENT);
	}
	
	private function initDrawData():Void {
		var iNode:HaXeNode;
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
	
	private function emptyList(node:HaXeNode):Void {
		var iNode:HaXeNode;
		var jNode:HaXeNode;
		iNode = node;
		while (iNode != NULL) {
			jNode = iNode.next;
			iNode.next = NULL;
			iNode = jNode;
		}
	}
}