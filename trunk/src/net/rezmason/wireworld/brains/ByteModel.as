/**
* Wireworld Player by Jeremy Sachs. June 22, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld.brains {

	//---------------------------------------
	// IMPORT STATEMENTS
	//---------------------------------------
	import apparat.math.IntMath;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import net.rezmason.utils.GreenThread;
	import net.rezmason.wireworld.WWRefreshFlag;
	
	// Downgraded from TDSIModel. Uses a ByteArray, but no TDSI.
	// It demonstrates that ByteArrays do not magically improve performance. 
	
	// Refer to the TDSIModel comments if the ones here don't help.
	
	public final class ByteModel extends BaseModel {

		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		private static const EMPTY_SURVEY:Vector.<int>= new Vector.<int>(9, true);
		private static const DARKEN:ColorTransform = new ColorTransform(1, 1, 1, 0.9);
		
		private static const NULL:int = -1;
		
		private static const BYTE_SIZE:int = 1;
		private static const SHORT_SIZE:int = 2;
		private static const INT_SIZE:int = 4;
		
		//	NAME			TYPE			BINARY DATA TYPE	BYTE	OFFSET
		//	isWire			Boolean			byte				1		0
		//	next			WireNode		int					4		1
		//	timesLit		int				int					4		5
		//	taps			int				byte				1		9
		//	x				int				short				2		10
		//	y				int				short				2		12
		//	firstState		int				byte				1		14
		//	neighborCount	int				byte				1		15
		//	neighborList	Vector.<int>	int * 8				4 * 8	16
		//	nodeSize													48
		
		// offsets- properties of a node, spaced apart sequentially in the ByteArray
		
		private static const IS_WIRE__:int = 0;
		private static const NEXT__:int = IS_WIRE__ + BYTE_SIZE;
		private static const TIMES_LIT__:int = NEXT__ + INT_SIZE;
		private static const TAPS__:int = TIMES_LIT__ + INT_SIZE;
		private static const X__:int = TAPS__ + BYTE_SIZE;
		private static const Y__:int = X__ + SHORT_SIZE;
		private static const FIRST_STATE__:int = Y__ + SHORT_SIZE;
		private static const NEIGHBOR_COUNT__:int = FIRST_STATE__ + BYTE_SIZE;
		private static const NEIGHBOR_LIST__:int = NEIGHBOR_COUNT__ + BYTE_SIZE;
		
		private static const NODE_SIZE:int = NEIGHBOR_LIST__ + 8 * INT_SIZE + 1;
		
		private static const MIN_BYTEARRAY_SIZE:int = 1024;

		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private var neighborLookupTable:Array = []; // sparse array of all nodes, listed by index
		// NOTE: The neighbor lookup table is an Array because it's sparse, it's boundless, and because we only use it for parsing.
		private var totalBytes:int, totalHeads:int;
		private var staticSurvey:Vector.<int>;
		private var neighborThread:GreenThread = new GreenThread; // The green thread that drives the neighbor finding algorithm
		private var headFront:int = NULL, headBack:int = NULL; // linked list of nodes that are currently electron heads
		private var tailFront:int = NULL, tailBack:int = NULL; // linked list of nodes that are currently electron tails
		private var newHeadFront:int = NULL, newHeadBack:int = NULL; // linked list of nodes that are becoming electron heads
		private var bytes:ByteArray = new ByteArray();
		private var ike:int, jen:int;
		private var neighborItr:int;
		private var scratch:int;
		private var iNode:int, jNode:int;
		private var neighbor:*;
		
		private var x_:int, y_:int, taps_:int, next_:int, timesLit_:int, firstState_:int;

		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function ByteModel():void {
			
			// init the ByteArray.
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.length = 1024;
			
			// Set up the neighbor thread.
			neighborThread.taskFragment = partialFindNeighbors;
			neighborThread.condition = checkFindNeighbors;
			neighborThread.prologue = beginFindNeighbors;
			neighborThread.epilogue = finishFindNeighbors;
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		// update
		override public function update():void {
			// find new heads in current head neighbors (and list them)
			
			//		first, list all wires that are adjacent to heads
			iNode = headFront;
			while (iNode != NULL) {
				bytes.position = iNode + NEIGHBOR_COUNT__;
				scratch = bytes.readUnsignedByte();
				for (ike = 0; ike < scratch; ike += 1) {
					bytes.position = iNode + NEIGHBOR_LIST__ + ike * INT_SIZE;
					jNode = bytes.readInt();
					bytes.position = jNode + IS_WIRE__;
					if (bytes.readUnsignedByte()) {
						jen = jNode + TAPS__;
						bytes.position = jen;
						if (!bytes.readUnsignedByte()) {
							if (newHeadFront == NULL) {
								newHeadFront = jNode;
							} else {
								bytes.position = newHeadBack + NEXT__;
								bytes.writeInt(jNode);
							}
							newHeadBack = jNode;
						}
						bytes.position = jen;
						taps_ = bytes.readUnsignedByte() + 1;
						bytes.position = jen;
						bytes.writeByte(taps_);
					}
				}
				bytes.position = iNode + NEXT__;
				iNode = bytes.readInt();
			}
			if (newHeadBack != NULL) {
				bytes.position = newHeadBack + NEXT__;
				bytes.writeInt(NULL);
			}
			
			//		then, remove from this list all nodes with more than two head neighbors
			iNode = newHeadFront;
			while (iNode != NULL) {
				bytes.position = iNode + TAPS__;
				if (bytes.readUnsignedByte() > 2) {
					bytes.position = iNode + NEXT__;
					newHeadFront = bytes.readInt();
					bytes.position = iNode + TAPS__;
					bytes.writeByte(0);
					iNode = newHeadFront;
				} else {
					bytes.position = iNode + TAPS__;
					bytes.writeByte(0);
					break;
				}
			}
			
			totalHeads = 0;
			
			if (iNode != NULL) {
				bytes.position = iNode + NEXT__;
				jNode = bytes.readInt();
				while (jNode != NULL) {
					bytes.position = jNode + TAPS__;
					if (bytes.readUnsignedByte() > 2) {
						bytes.position = jNode + NEXT__;
						next_ = bytes.readInt();
						bytes.position = iNode + NEXT__;
						bytes.writeInt(next_);
					} else {
						totalHeads++;
						iNode = jNode;
					}
					bytes.position = jNode + TAPS__;
					bytes.writeByte(0);
					bytes.position = jNode + NEXT__;
					jNode = bytes.readInt();
				}
			}
			
			// change states
			
			iNode = tailFront;
			while (iNode != NULL) {
				bytes.position = iNode + IS_WIRE__;
				bytes.writeByte(1);
				bytes.position = iNode + NEXT__;
				iNode = bytes.readInt();
			}
			
			iNode = newHeadFront;
			while (iNode != NULL) {
				bytes.position = iNode + IS_WIRE__;
				bytes.writeByte(0);
				bytes.position = iNode + TIMES_LIT__;
				timesLit_ = bytes.readInt() + 1;
				bytes.position = iNode + TIMES_LIT__;
				bytes.writeInt(timesLit_);
				bytes.position = iNode + NEXT__;
				iNode = bytes.readInt();
			}
			
			// swap the lists
			tailFront = headFront;
			headFront = newHeadFront;
			newHeadBack = newHeadFront = NULL;
			
			_generation++;
		}
		
		override public function eraseRect(rect:Rectangle):void {
			
			// correct the offset
			rect.x -= activeRect.x + 0.5;
			rect.y -= activeRect.y + 0.5;
			
			// find heads whose centers are NOT within eraseRect
			totalHeads = 0;
			iNode = headFront;
			while (iNode != NULL) {
				bytes.position = iNode + X__;
				x_ = bytes.readUnsignedShort();
				y_ = bytes.readUnsignedShort();
				if (rect.contains(x_, y_)) {
					bytes.position = iNode + IS_WIRE__;
					bytes.writeByte(1);
					_heatData.setPixel32(x_, y_, 0xFF0008000);
				} else {
					if (newHeadFront == NULL) {
						newHeadFront = iNode;
					} else {
						bytes.position = newHeadBack + NEXT__;
						bytes.writeInt(iNode);
					}
					newHeadBack = iNode;
					totalHeads++;
				}
				bytes.position = iNode + NEXT__;
				iNode = bytes.readInt();
			}
			
			if (newHeadBack != NULL) {
				bytes.position = newHeadBack + NEXT__;
				bytes.writeInt(NULL);
			}
			
			// those heads are the "good" heads; swap lists
			
			headFront = newHeadFront;
			newHeadBack = newHeadFront = NULL;
			
			// do the same with tails
			
			iNode = tailFront;
			while (iNode != NULL) {
				bytes.position = iNode + X__;
				x_ = bytes.readUnsignedShort();
				y_ = bytes.readUnsignedShort();
				if (rect.contains(x_, y_)) {
					bytes.position = iNode + IS_WIRE__;
					bytes.writeByte(1);
					_heatData.setPixel32(x_, y_, 0xFF0008000);
				} else {
					if (newHeadFront == NULL) {
						newHeadFront = iNode;
					} else {
						bytes.position = newHeadBack + NEXT__;
						bytes.writeInt(iNode);
					}
					newHeadBack = iNode;
				}
				bytes.position = iNode + NEXT__;
				iNode = bytes.readInt();
			}
			
			if (newHeadBack != NULL) {
				bytes.position = newHeadBack + NEXT__;
				bytes.writeInt(NULL);
			}
			
			tailFront = newHeadFront;
			newHeadBack = newHeadFront = NULL;
			
		}
		
		override public function getState(__x:int, __y:int):uint {
			__x -= activeRect.x;
			__y -= activeRect.y;
			return _headData.getPixel32(__x, __y) | _tailData.getPixel32(__x, __y);
		}

		override public function reset():void {
			// repopulate the lists - no need to empty any lists here 
			headBack = headFront = NULL;
			tailBack = tailFront = NULL;
			
			// Return every node to its original state
			// and add them to the proper lists
			
			// Technically this could be faster, but who really cares?
			iNode = 0;
			while (iNode < totalBytes) {
				bytes.position = iNode + TIMES_LIT__;
				bytes.writeInt(0);
				
				bytes.position = iNode + FIRST_STATE__;
				firstState_ = bytes.readUnsignedByte();
				
				switch (firstState_) {
					case WWFormat.HEAD:
						bytes.position = iNode + IS_WIRE__;
						bytes.writeByte(0);
						if (headFront == NULL) {
							headFront = iNode;
						} else {
							bytes.position = headBack + NEXT__;
							bytes.writeInt(iNode);
						}
						headBack = iNode;
						bytes.position = iNode + TIMES_LIT__;
						timesLit_ = bytes.readInt() + 1;
						bytes.position = iNode + TIMES_LIT__;
						bytes.writeInt(timesLit_);
						break;
					case WWFormat.TAIL:
						bytes.position = iNode + IS_WIRE__;
						bytes.writeByte(0);
						if (tailFront == NULL) {
							tailFront = iNode;
						} else {
							bytes.position = tailBack + NEXT__;
							bytes.writeInt(iNode);
						}
						tailBack = iNode;
						break;
					case WWFormat.WIRE:
						bytes.position = iNode + IS_WIRE__;
						bytes.writeByte(1);
				}
				
				iNode += NODE_SIZE;
			}
			
			bytes.position = headBack + NEXT__;
			if (headBack != NULL) {
				bytes.writeInt(NULL);
			}
			if (tailBack != NULL) {
				bytes.writeInt(NULL);
			}
			
			// wipe the head data
			_heatData.fillRect(_heatData.rect, CLEAR);
			refresh(WWRefreshFlag.FULL | WWRefreshFlag.TAIL);
			
			_generation = 1;
		}

		//---------------------------------------
		// PRIVATE METHODS
		//---------------------------------------
		
		override protected function finishParse(event:Event):void {
			
			if (importer.width  > WWFormat.MAX_SIZE || importer.height  > WWFormat.MAX_SIZE || importer.width * importer.height < 1) {
				dispatchEvent(INVALID_SIZE_ERROR_EVENT);
			} else {
				_width = importer.width;
				_height = importer.height;
				_credit = importer.credit;
			
				neighborLookupTable.length = 0;
				if (totalBytes) {
					bytes.clear();
				}
				bytes.length = IntMath.max(NODE_SIZE * importer.totalNodes, MIN_BYTEARRAY_SIZE);
				trace("Byte array size :", bytes.length);
				totalNodes = 0;
				totalBytes = 0;
				headFront = headBack = -1;
				tailFront = tailBack = -1;
				newHeadFront = newHeadBack = -1;
				
				importer.extract(addNode);
			}
		}
		
		override protected function finishExtraction(event:Event):void {
			importer.dump();
			neighborThread.start();
		}
		
		private function beginFindNeighbors():void {
			staticSurvey = EMPTY_SURVEY.slice();
			neighborItr = 0;
		}
		
		private function checkFindNeighbors():Boolean {
			return (neighborItr < totalBytes);
		}
		
		private function partialFindNeighbors():void {
			for (ike = 0; ike < STEP && neighborItr < totalBytes; ike += 1) {
				iNode = neighborItr;
				bytes.position = iNode + X__;
				scratch = bytes.readUnsignedShort() + bytes.readUnsignedShort() * _width;
				bytes.position = iNode + NEIGHBOR_COUNT__;
				bytes.writeByte(0);

				scratch -= _width;
				neighbor = neighborLookupTable[scratch - 1];	if (neighbor != undefined) addNeighbor(iNode, int(neighbor));
				neighbor = neighborLookupTable[scratch + 0];	if (neighbor != undefined) addNeighbor(iNode, int(neighbor));
				neighbor = neighborLookupTable[scratch + 1];	if (neighbor != undefined) addNeighbor(iNode, int(neighbor));

				scratch += _width;
				neighbor = neighborLookupTable[scratch - 1];	if (neighbor != undefined) addNeighbor(iNode, int(neighbor));
				neighbor = neighborLookupTable[scratch + 1];	if (neighbor != undefined) addNeighbor(iNode, int(neighbor));

				scratch += _width;
				neighbor = neighborLookupTable[scratch - 1];	if (neighbor != undefined) addNeighbor(iNode, int(neighbor));
				neighbor = neighborLookupTable[scratch + 0];	if (neighbor != undefined) addNeighbor(iNode, int(neighbor));
				neighbor = neighborLookupTable[scratch + 1];	if (neighbor != undefined) addNeighbor(iNode, int(neighbor));

				bytes.position = iNode + NEIGHBOR_COUNT__;
				staticSurvey[bytes.readUnsignedByte()]++;
				
				neighborItr += NODE_SIZE;
			}
		}
		
		private function addNeighbor(node:int, value:int):void {
			bytes.position = node + NEIGHBOR_COUNT__;
			jen = bytes.readUnsignedByte();
			bytes.position = node + NEIGHBOR_LIST__ + jen * INT_SIZE;
			bytes.writeInt(value);
			bytes.position = node + NEIGHBOR_COUNT__;
			bytes.writeByte(jen + 1);
		}
		
		private function finishFindNeighbors():void {
			neighborLookupTable.length = 0;
			
			initDrawData(); // This sounds like it should belong in the View, but it really doesn't.
			
			trace(totalNodes, "total nodes")
			trace("staticSurvey:", staticSurvey);
			trace("1-2:", staticSurvey[1] + staticSurvey[2]);
			trace("3-4:", staticSurvey[3] + staticSurvey[4]);
			trace("5-7:", staticSurvey[5] + staticSurvey[6] + staticSurvey[7]);
			
			dispatchEvent(COMPLETE_EVENT);
		}
		
		private function initDrawData():void {
			activeRect.setEmpty();
			iNode = 0;
			while (iNode < totalBytes) {
				bytes.position = iNode + X__;
				x_ = bytes.readUnsignedShort();
				y_ = bytes.readUnsignedShort();
				
				if (activeRect.isEmpty()) {
					activeRect.left = x_;
					activeRect.top = y_;
					activeRect.width = 1;
					activeRect.height = 1;
				} else {
					activeRect.left = IntMath.min(activeRect.left, x_);
					activeRect.top = IntMath.min(activeRect.top, y_);
					activeRect.right = IntMath.max(activeRect.right, x_ + 1);
					activeRect.bottom = IntMath.max(activeRect.bottom, y_ + 1);
				}
				
				activeCorner.x = activeRect.left;
				activeCorner.y = activeRect.top;
				
				iNode += NODE_SIZE;
			}
			
			if (_wireData) _wireData.dispose();
			if (_headData) _wireData.dispose();
			if (_tailData) _wireData.dispose();
			if (_heatData) _wireData.dispose();
			
			// The BitmapData objects only need to be as large as the active rectangle, with a one-pixel border to prevent artifacts.
			_wireData = new BitmapData(activeRect.width + 1, activeRect.height + 1, true, CLEAR);
			_headData = new BitmapData(activeRect.width + 1, activeRect.height + 1, true, CLEAR);
			_tailData = new BitmapData(activeRect.width + 1, activeRect.height + 1, true, CLEAR);
			_heatData = new BitmapData(activeRect.width + 1, activeRect.height + 1, true, CLEAR);
			
			drawBackground(_baseGraphics, _width, _height, BLACK);
			drawData(_wireGraphics, activeRect, _wireData);
			drawData(_headGraphics, activeRect, _headData);
			drawData(_tailGraphics, activeRect, _tailData);
			drawData(_heatGraphics, activeRect, _heatData);
			
			// update the positions of nodes
			iNode = 0;
			while (iNode < totalBytes) {
				bytes.position = iNode + X__;
				x_ = bytes.readUnsignedShort();
				y_ = bytes.readUnsignedShort();
				x_ -= activeRect.x;
				y_ -= activeRect.y;
				bytes.position = iNode + X__;
				bytes.writeShort(x_);
				bytes.writeShort(y_);
				_wireData.setPixel32(x_, y_, BLACK);
				iNode += NODE_SIZE;
			}
		}

		override protected function addNode(__x:int, __y:int, __state:int):void {
			
			iNode = totalBytes;
			neighborLookupTable[__x + _width * __y] = iNode;
			
			// You see here, a node is simply a sequence of information.
			
			// Known values first...
			bytes.position = iNode;
			bytes.writeByte(0); 		// byte
			bytes.writeInt(NULL); 		// int
			bytes.writeInt(0); 		// int
			bytes.writeByte(0); 		// byte
			bytes.writeShort(__x); 	// short
			bytes.writeShort(__y); 	// short
			bytes.writeByte(__state); 	// byte
			bytes.writeByte(0);		// byte
			
			// ... plus room for eight neighbor ints, which will store pointers to neighbors
			
			totalNodes++;
			totalBytes += NODE_SIZE;
		}
		
		override protected function refreshHeat(fully:int = 0):void {
			_heatData.lock();
			iNode = 0;
			var allow:Boolean;
			var mult:Number = 2.9 / _generation;
			while (iNode < totalBytes) {
				bytes.position = iNode + X__;
				x_ = bytes.readUnsignedShort();
				y_ = bytes.readUnsignedShort();
				allow = fully || (x_ >= leftBound && x_ <= rightBound && y_ >= topBound && y_ <= bottomBound);
				if (allow) {
					bytes.position = iNode + TIMES_LIT__;
					_heatData.setPixel32(x_, y_, heatColorOf(bytes.readInt() * mult));
				}
				iNode += NODE_SIZE;
			}
			_heatData.unlock();
		}

		override protected function refreshImage(fully:int = 0, freshTails:int = 0):void {
			var allow:Boolean;
			
			_tailData.lock();
			_headData.lock();
			if (freshTails) {
				
				_tailData.fillRect(fully ? _tailData.rect : bound, CLEAR);
				
				iNode = tailFront;
				while (iNode != NULL) {
					bytes.position = iNode + X__;
					x_ = bytes.readUnsignedShort();
					y_ = bytes.readUnsignedShort();
					allow = fully || (x_ >= leftBound && x_ <= rightBound && y_ >= topBound && y_ <= bottomBound);
					if (allow) _tailData.setPixel32(x_, y_, BLACK);
					bytes.position = iNode + NEXT__;
					iNode = bytes.readInt();
				}
				
			} else {
				_tailData.copyPixels(_headData, fully ? _tailData.rect : bound, fully ? ORIGIN : bound.topLeft);
			}
			
			_headData.fillRect(fully ? _headData.rect : bound, CLEAR);
			
			iNode = headFront;
			while (iNode != NULL) {
				bytes.position = iNode + X__;
				x_ = bytes.readUnsignedShort();
				y_ = bytes.readUnsignedShort();
				allow = fully || (x_ >= leftBound && x_ <= rightBound && y_ >= topBound && y_ <= bottomBound);
				if (allow) _headData.setPixel32(x_, y_, BLACK);
				bytes.position = iNode + NEXT__;
				iNode = bytes.readInt();
			}
			_tailData.unlock();
			_headData.unlock();
		}
	}
}
