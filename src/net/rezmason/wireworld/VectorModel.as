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
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
	import net.rezmason.utils.GreenThread;
	import apparat.math.IntMath;
	
	// Adapted from LinkedListModel. 
	// Originally stored WireNode instances in Vectors,
	// but that's just stupid. Instead, it now has a Vector
	// for every WireNode property.
	
	internal final class VectorModel extends BaseModel {

		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		private static const SURVEY_TEMPLATE:Vector.<int> = new <int>[0, 0, 0, 0, 0, 0, 0, 0, 0];
		private static const DARKEN:ColorTransform = new ColorTransform(1, 1, 1, 0.9);

		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private var neighborLookupTable:Array = []; // sparse array of all nodes, listed by index
		
		private var staticSurvey:Vector.<int>;
		private var neighborThread:GreenThread = new GreenThread;
		private var neighborCount:int = 0;
		// Vectors that store nodes (by their address as ints)
		private var headVec:Vector.<int> = new <int>[];
		private var tailVec:Vector.<int> = new <int>[];
		private var newHeadVec:Vector.<int> = new <int>[];
		private var candidateVec:Vector.<int> = new <int>[];
		
		//private var v1:Vector.<int> = headVec, v2:Vector.<int> = tailVec, v3:Vector.<int> = newHeadVec, v4:Vector.<int> = candidateVec;
		
		private var tempVec:Vector.<int>;
		private var totalHeads:int, totalTails:int, totalNewHeads:int, totalCandidates:int;
		
		// Property vectors
		private var isWireVec:Vector.<Boolean> = new <Boolean>[];
		private var xVec:Vector.<int> = new <int>[];
		private var yVec:Vector.<int> = new <int>[];
		private var firstStateVec:Vector.<int> = new <int>[];
		private var neighborCountVec:Vector.<int> = new <int>[];
		private var neighborsVec:Vector.<Vector.<int>> = new <Vector.<int>>[];
		private var timesLitVec:Vector.<int> = new <int>[];
		private var tapsVec:Vector.<int> = new <int>[];
		
		private var ike:int, jen:int, ken:int;
		private var scratch:int;
		private var iNode:int, jNode:int;
		private var neighbor:*;
		
		private var x_:int, y_:int;
		

		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function VectorModel():void {
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
			totalCandidates = 0;
			totalNewHeads = 0;
			
			//		first, list all wires that are adjacent to heads ("candidates")
			ike = 0;
			while (ike < totalHeads) {
				iNode = headVec[ike];
				
				scratch = neighborCountVec[iNode];
				for (jen = 0; jen < scratch; jen += 1) {
					jNode = neighborsVec[iNode][jen];
					if (isWireVec[jNode]) {
						if (tapsVec[jNode] == 0) {
							candidateVec[totalCandidates] = jNode;
							totalCandidates++;
						}
						tapsVec[jNode]++;
					}
				}
				ike++;
			}
			
			//		then, transfer all the candidates with less than 3 neighbors to the new heads list
			ike = 0;
			while (ike < totalCandidates) {
				iNode = candidateVec[ike];
				if (tapsVec[iNode] < 3) {
					isWireVec[iNode] = false;
					timesLitVec[iNode]++;
					newHeadVec[totalNewHeads] = iNode;
					totalNewHeads++;
				}
				tapsVec[iNode] = 0;
				ike++;
			}
			
			// change states
			
			ike = 0;
			while (ike < totalTails) {
				isWireVec[tailVec[ike]] = true;
				ike++;
			}
			
			// swap the vectors
			tempVec = tailVec;
			tailVec = headVec;
			headVec = newHeadVec;
			newHeadVec = tempVec;
			
			totalTails = totalHeads;
			totalHeads = totalNewHeads;
			
			_generation++;
			
			//trace(v1.length, v2.length, v3.length, v4.length)
		}
		
		override public function eraseRect(rect:Rectangle):void {
			// correct the offset
			rect.x -= activeRect.x + 0.5;
			rect.y -= activeRect.y + 0.5;
			
			// clear heads whose centers are within eraseRect
			totalCandidates = 0;
			ike = 0;
			while (ike < totalHeads) {
				iNode = headVec[ike];
				if (rect.contains(xVec[iNode], yVec[iNode])) {
					isWireVec[iNode] = true;
					_heatData.setPixel32(xVec[iNode], yVec[iNode], 0xFF0008000);
				} else {
					candidateVec[totalCandidates] = iNode;
					totalCandidates++;
				}
				ike++;
			}
			
			tempVec = headVec;
			headVec = candidateVec;
			candidateVec = tempVec;
			totalHeads = totalCandidates;
			
			// clear tails whose centers are within eraseRect
			totalCandidates = 0;
			ike = 0;
			while (ike < totalTails) {
				iNode = tailVec[ike];
				if (rect.contains(xVec[iNode], yVec[iNode])) {
					isWireVec[iNode] = true;
					_heatData.setPixel32(xVec[iNode], yVec[iNode], 0xFF0008000);
				} else {
					candidateVec[totalCandidates] = iNode;
					totalCandidates++;
				}
				ike++;
			}
			
			tempVec = tailVec;
			tailVec = candidateVec;
			candidateVec = tempVec;
			totalTails = totalCandidates;
		}
		
		override public function getState(__x:int, __y:int):uint {
			__x -= activeRect.x;
			__y -= activeRect.y;
			return _headData.getPixel32(__x, __y) | _tailData.getPixel32(__x, __y);
		}

		override public function reset():void {
			// empty lists
			headVec.splice(0, headVec.length);
			tailVec.splice(0, tailVec.length);
			newHeadVec.splice(0, newHeadVec.length);
			candidateVec.splice(0, candidateVec.length);
			
			totalHeads = totalTails = totalNewHeads = totalCandidates = 0;
			
			// repopulate
			iNode = 0;
			while (iNode < totalNodes) {
				timesLitVec[iNode] = 0;
				
				switch (firstStateVec[iNode]) {
					case WWFormat.HEAD:
						isWireVec[iNode] = false;
						headVec[totalHeads] = iNode;
						totalHeads++;
						timesLitVec[iNode]++;
						break;
					case WWFormat.TAIL:
						isWireVec[iNode] = false;
						tailVec[totalTails] = iNode;
						totalTails++;
						break;
					case WWFormat.WIRE:
						isWireVec[iNode] = true;
				}
				
				iNode++;
			}
			
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
				
				isWireVec.splice(0, isWireVec.length);
				xVec.splice(0, xVec.length);
				yVec.splice(0, yVec.length);
				firstStateVec.splice(0, firstStateVec.length);
				neighborCountVec.splice(0, neighborCountVec.length);
				neighborsVec.splice(0, neighborsVec.length);
				timesLitVec.splice(0, timesLitVec.length);
				tapsVec.splice(0, tapsVec.length);
				
				totalNodes = 0;
				neighborLookupTable.length = 0;
					
				importer.extract(addNode);
			}
		}
		
		override protected function finishExtraction(event:Event):void {
			importer.dump();
			neighborThread.start();
		}
		
		private function beginFindNeighbors():void {
			staticSurvey = SURVEY_TEMPLATE.slice();
			iNode = 0;
		}
		
		private function checkFindNeighbors():Boolean {
			return (iNode < totalNodes);
		}
		
		private function partialFindNeighbors():void {
			for (ike = 0; ike < STEP && iNode < totalNodes; ike += 1) {
				tempVec = neighborsVec[iNode];
				scratch = xVec[iNode] + yVec[iNode] * _width;
				neighborCount = 0;
				
				scratch -= _width;
				neighbor = neighborLookupTable[scratch - 1];	if (neighbor != undefined) tempVec[neighborCount++] = int(neighbor);
				neighbor = neighborLookupTable[scratch];		if (neighbor != undefined) tempVec[neighborCount++] = int(neighbor);
				neighbor = neighborLookupTable[scratch + 1];	if (neighbor != undefined) tempVec[neighborCount++] = int(neighbor);
				
				scratch += _width;
				neighbor = neighborLookupTable[scratch - 1];	if (neighbor != undefined) tempVec[neighborCount++] = int(neighbor);
				neighbor = neighborLookupTable[scratch + 1];	if (neighbor != undefined) tempVec[neighborCount++] = int(neighbor);
				
				scratch += _width;
				neighbor = neighborLookupTable[scratch - 1];	if (neighbor != undefined) tempVec[neighborCount++] = int(neighbor);
				neighbor = neighborLookupTable[scratch];		if (neighbor != undefined) tempVec[neighborCount++] = int(neighbor);
				neighbor = neighborLookupTable[scratch + 1];	if (neighbor != undefined) tempVec[neighborCount++] = int(neighbor);
				
				tempVec.length = neighborCount;
				tempVec.fixed = true;
				neighborCountVec[iNode] = neighborCount;
				staticSurvey[neighborCount]++;
				iNode++;
			}
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
			while (iNode < totalNodes) {
				if (activeRect.isEmpty()) {
					activeRect.left = xVec[iNode];
					activeRect.top = yVec[iNode];
					activeRect.width = 1;
					activeRect.height = 1;
				} else {
					activeRect.left = IntMath.min(activeRect.left, xVec[iNode]);
					activeRect.top = IntMath.min(activeRect.top, yVec[iNode]);
					activeRect.right = IntMath.max(activeRect.right, xVec[iNode] + 1);
					activeRect.bottom = IntMath.max(activeRect.bottom, yVec[iNode] + 1);
				}
				
				activeCorner.x = activeRect.left;
				activeCorner.y = activeRect.top;
				
				iNode++;
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
			
			iNode = 0;
			while (iNode < totalNodes) {
				xVec[iNode] -= activeRect.x;
				yVec[iNode] -= activeRect.y;
				_wireData.setPixel32(xVec[iNode], yVec[iNode], BLACK);
				iNode++;
			}
		}

		override protected function addNode(__x:int, __y:int, __state:int):void {
			
			// Each property of the node is pushed onto the corresponding Vector. 
			
			isWireVec[totalNodes] = false;
			xVec[totalNodes] = __x;
			yVec[totalNodes] = __y;
			firstStateVec[totalNodes] = __state;
			neighborsVec[totalNodes] = new Vector.<int>(8, false);
			neighborCountVec[totalNodes] = 0;
			timesLitVec[totalNodes] = 0;
			tapsVec[totalNodes] = 0;
			
			neighborLookupTable[__x + _width * __y] = totalNodes;
			totalNodes++;
		}
		
		override protected function refreshHeat(fully:int = 0):void {
			iNode = 0;
			var allow:Boolean;
			var mult:Number = 2.9 / _generation;
			while (iNode < totalNodes) {
				x_ = xVec[iNode];
				y_ = yVec[iNode];
				allow = fully || (x_ >= leftBound && x_ < rightBound && y_ >= topBound && y_ < bottomBound);
				if (allow) _heatData.setPixel32(x_, y_, heatColorOf(timesLitVec[iNode] * mult));
				iNode++;
			}
		}

		override protected function refreshImage(fully:int = 0, freshTails:int = 0):void {
			var allow:Boolean;
			
			if (freshTails) {
				
				_tailData.fillRect(fully ? _tailData.rect : bound, CLEAR);
				
				ike = 0;
				while (ike < totalTails) {
					iNode = tailVec[ike];
					x_ = xVec[iNode];
					y_ = yVec[iNode];
					allow = fully || (x_ >= leftBound && x_ < rightBound && y_ >= topBound && y_ < bottomBound);
					if (allow) _tailData.setPixel32(x_, y_, BLACK);
					ike++;
				}
				
			} else {
				_tailData.copyPixels(_headData, fully ? _tailData.rect : bound, fully ? ORIGIN : bound.topLeft);
			}
			
			_headData.fillRect(fully ? _headData.rect : bound, CLEAR);
			
			ike = 0;
			while (ike < totalHeads) {
				iNode = headVec[ike];
				x_ = xVec[iNode];
				y_ = yVec[iNode];
				allow = fully || (x_ >= leftBound && x_ < rightBound && y_ >= topBound && y_ < bottomBound);
				if (allow) _headData.setPixel32(x_, y_, BLACK);
				ike++
			}
		}
	}
}
