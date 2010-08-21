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
import flash.geom.Rectangle;
import flash.Lib;
import flash.Memory;
import flash.utils.ByteArray;
import flash.utils.Endian;

import net.rezmason.wireworld.WWRefreshFlag;
import net.rezmason.utils.GreenThread;

class MemoryHaXeModel extends HaXeBaseModel {
	
	inline static var EMPTY_SURVEY:Array<Int>= [0, 0, 0, 0, 0, 0, 0, 0, 0];
	inline static var NULL:Int = -1;
	inline static var BACKWARDS_BLACK:Int = 0xFF;
	inline static var BYTE_SIZE:Int = 1;
	inline static var SHORT_SIZE:Int = 2;
	inline static var INT_SIZE:Int = 4;
	
	//	NAME			TYPE			BINARY DATA TYPE	BYTE	OFFSET
	//	isWire			Bool			byte				1		0
	//	next			WireNode		int					4		1
	//	timesLit		int				int					4		5
	//	taps			int				byte				1		9
	//	x				int				short				2		10
	//	y				int				short				2		12
	//	firstState		int				byte				1		14
	//	neighborCount	int				byte				1		15
	//	neighborList	Array<int>	int * 8				4 * 8	16
	//	nodeSize													48
	
	// offsets- properties of a node, spaced apart sequentially in the ByteArray
	
	inline static var IS_WIRE__:Int = 0;
	inline static var NEXT__:Int = IS_WIRE__ + BYTE_SIZE;
	inline static var TIMES_LIT__:Int = NEXT__ + INT_SIZE;
	inline static var TAPS__:Int = TIMES_LIT__ + INT_SIZE;
	inline static var X__:Int = TAPS__ + BYTE_SIZE;
	inline static var Y__:Int = X__ + SHORT_SIZE;
	inline static var FIRST_STATE__:Int = Y__ + SHORT_SIZE;
	inline static var NEIGHBOR_COUNT__:Int = FIRST_STATE__ + BYTE_SIZE;
	inline static var NEIGHBOR_LIST__:Int = NEIGHBOR_COUNT__ + BYTE_SIZE;
	
	inline static var NODE_SIZE:Int = NEIGHBOR_LIST__ + 8 * INT_SIZE;
	inline static var MIN_BYTEARRAY_SIZE:Int = 1024;

	private var boundIsDirty:Bool;
	private var neighborLookupTable:Array<Null<Int>>;
	private var totalBytes:Int;
	private var bufferOffset:Int;
	private var totalHeads:Int;
	private var staticSurvey:Array<Int>;
	private var neighborThread:GreenThread;
	private var headFront:Int;
	private var headBack:Int;
	private var tailFront:Int;
	private var tailBack:Int;
	private var newHeadFront:Int;
	private var newHeadBack:Int;
	private var bytes:ByteArray;
	private var neighborItr:Int;
	
	private var transferBuffer:ByteArray;
	private var emptyBuffer:ByteArray;
	
	// CONSTRUCTOR
	public function new():Void {
		super();
		
		neighborLookupTable = []; // sparse array of all nodes, listed by index
		// NOTE: The neighbor lookup table is an Array because it's sparse, it's boundless, and because we only use it for parsing.
		neighborThread = new GreenThread(); // The green thread that drives the neighbor finding algorithm

		// linked list of nodes that are currently electron heads
		headFront = NULL;
		headBack = NULL;

		// linked list of nodes that are currently electron tails
		tailFront = NULL;
		tailBack = NULL;

		// linked list of nodes that are becoming electron heads
		newHeadFront = NULL;
		newHeadBack = NULL;

		bytes = new ByteArray();
		transferBuffer = new ByteArray();
		emptyBuffer = new ByteArray();
		
		// init the ByteArray.
		bytes.endian = Endian.LITTLE_ENDIAN;
		bytes.length = 1024;
		Memory.select(bytes);
		
		// Set up the neighbor thread.
		neighborThread.taskFragment = partialFindNeighbors;
		neighborThread.condition = checkFindNeighbors;
		neighborThread.prologue = beginFindNeighbors;
		neighborThread.epilogue = finishFindNeighbors;
	}
	
	// PUBLIC METHODS
	
	override public function eraseRect(rect:flash.geom.Rectangle):Void {
		var iNode:Int;
		var x_:Int;
		var y_:Int;
		// correct the offset
		rect.x -= activeRect.x + 0.5;
		rect.y -= activeRect.y + 0.5;
		
		// find heads whose centers are NOT within eraseRect
		totalHeads = 0;
		iNode = headFront;
		while (iNode != NULL) {
			x_ = Memory.getUI16(iNode + X__);
			y_ = Memory.getUI16(iNode + Y__);
			if (rect.contains(x_, y_)) {
				Memory.setByte(iNode + IS_WIRE__, 1);
				_heatData.setPixel32(x_, y_, 0xFF008000);
			} else {
				if (newHeadFront == NULL) {
					newHeadFront = iNode;
				} else {
					Memory.setI32(newHeadBack + NEXT__, iNode);
				}
				newHeadBack = iNode;
				totalHeads++;
			}
			iNode = Memory.getI32(iNode + NEXT__);
		}
		
		if (newHeadBack != NULL) {
			Memory.setI32(newHeadBack + NEXT__, NULL);
		}
		
		// those heads are the "good" heads; swap lists
		
		headFront = newHeadFront;
		newHeadBack = newHeadFront = NULL;
		
		// do the same with tails
		
		iNode = tailFront;
		while (iNode != NULL) {
			x_ = Memory.getUI16(iNode + X__);
			y_ = Memory.getUI16(iNode + Y__);
			if (rect.contains(x_, y_)) {
				Memory.setByte(iNode + IS_WIRE__, 1);
				_heatData.setPixel32(x_, y_, 0xFF008000);
			} else {
				if (newHeadFront == NULL) {
					newHeadFront = iNode;
				} else {
					Memory.setI32(newHeadBack + NEXT__, iNode);
				}
				newHeadBack = iNode;
			}
			iNode = Memory.getI32(iNode + NEXT__);
		}
		
		if (newHeadBack != NULL) {
			Memory.setI32(newHeadBack + NEXT__, NULL);
		}
		
		tailFront = newHeadFront;
		newHeadBack = newHeadFront = NULL;
		
	}
	
	override public function getState(__x:Int, __y:Int):UInt {
		__x -= Std.int(activeRect.x);
		__y -= Std.int(activeRect.y);
		return _headData.getPixel32(__x, __y) | _tailData.getPixel32(__x, __y);
	}
	
	override public function reset():Void {
		var iNode:Int;
		// repopulate the lists - no need to empty any lists here 
		headBack = headFront = NULL;
		tailBack = tailFront = NULL;
		
		// Return every node to its original state
		// and add them to the proper lists
		
		// Technically this could be faster, but who really cares?
		iNode = 0;
		while (iNode < totalBytes) {
			Memory.setI32(iNode + TIMES_LIT__, 0);
			
			switch (Memory.getByte(iNode + FIRST_STATE__)) {
				case WWFormat.HEAD:
					Memory.setByte(iNode + IS_WIRE__, 0);
					if (headFront == NULL) {
						headFront = iNode;
					} else {
						Memory.setI32(headBack + NEXT__, iNode);
					}
					headBack = iNode;
					Memory.setI32(iNode + TIMES_LIT__, Memory.getI32(iNode + TIMES_LIT__) + 1);
				case WWFormat.TAIL:
					Memory.setByte(iNode + IS_WIRE__, 0);
					if (tailFront == NULL) {
						tailFront = iNode;
					} else {
						Memory.setI32(tailBack + NEXT__, iNode);
					}
					tailBack = iNode;
				case WWFormat.WIRE:
					Memory.setByte(iNode + IS_WIRE__, 1);
			}
			
			iNode += NODE_SIZE;
		}
		
		if (headBack != NULL) {
			Memory.setI32(headBack + NEXT__, NULL);
		}
		if (tailBack != NULL) {
			Memory.setI32(tailBack + NEXT__, NULL);
		}
		
		// wipe the head data
		_heatData.fillRect(_heatData.rect, CLEAR);
		boundIsDirty = true;
		refresh(WWRefreshFlag.FULL | WWRefreshFlag.TAIL);
		
		_generation = 1;
	}
	
	override public function update():Void {
		var ike:Int;
		var jen:Int;
		var iNode:Int;
		var jNode:Int;
		
		var scratch:Int;
		
		// find new heads in current head neighbors (and list them)
		
		//		first, list all wires that are adjacent to heads
		iNode = headFront;
		while (iNode != NULL) {
			scratch = Memory.getByte(iNode + NEIGHBOR_COUNT__);
			for (ike in 0...scratch) {
				jNode = Memory.getI32(iNode + NEIGHBOR_LIST__ + ike * INT_SIZE);
				if (Memory.getByte(jNode + IS_WIRE__) > 0) {
					jen = jNode + TAPS__;
					if (Memory.getByte(jen) == 0) {
						if (newHeadFront == NULL) {
							newHeadFront = jNode;
						} else {
							Memory.setI32(newHeadBack + NEXT__, jNode);
						}
						newHeadBack = jNode;
					}
					Memory.setByte(jen, Memory.getByte(jen) + 1);
				}
			}
			iNode = Memory.getI32(iNode + NEXT__);
		}
		if (newHeadBack != NULL) {
			Memory.setI32(newHeadBack + NEXT__, NULL);
		}
		
		//		then, remove from this list all nodes with more than two head neighbors
		iNode = newHeadFront;
		while (iNode != NULL) {
			if (Memory.getByte(iNode + TAPS__) > 2) {
				newHeadFront = Memory.getI32(iNode + NEXT__);
				Memory.setByte(iNode + TAPS__, 0);
				iNode = newHeadFront;
			} else {
				Memory.setByte(iNode + TAPS__, 0);
				break;
			}
		}
		
		totalHeads = 0;
		
		if (iNode != NULL) {
			jNode = Memory.getI32(iNode + NEXT__);
			while (jNode != NULL) {
				if (Memory.getByte(jNode + TAPS__) > 2) {
					Memory.setI32(iNode + NEXT__, Memory.getI32(jNode + NEXT__));
				} else {
					totalHeads++;
					iNode = jNode;
				}
				Memory.setByte(jNode + TAPS__, 0);
				jNode = Memory.getI32(jNode + NEXT__);
			}
		}
		
		// change states
		
		iNode = tailFront;
		while (iNode != NULL) {
			Memory.setByte(iNode + IS_WIRE__, 1);
			iNode = Memory.getI32(iNode + NEXT__);
		}
		
		iNode = newHeadFront;
		while (iNode != NULL) {
			Memory.setByte(iNode + IS_WIRE__, 0);
			Memory.setI32(iNode + TIMES_LIT__, Memory.getI32(iNode + TIMES_LIT__) + 1);
			iNode = Memory.getI32(iNode + NEXT__);
		}
		
		// swap the lists
		tailFront = headFront;
		headFront = newHeadFront;
		newHeadBack = newHeadFront = NULL;
		
		_generation++;
		
	}
	
	override public function setBounds(top:Int, left:Int, bottom:Int, right:Int):Void {
		super.setBounds(top, left, bottom, right);
		boundIsDirty = true;
	}
	
	// OVERRIDDEN PRIVATE METHODS
	
	override function addNode(__x:Int, __y:Int, __state:Int):Void {
		var iNode:Int;
		iNode = totalBytes;
		neighborLookupTable[__x + _width * __y] = iNode;
		
		// You see here, a node is simply a sequence of information.
		
		// Known values first...
		
		Memory.setByte(		iNode + IS_WIRE__, 			0); 		// byte
		Memory.setI32(		iNode + NEXT__, 			NULL); 		// int
		Memory.setI32(		iNode + TIMES_LIT__, 		0); 		// int
		Memory.setByte(		iNode + TAPS__, 			0); 		// byte
		Memory.setI16(		iNode + X__, 				__x); 		// short
		Memory.setI16(		iNode + Y__, 				__y); 		// short
		Memory.setByte(		iNode + FIRST_STATE__, 		__state); 	// byte
		Memory.setByte(		iNode + NEIGHBOR_COUNT__, 	0);			// byte
		
		// ... plus room for eight neighbor ints, which will store pointers to neighbors
		
		totalNodes++;
		totalBytes += NODE_SIZE;
	}
	
	override function finishExtraction(event:flash.events.Event):Void {
		importer.dump();
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
			if (totalBytes > 0) {
				bytes.clear();
			}
			bytes.length = Std.int(Math.max(NODE_SIZE * importer.totalNodes, MIN_BYTEARRAY_SIZE));
			Lib.trace("Byte array size: " + bytes.length);
			Lib.trace("Buffer size: " + INT_SIZE * _width * _height);
			bytes.length += INT_SIZE * _width * _height;
			Memory.select(bytes);
			totalNodes = 0;
			totalBytes = 0;
			headFront = headBack = -1;
			tailFront = tailBack = -1;
			newHeadFront = newHeadBack = -1;
		
			importer.extract(addNode);
		}
	}
	
	override function refreshHeat(fully:Int):Void {
		var iNode:Int;
		var allow:Bool;
		var x_:Int;
		var y_:Int;
		var mult:Float = 2.9 / _generation;
		_heatData.lock();
		iNode = 0;
		while (iNode < totalBytes) {
			x_ = Memory.getUI16(iNode + X__);
			y_ = Memory.getUI16(iNode + Y__);
			allow = (fully > 0) || (x_ >= leftBound && x_ <= rightBound && y_ >= topBound && y_ <= bottomBound);
			if (allow) _heatData.setPixel32(x_, y_, heatSpectrum.colorOf(Memory.getI32(iNode + TIMES_LIT__) * mult));
			iNode += NODE_SIZE;
		}
		_heatData.unlock();
	}
	
	override function refreshImage(fully:Int, freshTails:Int):Void {
		var iNode:Int;
		var allow:Bool;
		var x_:Int;
		var y_:Int;
		
		var rect:Rectangle = fully > 0 ? _headData.rect : bound;
		var rectWidth:Int = Std.int(rect.width);
		var rectTop:Int = Std.int(rect.top);
		var rectLeft:Int = Std.int(rect.left);
		var bufferSize:Int = Std.int(rect.width * rect.height * INT_SIZE);
		
		_tailData.lock();
		
		if (freshTails > 0 || boundIsDirty) {
			
			// BUFFER SETUP
			bytes.position = bufferOffset;
			bytes.writeBytes(emptyBuffer, 0, bufferSize);

			_tailData.fillRect((fully > 0) ? _tailData.rect : bound, CLEAR);
			
			iNode = tailFront;
			while (iNode != NULL) {
				x_ = Memory.getUI16(iNode + X__);
				y_ = Memory.getUI16(iNode + Y__);
				allow = (fully > 0) || (x_ >= leftBound && x_ <= rightBound && y_ >= topBound && y_ <= bottomBound);
				if (allow) { 
					x_ -= rectLeft;
					y_ -= rectTop;
					Memory.setI32(bufferOffset + INT_SIZE * (y_ * rectWidth + x_), BACKWARDS_BLACK); // BUFFER OPERATION
				}
				iNode = Memory.getI32(iNode + NEXT__);
			}
			
			// BUFFER RESOLUTION
			transferBuffer.position = 0;
			transferBuffer.writeBytes(bytes, bufferOffset, bufferSize);
			transferBuffer.position = 0;
			_tailData.setPixels(rect, transferBuffer);
			
			boundIsDirty = false;
		} else {
			_tailData.copyPixels(_headData, (fully > 0) ? _tailData.rect : bound, (fully > 0) ? ORIGIN : bound.topLeft);
		}
		
		_tailData.unlock();
		_headData.lock();
		
		// BUFFER SETUP
		bytes.position = bufferOffset;
		bytes.writeBytes(emptyBuffer, 0, bufferSize);
		
		iNode = headFront;
		while (iNode != NULL) {
			x_ = Memory.getUI16(iNode + X__);
			y_ = Memory.getUI16(iNode + Y__);
			allow = (fully > 0) || (x_ >= leftBound && x_ <= rightBound && y_ >= topBound && y_ <= bottomBound);
			if (allow) { 
				x_ -= rectLeft;
				y_ -= rectTop;
				Memory.setI32(bufferOffset + INT_SIZE * (y_ * rectWidth + x_), BACKWARDS_BLACK); // BUFFER OPERATION
			}
			iNode = Memory.getI32(iNode + NEXT__);
		}
		
		// BUFFER RESOLUTION
		transferBuffer.position = 0;
		transferBuffer.writeBytes(bytes, bufferOffset, bufferSize);
		transferBuffer.position = 0;
		_headData.setPixels(rect, transferBuffer);
		
		_headData.unlock();
	}
	
	// PRIVATE METHODS
	
	private function beginFindNeighbors():Void {
		staticSurvey = EMPTY_SURVEY.slice(0);
		neighborItr = 0;
	}

	private function checkFindNeighbors():Bool {
		return (neighborItr < totalBytes);
	}

	private function partialFindNeighbors():Void {
		var ike:Int;
		var iNode:Int;
		var scratch:Int;
		var neighbor:Null<Int>;
		var row:Int;
		
		ike = 0;
		while (ike < STEP && neighborItr < totalBytes) {
			iNode = neighborItr;
			row = Memory.getUI16(iNode + Y__);
			scratch = Memory.getUI16(iNode + X__) + row * _width;
			Memory.setByte(iNode + NEIGHBOR_COUNT__, 0);

			scratch -= _width; row--;
			neighbor = neighborLookupTable[scratch - 1];	if (neighbor != null) addNeighbor(iNode, neighbor, row);
			neighbor = neighborLookupTable[scratch + 0];	if (neighbor != null) addNeighbor(iNode, neighbor, row);
			neighbor = neighborLookupTable[scratch + 1];	if (neighbor != null) addNeighbor(iNode, neighbor, row);
			
			scratch += _width; row++;
			neighbor = neighborLookupTable[scratch - 1];	if (neighbor != null) addNeighbor(iNode, neighbor, row);
			neighbor = neighborLookupTable[scratch + 1];	if (neighbor != null) addNeighbor(iNode, neighbor, row);
			
			scratch += _width; row++;
			neighbor = neighborLookupTable[scratch - 1];	if (neighbor != null) addNeighbor(iNode, neighbor, row);
			neighbor = neighborLookupTable[scratch + 0];	if (neighbor != null) addNeighbor(iNode, neighbor, row);
			neighbor = neighborLookupTable[scratch + 1];	if (neighbor != null) addNeighbor(iNode, neighbor, row);

			staticSurvey[Memory.getByte(iNode + NEIGHBOR_COUNT__)]++;
			
			neighborItr += NODE_SIZE;
			
			ike += 1;
		}
	}
	
	private function addNeighbor(node:Int, value:Int, intendedRow:Int):Void {
		if (Memory.getUI16(value + Y__) != intendedRow) return;
		var jen:Int;
		jen = Memory.getByte(node + NEIGHBOR_COUNT__);
		Memory.setI32(	node + NEIGHBOR_LIST__ + jen * INT_SIZE, 	value		);
		Memory.setByte(	node + NEIGHBOR_COUNT__, 					jen + 1		);
	}
	
	private function finishFindNeighbors():Void {
		neighborLookupTable.splice(0, neighborLookupTable.length);
		
		initDrawData(); // This sounds like it should belong in the View, but it really doesn't.
		
		Lib.trace(totalNodes + " total nodes");
		Lib.trace("staticSurvey: " + staticSurvey);
		Lib.trace("1-2: " + Std.int(staticSurvey[1] + staticSurvey[2]));
		Lib.trace("3-4: " + Std.int(staticSurvey[3] + staticSurvey[4]));
		Lib.trace("5-7: " + Std.int(staticSurvey[5] + staticSurvey[6] + staticSurvey[7]));
		
		dispatchEvent(COMPLETE_EVENT);
	}
	
	private function initDrawData():Void {
		var iNode:Int;
		var x_:Int;
		var y_:Int;
		activeRect.setEmpty();
		iNode = 0;
		while (iNode < totalBytes) {
			x_ = Memory.getUI16(iNode + X__);
			y_ = Memory.getUI16(iNode + Y__);
			if (activeRect.isEmpty()) {
				activeRect.left = x_;
				activeRect.top = y_;
				activeRect.width = 1;
				activeRect.height = 1;
			} else {
				activeRect.left = Math.min(activeRect.left, x_);
				activeRect.top = Math.min(activeRect.top, y_);
				activeRect.right = Math.max(activeRect.right, x_ + 1);
				activeRect.bottom = Math.max(activeRect.bottom, y_ + 1);
			}
			
			activeCorner.x = activeRect.left;
			activeCorner.y = activeRect.top;
			
			iNode += NODE_SIZE;
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
		
		bufferOffset = totalBytes;
		transferBuffer.clear();
		emptyBuffer.clear();
		transferBuffer.length = emptyBuffer.length = Std.int(INT_SIZE * activeRect.width * activeRect.height);
		
		drawBackground(_baseGraphics, _width, _height, BLACK);
		drawData(_wireGraphics, activeRect, _wireData);
		drawData(_headGraphics, activeRect, _headData);
		drawData(_tailGraphics, activeRect, _tailData);
		drawData(_heatGraphics, activeRect, _heatData);
		
		// update the positions of nodes
		iNode = 0;
		while (iNode < totalBytes) {
			x_ = Memory.getUI16(iNode + X__) - Std.int(activeRect.x);
			y_ = Memory.getUI16(iNode + Y__) - Std.int(activeRect.y);
			Memory.setI16(iNode + X__, x_);
			Memory.setI16(iNode + Y__, y_);
			_wireData.setPixel32(x_, y_, BLACK);
			iNode += NODE_SIZE;
		}
	}
}