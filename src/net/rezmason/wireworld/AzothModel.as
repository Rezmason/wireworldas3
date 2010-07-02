/**
* Wireworld Player by Jeremy Sachs. June 22, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld {

	//---------------------------------------
	// IMPORT STATEMENTS
	//---------------------------------------
	import apparat.math.IntMath;
	
	import com.buraks.utils.fastmem;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import net.rezmason.utils.GreenThread;
	
	// Based on TDSIModel. Doing a find-and-replace. Is this really faster?
	
	// Refer to the VectorModel comments if the ones here don't help.
	
	internal final class AzothModel extends BaseModel {

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
		
		private var x_:int, y_:int;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function AzothModel():void {
			
			// init the ByteArray.
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.length = 1024;
			fastmem.fastSelectMem(bytes);
			
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
				scratch = fastmem.fastGetByte(iNode + NEIGHBOR_COUNT__);
				for (ike = 0; ike < scratch; ike += 1) {
					jNode = fastmem.fastGetI32(iNode + NEIGHBOR_LIST__ + ike * INT_SIZE);
					if (fastmem.fastGetByte(jNode + IS_WIRE__)) {
						jen = jNode + TAPS__;
						if (!fastmem.fastGetByte(jen)) {
							if (newHeadFront == NULL) {
								newHeadFront = jNode;
							} else {
								fastmem.fastSetI32(jNode, newHeadBack + NEXT__);
							}
							newHeadBack = jNode;
						}
						fastmem.fastSetByte(fastmem.fastGetByte(jen) + 1, jen);
					}
				}
				iNode = fastmem.fastGetI32(iNode + NEXT__);
			}
			if (newHeadBack != NULL) {
				fastmem.fastSetI32(NULL, newHeadBack + NEXT__);
			}
			
			//		then, remove from this list all nodes with more than two head neighbors
			iNode = newHeadFront;
			while (iNode != NULL) {
				if (fastmem.fastGetByte(iNode + TAPS__) > 2) {
					newHeadFront = fastmem.fastGetI32(iNode + NEXT__);
					fastmem.fastSetByte(0, iNode + TAPS__);
					iNode = newHeadFront;
				} else {
					fastmem.fastSetByte(0, iNode + TAPS__);
					break;
				}
			}
			
			totalHeads = 0;
			
			if (iNode != NULL) {
				jNode = fastmem.fastGetI32(iNode + NEXT__);
				while (jNode != NULL) {
					if (fastmem.fastGetByte(jNode + TAPS__) > 2) {
						fastmem.fastSetI32(fastmem.fastGetI32(jNode + NEXT__), iNode + NEXT__);
					} else {
						totalHeads++;
						iNode = jNode;
					}
					fastmem.fastSetByte(0, jNode + TAPS__);
					jNode = fastmem.fastGetI32(jNode + NEXT__);
				}
			}
			
			// change states
			
			iNode = tailFront;
			while (iNode != NULL) {
				fastmem.fastSetByte(1, iNode + IS_WIRE__);
				iNode = fastmem.fastGetI32(iNode + NEXT__);
			}
			
			iNode = newHeadFront;
			while (iNode != NULL) {
				fastmem.fastSetByte(0, iNode + IS_WIRE__);
				fastmem.fastSetI32(fastmem.fastGetI32(iNode + TIMES_LIT__) + 1, iNode + TIMES_LIT__);
				iNode = fastmem.fastGetI32(iNode + NEXT__);
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
				x_ = fastmem.fastGetUI16(iNode + X__);
				y_ = fastmem.fastGetUI16(iNode + Y__);
				if (rect.contains(x_, y_)) {
					fastmem.fastSetByte(1, iNode + IS_WIRE__);
					_heatData.setPixel(x_, y_, 0xFF0008000);
				} else {
					if (newHeadFront == NULL) {
						newHeadFront = iNode;
					} else {
						fastmem.fastSetI32(iNode, newHeadBack + NEXT__);
					}
					newHeadBack = iNode;
					totalHeads++;
				}
				iNode = fastmem.fastGetI32(iNode + NEXT__);
			}
			
			if (newHeadBack != NULL) {
				fastmem.fastSetI32(NULL, newHeadBack + NEXT__);
			}
			
			// those heads are the "good" heads; swap lists
			
			headFront = newHeadFront;
			newHeadBack = newHeadFront = NULL;
			
			// do the same with tails
			
			iNode = tailFront;
			while (iNode != NULL) {
				x_ = fastmem.fastGetUI16(iNode + X__);
				y_ = fastmem.fastGetUI16(iNode + Y__);
				if (rect.contains(x_, y_)) {
					fastmem.fastSetByte(1, iNode + IS_WIRE__);
					_heatData.setPixel(x_, y_, 0xFF0008000);
				} else {
					if (newHeadFront == NULL) {
						newHeadFront = iNode;
					} else {
						fastmem.fastSetI32(iNode, newHeadBack + NEXT__);
					}
					newHeadBack = iNode;
				}
				iNode = fastmem.fastGetI32(iNode + NEXT__);
			}
			
			if (newHeadBack != NULL) {
				fastmem.fastSetI32(NULL, newHeadBack + NEXT__);
			}
			
			tailFront = newHeadFront;
			newHeadBack = newHeadFront = NULL;
			
			// refresh
			
			refreshImage();
			refreshTails();
		}
		
		override public function refreshHeat(fully:Boolean = false):void {
			iNode = 0;
			var allow:Boolean;
			var mult:Number = 2.9 / _generation;
			while (iNode < totalBytes) {
				x_ = fastmem.fastGetUI16(iNode + X__);
				y_ = fastmem.fastGetUI16(iNode + Y__);
				allow = fully || (x_ >= leftBound && x_ < rightBound && y_ >= topBound && y_ < bottomBound);
				if (allow) {
					scratch = heatColorOf(fastmem.fastGetI32(iNode + TIMES_LIT__) * mult);
					_heatData.setPixel(x_, y_, scratch);
				}
				iNode += NODE_SIZE;
			}
		}

		override public function refreshImage(fully:Boolean = false):void {
			if (fully) {
				_tailData.copyPixels(_headData, _tailData.rect, ORIGIN);
				_headData.fillRect(_headData.rect, CLEAR);
			} else {
				_tailData.copyPixels(_headData, bound, bound.topLeft);
				_headData.fillRect(bound, CLEAR);
			}
			
			iNode = headFront;
			var allow:Boolean;
			while (iNode != NULL) {
				x_ = fastmem.fastGetUI16(iNode + X__);
				y_ = fastmem.fastGetUI16(iNode + Y__);
				allow = fully || (x_ >= leftBound && x_ < rightBound && y_ >= topBound && y_ < bottomBound);
				if (allow) _headData.setPixel32(x_, y_, BLACK);
				iNode = fastmem.fastGetI32(iNode + NEXT__);
			}
		}
		
		private function refreshTails(fully:Boolean = false):void {
			if (fully) {
				_tailData.fillRect(_tailData.rect, CLEAR);
			} else {
				_tailData.fillRect(bound, CLEAR);
			}
			
			iNode = tailFront;
			var allow:Boolean;
			while (iNode != NULL) {
				x_ = fastmem.fastGetUI16(iNode + X__);
				y_ = fastmem.fastGetUI16(iNode + Y__);
				allow = fully || (x_ >= leftBound && x_ < rightBound && y_ >= topBound && y_ < bottomBound);
				if (allow) _tailData.setPixel32(x_, y_, BLACK);
				iNode = fastmem.fastGetI32(iNode + NEXT__);
			}
		}
		
		override public function refreshAll(fully:Boolean = false):void {
			refreshImage(fully);
			refreshTails(fully);
			refreshHeat(fully);
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
				fastmem.fastSetI32(0, iNode + TIMES_LIT__);
				
				switch (fastmem.fastGetByte(iNode + FIRST_STATE__)) {
					case WireFormat.HEAD:
						fastmem.fastSetByte(0, iNode + IS_WIRE__);
						if (headFront == NULL) {
							headFront = iNode;
						} else {
							fastmem.fastSetI32(iNode, headBack + NEXT__);
						}
						headBack = iNode;
						fastmem.fastSetI32(fastmem.fastGetI32(iNode + TIMES_LIT__) + 1, iNode + TIMES_LIT__);
						break;
					case WireFormat.TAIL:
						fastmem.fastSetByte(0, iNode + IS_WIRE__);
						if (tailFront == NULL) {
							tailFront = iNode;
						} else {
							fastmem.fastSetI32(iNode, tailBack + NEXT__);
						}
						tailBack = iNode;
						break;
					case WireFormat.WIRE:
						fastmem.fastSetByte(1, iNode + IS_WIRE__);
				}
				
				iNode += NODE_SIZE;
			}
			
			if (headBack != NULL) {
				fastmem.fastSetI32(NULL, headBack + NEXT__);
			}
			if (tailBack != NULL) {
				fastmem.fastSetI32(NULL, tailBack + NEXT__);
			}
			
			// wipe the head data
			_heatData.fillRect(_heatData.rect, CLEAR);
			refreshAll();
			
			_generation = 1;
		}

		//---------------------------------------
		// PRIVATE METHODS
		//---------------------------------------
		
		override protected function finishParse(event:Event):void {
			
			if (importer.width  > WireFormat.MAX_SIZE || importer.height  > WireFormat.MAX_SIZE || importer.width * importer.height < 1) {
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
				fastmem.fastSelectMem(bytes);
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
				scratch = fastmem.fastGetUI16(iNode + X__) + fastmem.fastGetUI16(iNode + Y__) * _width;
				fastmem.fastSetByte(0, iNode + NEIGHBOR_COUNT__);

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

				staticSurvey[fastmem.fastGetByte(iNode + NEIGHBOR_COUNT__)]++;
				
				neighborItr += NODE_SIZE;
			}
		}
		
		private function addNeighbor(node:int, value:int):void {
			jen = fastmem.fastGetByte(node + NEIGHBOR_COUNT__);
			fastmem.fastSetI32(value, node + NEIGHBOR_LIST__ + jen * INT_SIZE);
			fastmem.fastSetByte(jen + 1, node + NEIGHBOR_COUNT__);
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
				x_ = fastmem.fastGetUI16(iNode + X__);
				y_ = fastmem.fastGetUI16(iNode + Y__);
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
			
			
			// The BitmapData objects only need to be as large as the active rectangle, with a one-pixel border to prevent artifacts.
			_wireData = new BitmapData(activeRect.width + 1, activeRect.height + 1, true, CLEAR);
			_headData = new BitmapData(activeRect.width + 1, activeRect.height + 1, true, CLEAR);
			_tailData = new BitmapData(activeRect.width + 1, activeRect.height + 1, true, CLEAR);
			_heatData = new BitmapData(activeRect.width + 1, activeRect.height + 1, false, BLACK);
			
			drawBackground(_baseGraphics, _width, _height, BLACK);
			drawData(_wireGraphics, activeRect, _wireData);
			drawData(_headGraphics, activeRect, _headData);
			drawData(_tailGraphics, activeRect, _tailData);
			drawData(_heatGraphics, activeRect, _heatData);
			
			// update the positions of nodes
			iNode = 0;
			while (iNode < totalBytes) {
				x_ = fastmem.fastGetUI16(iNode + X__) - activeRect.x;
				y_ = fastmem.fastGetUI16(iNode + Y__) - activeRect.y;
				fastmem.fastSetI16(x_, iNode + X__);
				fastmem.fastSetI16(y_, iNode + Y__);
				_wireData.setPixel32(x_, y_, BLACK);
				iNode += NODE_SIZE;
			}
		}

		override protected function addNode(__x:int, __y:int, __state:int):void {
			
			iNode = totalBytes;
			neighborLookupTable[__x + _width * __y] = iNode;
			
			// You see here, a node is simply a sequence of information.
			
			// Known values first...
			fastmem.fastSetByte(0, 		iNode + IS_WIRE__); 		// byte
			fastmem.fastSetI32(NULL, 		iNode + NEXT__); 			// int
			fastmem.fastSetI32(0, 			iNode + TIMES_LIT__); 		// int
			fastmem.fastSetByte(0, 		iNode + TAPS__); 			// byte
			fastmem.fastSetI16(__x, 		iNode + X__); 				// short
			fastmem.fastSetI16(__y, 		iNode + Y__); 				// short
			fastmem.fastSetByte(__state, 	iNode + FIRST_STATE__); 	// byte
			fastmem.fastSetByte(0, 		iNode + NEIGHBOR_COUNT__);	// byte
			
			// ... plus room for eight neighbor ints, which will store pointers to neighbors
			
			totalNodes++;
			totalBytes += NODE_SIZE;
		}
	}
}
