﻿/*** Wireworld Player by Jeremy Sachs. June 22, 2010** Feel free to distribute the source, just try not to hand it off to some douchebag.* Keep this header here.** Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.*/package net.rezmason.wireworld {	//---------------------------------------	// IMPORT STATEMENTS	//---------------------------------------	import flash.display.BitmapData;	import flash.events.Event;	import flash.geom.ColorTransform;	import flash.geom.Rectangle;		import net.rezmason.utils.GreenThread;		import apparat.math.IntMath;		// The first model made, based on linked lists. Also the second fastest,	// by a smidge.		// The nodes in this model are instances of WireNode, a flyweight	// with a "next" pointer.		internal final class LinkedListModel extends BaseModel {				//---------------------------------------		// CLASS CONSTANTS		//---------------------------------------		private static const SURVEY_TEMPLATE:Vector.<int> = new <int>[0, 0, 0, 0, 0, 0, 0, 0, 0];		private static const DARKEN:ColorTransform = new ColorTransform(1, 1, 1, 0.9);				// The three major models use NULL instead of null, so that they can		// be modified more easily into other models.		private static const NULL:WireNode = new WireNode(-1, -1, -1);				//---------------------------------------		// PRIVATE VARIABLES		//---------------------------------------		private var neighborLookupTable:Array = []; // sparse array of all nodes, listed by index		private var pool:Vector.<WireNode> = new <WireNode>[]; // vector of all nodes		private var tempVec:Vector.<WireNode>;		private var totalHeads:int;		private var staticSurvey:Vector.<int>;		private var neighborThread:GreenThread = new GreenThread;		private var neighborCount:int = 0;				private var headFront:WireNode = NULL, headBack:WireNode = NULL; // linked list of nodes that are currently electron heads		private var tailFront:WireNode = NULL, tailBack:WireNode = NULL; // linked list of nodes that are currently electron tails		private var newHeadFront:WireNode = NULL, newHeadBack:WireNode = NULL; // linked list of nodes that are becoming electron heads				private var ike:int, jen:int, ken:int;		private var pItr:int;		private var scratch:int;		private var iNode:WireNode, jNode:WireNode;		private var neighbor:*;				private var x_:int, y_:int;		//---------------------------------------		// CONSTRUCTOR		//---------------------------------------		public function LinkedListModel():void {			neighborThread.taskFragment = partialFindNeighbors;			neighborThread.condition = checkFindNeighbors;			neighborThread.prologue = beginFindNeighbors;			neighborThread.epilogue = finishFindNeighbors;		}				//---------------------------------------		// PUBLIC METHODS		//---------------------------------------				// update		override public function update():void {			// find new heads in current head neighbors (and list them)						//		first, list all wires that are adjacent to heads			iNode = headFront;			while (iNode != NULL) {				scratch = iNode.neighbors.length;				for (ike = 0; ike < scratch; ike += 1) {					jNode = iNode.neighbors[ike];					if (jNode.isWire) {						if (!jNode.taps) {							if (newHeadFront == NULL) {								newHeadFront = jNode;							} else {								newHeadBack.next = jNode;							}							newHeadBack = jNode;						}						jNode.taps++;					}				}				iNode = iNode.next;			}			if (newHeadBack != NULL) {				newHeadBack.next = NULL;			}						//		then, remove from the list all nodes with more than two head neighbors			iNode = newHeadFront;			while (iNode != NULL) {				if (iNode.taps > 2) {					newHeadFront = iNode.next;					iNode.taps = 0;					iNode = iNode.next;				} else {					iNode.taps = 0;					break;				}			}						totalHeads = 0;						if (iNode != NULL) {				jNode = iNode.next;				while (jNode != NULL) {					if (jNode.taps > 2) {						iNode.next = jNode.next;					} else {						totalHeads++;						iNode = jNode;					}					jNode.taps = 0;					jNode = jNode.next;				}			}						// change states						iNode = tailFront;			while (iNode != NULL) {				iNode.isWire = true;				iNode = iNode.next;			}						iNode = newHeadFront;			while (iNode != NULL) {				iNode.isWire = false;				iNode.timesLit++;				iNode = iNode.next;			}						// swap the linked lists			tailFront = headFront;			headFront = newHeadFront;			newHeadBack = newHeadFront = NULL;						_generation++;		}				override public function eraseRect(rect:Rectangle):void {			// correct the offset			rect.x -= activeRect.x + 0.5;			rect.y -= activeRect.y + 0.5;						// clear heads whose centers are within eraseRect			iNode = headFront;			while (iNode.next != NULL) {				jNode = iNode.next;				if (rect.contains(jNode.x, jNode.y)) {					jNode.isWire = true;					iNode.next = jNode.next;					_heatData.setPixel32(jNode.x, jNode.y, 0xFF0008000);				} else {					iNode = jNode;				}			}						// clear tails whose centers are within eraseRect			iNode = tailFront;			while (iNode.next != NULL) {				jNode = iNode.next;				if (rect.contains(jNode.x, jNode.y)) {					jNode.isWire = true;					iNode.next = jNode.next;					_heatData.setPixel32(jNode.x, jNode.y, 0xFF0008000);				} else {					iNode = jNode;				}			}		}				override public function getState(__x:int, __y:int):uint {			__x -= activeRect.x;			__y -= activeRect.y;			return _headData.getPixel32(__x, __y) | _tailData.getPixel32(__x, __y);		}		override public function reset():void {			// empty lists			emptyList(headFront);			emptyList(tailFront);			emptyList(newHeadFront);			// repopulate			headBack = headFront = NULL;			tailBack = tailFront = NULL;						pItr = 0;			while (pItr < totalNodes) {				iNode = pool[pItr];				iNode.timesLit = 0;								switch (iNode.firstState) {					case WWFormat.HEAD:						iNode.isWire = false;						if (headFront == NULL) {							headFront = iNode;						} else {							headBack.next = iNode;						}						headBack = iNode;						iNode.timesLit++;						break;					case WWFormat.TAIL:						iNode.isWire = false;						if (tailFront == NULL) {							tailFront = iNode;						} else {							tailBack.next = iNode;						}						tailBack = iNode;						break;					case WWFormat.WIRE:						iNode.isWire = true;				}								pItr++;			}						if (headBack != NULL) {				headBack.next = NULL;			}			if (tailBack != NULL) {				tailBack.next = NULL;			}			_heatData.fillRect(_heatData.rect, CLEAR);			refresh(WWRefreshFlag.FULL | WWRefreshFlag.TAIL);						_generation = 1;		}		//---------------------------------------		// PRIVATE METHODS		//---------------------------------------				override protected function finishParse(event:Event):void {						if (importer.width  > WWFormat.MAX_SIZE || importer.height  > WWFormat.MAX_SIZE || importer.width * importer.height < 1) {				dispatchEvent(INVALID_SIZE_ERROR_EVENT);			} else {				_width = importer.width;				_height = importer.height;				_credit = importer.credit;							neighborLookupTable.length = 0;				pItr = 0;				while (pItr < totalNodes) {					pool[pItr].next = NULL;					pItr++;				}				pool.splice(0, totalNodes);								importer.extract(addNode);			}		}				override protected function finishExtraction(event:Event):void {			importer.dump();			totalNodes = pool.length;			neighborThread.start();		}				private function beginFindNeighbors():void {			staticSurvey = SURVEY_TEMPLATE.slice();			pItr = 0;		}				private function checkFindNeighbors():Boolean {			return (pItr < totalNodes);		}				private function partialFindNeighbors():void {			for (ike = 0; ike < STEP && pItr < totalNodes; ike += 1) {				iNode = pool[pItr];				tempVec = iNode.neighbors;				scratch = iNode.x + iNode.y * _width;				neighborCount = 0;				scratch -= _width;				neighbor = neighborLookupTable[scratch - 1];	if (neighbor != undefined) tempVec[neighborCount++] = neighbor as WireNode;				neighbor = neighborLookupTable[scratch];		if (neighbor != undefined) tempVec[neighborCount++] = neighbor as WireNode;				neighbor = neighborLookupTable[scratch + 1]; 	if (neighbor != undefined) tempVec[neighborCount++] = neighbor as WireNode;				scratch += _width;				neighbor = neighborLookupTable[scratch - 1];	if (neighbor != undefined) tempVec[neighborCount++] = neighbor as WireNode;				neighbor = neighborLookupTable[scratch + 1];	if (neighbor != undefined) tempVec[neighborCount++] = neighbor as WireNode;				scratch += _width;				neighbor = neighborLookupTable[scratch - 1];	if (neighbor != undefined) tempVec[neighborCount++] = neighbor as WireNode;				neighbor = neighborLookupTable[scratch];		if (neighbor != undefined) tempVec[neighborCount++] = neighbor as WireNode;				neighbor = neighborLookupTable[scratch + 1];	if (neighbor != undefined) tempVec[neighborCount++] = neighbor as WireNode;				tempVec.length = neighborCount;				tempVec.fixed = true;				staticSurvey[neighborCount]++;				pItr++;			}		}				private function finishFindNeighbors():void {			neighborLookupTable.length = 0;						initDrawData(); // This sounds like it should belong in the View, but it really doesn't.						trace(totalNodes, "total nodes")			trace("staticSurvey:", staticSurvey);			trace("1-2:", staticSurvey[1] + staticSurvey[2]);			trace("3-4:", staticSurvey[3] + staticSurvey[4]);			trace("5-7:", staticSurvey[5] + staticSurvey[6] + staticSurvey[7]);						dispatchEvent(COMPLETE_EVENT);		}				private function initDrawData():void {			activeRect.setEmpty();			pItr = 0;			while (pItr < totalNodes) {				iNode = pool[pItr];				if (activeRect.isEmpty()) {					activeRect.left = iNode.x;					activeRect.top = iNode.y;					activeRect.width = 1;					activeRect.height = 1;				} else {					activeRect.left = IntMath.min(activeRect.left, iNode.x);					activeRect.top = IntMath.min(activeRect.top, iNode.y);					activeRect.right = IntMath.max(activeRect.right, iNode.x + 1);					activeRect.bottom = IntMath.max(activeRect.bottom, iNode.y + 1);				}								activeCorner.x = activeRect.left;				activeCorner.y = activeRect.top;								pItr++;			}						if (_wireData) _wireData.dispose();			if (_headData) _wireData.dispose();			if (_tailData) _wireData.dispose();			if (_heatData) _wireData.dispose();						// The BitmapData objects only need to be as large as the active rectangle, with a one-pixel border to prevent artifacts.			_wireData = new BitmapData(activeRect.width + 1, activeRect.height + 1, true, CLEAR);			_headData = new BitmapData(activeRect.width + 1, activeRect.height + 1, true, CLEAR);			_tailData = new BitmapData(activeRect.width + 1, activeRect.height + 1, true, CLEAR);			_heatData = new BitmapData(activeRect.width + 1, activeRect.height + 1, true, CLEAR);						drawBackground(_baseGraphics, _width, _height, BLACK);			drawData(_wireGraphics, activeRect, _wireData);			drawData(_headGraphics, activeRect, _headData);			drawData(_tailGraphics, activeRect, _tailData);			drawData(_heatGraphics, activeRect, _heatData);						pItr = 0;			while (pItr < totalNodes) {				iNode = pool[pItr];				iNode.x -= activeRect.x;				iNode.y -= activeRect.y;				_wireData.setPixel32(iNode.x, iNode.y, BLACK);				pItr++;			}		}		override protected function addNode(__x:int, __y:int, __state:int):void {			iNode = new WireNode(__x, __y, __state);			neighborLookupTable[__x + _width * __y] = iNode;			pool.push(iNode);		}				private function emptyList(node:WireNode):void {			iNode = node;			while (iNode != NULL) {				jNode = iNode.next;				iNode.next = NULL;				iNode = jNode;			}		}				override protected function refreshHeat(fully:int = 0):void {			_heatData.lock();			iNode = headFront;			var allow:Boolean;			var mult:Number = 2.9 / _generation;			while (iNode != NULL) {				x_ = iNode.x;				y_ = iNode.y;				allow = fully || (x_ >= leftBound && x_ < rightBound && y_ >= topBound && y_ < bottomBound);				if (allow) _heatData.setPixel32(x_, y_, heatColorOf(iNode.timesLit * mult));				iNode = iNode.next;			}			_heatData.unlock();		}		override protected function refreshImage(fully:int = 0, freshTails:int = 0):void {						var allow:Boolean;						_tailData.lock();			_headData.lock();			if (freshTails) {								_tailData.fillRect(fully ? _tailData.rect : bound, CLEAR);								iNode = tailFront;				while (iNode != NULL) {					x_ = iNode.x;					y_ = iNode.y;					allow = fully || (x_ >= leftBound && x_ < rightBound && y_ >= topBound && y_ < bottomBound);					if (allow) _tailData.setPixel32(x_, y_, BLACK);					iNode = iNode.next;				}							} else {				_tailData.copyPixels(_headData, fully ? _tailData.rect : bound, fully ? ORIGIN : bound.topLeft);			}						_headData.fillRect(fully ? _headData.rect : bound, CLEAR);						iNode = headFront;			while (iNode != NULL) {				x_ = iNode.x;				y_ = iNode.y;				allow = fully || (x_ >= leftBound && x_ < rightBound && y_ >= topBound && y_ < bottomBound);				if (allow) _headData.setPixel32(x_, y_, BLACK);				iNode = iNode.next;			}			_tailData.unlock();			_headData.unlock();		}	}}