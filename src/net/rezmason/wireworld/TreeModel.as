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
	import __AS3__.vec.Vector;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import net.rezmason.utils.GreenThread;
	
	// Highly experimental model that uses Bill Gosper's
	// hashlife algorithm, similarly to its implementation
	// in Golly.
	
	// Hashlife uses a humongous hash table and tons of memory,
	// so this model is a resource hog.
	
	// This model is not yet optimized in any way, because it
	// is unfinished. It's missing a garbage collection scheme.
	
	// I won't comment this model until I get it working smoothly.
	
	internal final class TreeModel extends BaseModel {
		
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		
		private static const MAX_CALC_BITE:int = 10000;
		private static const INVALID_NODE_ERROR:Error = new Error("The given node cannot be used with this function.");
		private static const SEPARATOR:String = "|";
		private static const DEAD_LEAF:TreeNode = new TreeNode();
		private static const WIRE_LEAF:TreeNode = new TreeNode();
		private static const HEAD_LEAF:TreeNode = new TreeNode();
		private static const TAIL_LEAF:TreeNode = new TreeNode();
		private static const STATE_TO_LEAF:Vector.<TreeNode> = new <TreeNode>[DEAD_LEAF, WIRE_LEAF, HEAD_LEAF, TAIL_LEAF];
		private static const NEXT_LEAF:Vector.<TreeNode> = new <TreeNode>[null, DEAD_LEAF, HEAD_LEAF, TAIL_LEAF, WIRE_LEAF];
		private static const CONSTRUCTOR_THRESHOLD:Number = 100000; // may eventually change or vary based on time step
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private var uniqueAddress:uint = 1;
		private var emptyNodes:Vector.<TreeNode> = new <TreeNode>[];
		private var _overdriveActive:Boolean;
		private var rootNode:TreeNode, firstRootNode:TreeNode;
		private var rootLevel:int, rootWidth:int;
		private var iNode:TreeNode, jNode:TreeNode;
		private var ike:int, jen:int, ken:int;
		private var prop:String, key:String;
		private var _generationFloat:Number = 0, _overdriveStart:Number = 0;
		private var nodePool:Vector.<Vector.<TreeNode>> = new <Vector.<TreeNode>>[];
		private var hashTable:Vector.<Object> = new <Object>[];
		private var scrap:TreeNode = new TreeNode();
		private var timePow:int, timeStep:int;
		private var nodeCount:int;
		private var exciteNodes:Array;
		
		private var grid:Vector.<Vector.<int>> = new <Vector.<int>>[];
		
		// variables related to the state of the central calculation, which is green-threaded
		private var calcBite:int;
		private var calcDepth:int;
		private var currentCalcDepth:int;
		private var calcItr:int;
		private var calcScope:TreeCalcScope;
		private var calcStack:Vector.<TreeCalcScope>;
		private var calcThread:GreenThread = new GreenThread();
		
		// other useful data structures for recursive functions
		private var stateStack:Vector.<int>;
		private var nodeStack:Vector.<TreeNode>;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function TreeModel():void {
			DEAD_LEAF.address = uniqueAddress++;
			WIRE_LEAF.address = uniqueAddress++;
			HEAD_LEAF.address = uniqueAddress++;
			TAIL_LEAF.address = uniqueAddress++;
			
			DEAD_LEAF.cold = WIRE_LEAF.cold = true;
			
			nodeCount = 0;
			
			calcThread.taskFragment = partialCalc;
			calcThread.condition = checkCalc;
			calcThread.prologue = beginCalc;
			calcThread.epilogue = finishCalc;
		}
		
		//---------------------------------------
		// GETTERS & SETTERS
		//---------------------------------------
		
		override public function get generation():Number { return _generationFloat; }
		override public function get implementsOverdrive():Boolean { return true; }
		override public function get overdriveActive():Boolean { return _overdriveActive; }
		override public function set overdriveActive(value:Boolean):void { 
			_overdriveActive = value;
			resetTime();
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		override public function reset():void {
			rootNode = firstRootNode;
			_generationFloat = 1;
			_tailData.fillRect(_tailData.rect, CLEAR);
			_headData.fillRect(_headData.rect, CLEAR);
			drawPixels(rootNode, 0, 0, rootWidth);
			resetTime();
		}
		
		override public function update():void {
			if (!calcThread.running) {
				calcThread.start();
			}
		}
		
		override public function eraseRect(rect:Rectangle):void {}
		
		override public function refreshAll(fully:Boolean = false):void {}
		
		override public function refreshImage(fully:Boolean = false):void {}
		
		override public function getState(__x:int, __y:int):uint {
			__x -= activeRect.x;
			__y -= activeRect.y;
			return _headData.getPixel32(__x, __y) | _tailData.getPixel32(__x, __y);
		}
		
		//---------------------------------------
		// PRIVATE METHODS
		//---------------------------------------
		
		private function resetTime():void { timePow = 0; timeStep = 1; _overdriveStart = 0; }
		
		private function newNode(nw:TreeNode = null, ne:TreeNode = null, se:TreeNode = null, sw:TreeNode = null):TreeNode {
			var returnVal:TreeNode = nodePool[nw.lev].pop();
			if (!returnVal) {
				// only when the node pool is empty do we make new tree nodes
				returnVal = new TreeNode();
				returnVal.address = uniqueAddress++;
				nodeCount++;
			}
			
			returnVal.nw = nw; returnVal.ne = ne;
			returnVal.sw = sw; returnVal.se = se;
			returnVal.lev = nw.lev + 1;
			returnVal.cold = nw.cold && ne.cold && se.cold && sw.cold;
			
			if (returnVal.cold && nw.lev > 1) {
				// All high-level cold nodes get a permanent hop and a skip, right off the bat.
				setNextNode(returnVal, setNextNode(returnVal, contract(returnVal), true));
			}
			
			return returnVal;
		}
		
		private function getKey(a1:uint, a2:uint, a3:uint, a4:uint):String {
			return a1 + SEPARATOR + a2 + SEPARATOR + a3 + SEPARATOR + a4;
		}
		
		private function getParentNode(nw:TreeNode, ne:TreeNode, se:TreeNode, sw:TreeNode):TreeNode {
			key = getKey(nw.address, ne.address, se.address, sw.address);
			var returnVal:TreeNode = hashTable[nw.lev][key];
			if (!returnVal) {
				returnVal = hashTable[nw.lev][key] = newNode(nw, ne, se, sw);
			}
			return returnVal;
		}
		
		private function getNextNode(node:TreeNode, skip:Boolean = false):TreeNode {
			if (skip) {
				key = getKey(node.skipNW, node.skipNE, node.skipSE, node.skipSW);
			} else {
				key = getKey(node.hopNW, node.hopNE, node.hopSE, node.hopSW);
			}
			return hashTable[node.lev - 2][key];
		}
		
		private function setNextNode(node:TreeNode, next:TreeNode, skip:Boolean = false):TreeNode {
			if (skip) {
				if (!next) {
					node.skipNW = node.skipNE = node.skipSE = node.skipSW = 0;
				} else {
					node.skipNW = next.nw.address;
					node.skipNE = next.ne.address;
					node.skipSE = next.se.address;
					node.skipSW = next.sw.address;
				}
			} else {
				if (!next) {
					node.hopNW = node.hopNE = node.hopSE = node.hopSW = 0;
				} else {
					node.hopNW = next.nw.address;
					node.hopNE = next.ne.address;
					node.hopSE = next.se.address;
					node.hopSW = next.sw.address;
				}
			}
			
			return next;
		}
		
		private function expand(node:TreeNode):TreeNode {
			
			var nothing:TreeNode = emptyNodes[node.lev - 1];
			
			scrap.nw = getParentNode(nothing, nothing, node.nw, nothing);
			scrap.ne = getParentNode(nothing, nothing, nothing, node.ne);
			scrap.se = getParentNode(node.se, nothing, nothing, nothing);
			scrap.sw = getParentNode(nothing, node.sw, nothing, nothing);
			
			return getParentNode(scrap.nw, scrap.ne, scrap.se, scrap.sw);
		}
		
		private function contract(node:TreeNode):TreeNode {
			return getParentNode(node.nw.se, node.ne.sw, node.se.nw, node.sw.ne);
		}
		
		override protected function finishParse(event:Event):void {
			if (importer.width  > WireFormat.MAX_SIZE || importer.height  > WireFormat.MAX_SIZE || importer.width * importer.height < 1) {
				dispatchEvent(INVALID_SIZE_ERROR_EVENT);
				return;
			} else {
				_width = importer.width;
				_height = importer.height;
				_credit = importer.credit;
				grid.length = _height;
				activeRect.setEmpty();
				totalNodes = 0;
				_wireData = new BitmapData(_width, _height, true, CLEAR);
				
				importer.extract(addNode); // addNode
			}
		}
		
		override protected function finishExtraction(event:Event):void {
			importer.dump();
			
			// MAKE A NEW TREE
			ike = Math.max(activeRect.width, activeRect.height);
			rootLevel = 0, rootWidth = 1;
			while (rootWidth <= ike) rootWidth *= 2, rootLevel++;
			calcStack = new Vector.<TreeCalcScope>(rootLevel + 2, true);
			stateStack = new Vector.<int>(rootLevel + 1, true);
			nodeStack = new Vector.<TreeNode>(rootLevel + 1, true);
			for (ike = 0; ike < calcStack.length; ike++) {
				calcStack[ike] = new TreeCalcScope();
			}
			hashTable.length = Math.max(hashTable.length, rootLevel + 1);
			nodePool.length = hashTable.length;
			for (ike = 0; ike < hashTable.length; ike++) {
				hashTable[ike] ||= {};
				nodePool[ike] ||= new Vector.<TreeNode>();
			}
			
			ike = 1, iNode = DEAD_LEAF;
			emptyNodes.length = rootLevel + 1;
			emptyNodes[0] = iNode;
			while (ike < emptyNodes.length) {
				emptyNodes[ike] = iNode = getParentNode(iNode, iNode, iNode, iNode);
				ike++;
			}
			
			makeTree();
			
			initDrawData();
			
			dispatchEvent(COMPLETE_EVENT);
		}
		
		private function initDrawData():void {
			
			var tempData:BitmapData = _wireData;
			
			_wireData = new BitmapData(activeRect.width + 1, activeRect.height + 1, true, CLEAR);
			_headData = new BitmapData(activeRect.width + 1, activeRect.height + 1, true, CLEAR);
			_tailData = new BitmapData(activeRect.width + 1, activeRect.height + 1, true, CLEAR);
			
			_wireData.copyPixels(tempData, activeRect, ORIGIN);
			
			drawBackground(_baseGraphics, _width, _height, BLACK);
			drawData(_wireGraphics, activeRect, _wireData);
			drawData(_headGraphics, activeRect, _headData);
			drawData(_tailGraphics, activeRect, _tailData);
			
			activeCorner.x = activeRect.left;
			activeCorner.y = activeRect.top;
			
		}
		
		override protected function addNode(__x:int, __y:int, __state:int):void {
			grid[__y] ||= new Vector.<int>();
			grid[__y].length = _width;
			grid[__y][__x] = __state + 1;
			_wireData.setPixel32(__x, __y, BLACK);
			
			if (activeRect.isEmpty()) {
				activeRect.left = __x;
				activeRect.top = __y;
				activeRect.right = __x + 1;
				activeRect.bottom = __y + 1;
			} else {
				activeRect.left = Math.min(activeRect.left, __x);
				activeRect.top = Math.min(activeRect.top, __y);
				activeRect.right = Math.max(activeRect.right, __x + 1);
				activeRect.bottom = Math.max(activeRect.bottom, __y + 1);
			}
		}
		
		private function drawPixels(node:TreeNode, currentX:int, currentY:int, currentWidth:int):void {
			
			if (!node) return;
			
			// drawPixels is used to draw any portion of the tree.
			// NOTE: drawPixels is an unwrapped recursive function.
			
			stateStack[0] = 0;
			nodeStack[0] = node;
			
			ike = 0;
			while (ike > -1) {
				iNode = nodeStack[ike];
				
				switch (stateStack[ike]) {
					case 0:
						if (iNode.lev == 0) {
							if (!iNode.cold) {
								((iNode == HEAD_LEAF) ? _headData : _tailData).setPixel32(currentX, currentY, BLACK);
							}
							ike--;
						} else if (iNode.cold) {
							ike--;
						} else {
							currentWidth >>= 1, stateStack[ike++]++;
							nodeStack[ike] = iNode.nw, stateStack[ike] = 0;
						}
					break;
					case 1:
						currentX += currentWidth, stateStack[ike++]++;
						nodeStack[ike] = iNode.ne, stateStack[ike] = 0;
					break;
					case 2:
						currentY += currentWidth, stateStack[ike++]++;
						nodeStack[ike] = iNode.se, stateStack[ike] = 0;
					break;
					case 3:
						currentX -= currentWidth, stateStack[ike++]++;
						nodeStack[ike] = iNode.sw, stateStack[ike] = 0;
					break;
					case 4:
						currentY -= currentWidth, ike--;
						currentWidth <<= 1;
					break;
				}
			}
		}
		
		private function makeTree():void {
			
			// makeTree is used to extract the tree from grid.
			// NOTE: makeTree is an unwrapped recursive function.
			
			var nX:int = 0, nY:int = 0, nLevel:int = rootLevel, nWidth:int = rootWidth;
			var nOX:int, nOY:int, nPow:Number;
			
			var parameters:Vector.<TreeNode> = new <TreeNode>[];
			var result:TreeNode;
			stateStack[0] = 0;
			
			ike = 0;
			while (ike > -1) {
				switch (stateStack[ike]) {
					case 0:
						if (nLevel == 1) {
							scrap.nw = scrap.ne = scrap.se = scrap.sw = DEAD_LEAF;
							
							nOY = nY + activeRect.y;
							nOX = nX + activeRect.x;
								
							if (nOY < _height && grid[nOY + 0] && nOX < _width) {
									scrap.nw = STATE_TO_LEAF[grid[nOY + 0][nOX + 0]];
									if (nOX + 1 < _width) scrap.ne = STATE_TO_LEAF[grid[nOY + 0][nOX + 1]];
								if (nOY + 1 < _height && grid[nOY + 1]) {
									scrap.sw = STATE_TO_LEAF[grid[nOY + 1][nOX + 0]];
									if (nOX + 1 < _width) scrap.se = STATE_TO_LEAF[grid[nOY + 1][nOX + 1]];
								}
							}
						
							result = getParentNode(scrap.nw, scrap.ne, scrap.se, scrap.sw);
							ike--;
						} else {
							nLevel--, nWidth >>= 1, stateStack[ike++]++;
							nY += nWidth;
							stateStack[ike] = 0;
						}
					break;
					case 1:
						parameters.push(result);
						nX += nWidth, stateStack[ike++]++;
						stateStack[ike] = 0;
					break;
					case 2:
						parameters.push(result);
						nY -= nWidth, stateStack[ike++]++;
						stateStack[ike] = 0;
					break;
					case 3:
						parameters.push(result);
						nX -= nWidth, stateStack[ike++]++;
						stateStack[ike] = 0;
					break;
					case 4:
						parameters.push(result);
						ike--;
						nLevel++, nWidth <<= 1;
						result = getParentNode(parameters.pop(), parameters.pop(), parameters.pop(), parameters.pop());
					break;
				}
			}
			
			firstRootNode = result;
			
			grid.length = 0;
		}
		
		private function writeCalcTable(scope:TreeCalcScope):void {
			scope.table[0] = scope.node.nw; scope.table[2] = scope.node.ne;
			scope.table[6] = scope.node.sw; scope.table[8] = scope.node.se;
			
			scope.table[1] = getParentNode(scope.table[0].ne, scope.table[2].nw, scope.table[2].sw, scope.table[0].se);
			scope.table[5] = getParentNode(scope.table[2].sw, scope.table[2].se, scope.table[8].ne, scope.table[8].nw);
			scope.table[7] = getParentNode(scope.table[6].ne, scope.table[8].nw, scope.table[8].sw, scope.table[6].se);
			scope.table[3] = getParentNode(scope.table[0].sw, scope.table[0].se, scope.table[6].ne, scope.table[6].nw);
			scope.table[4] = getParentNode(scope.table[0].se, scope.table[2].sw, scope.table[8].nw, scope.table[6].ne);
		}
		
		private function beginCalc():void {
			dispatchEvent(BUSY_EVENT);
			
			// identify the level separating hop and skip modes
			calcDepth = rootLevel - timePow - 1;
			
			currentCalcDepth = calcDepth;
			calcItr = 0;
			calcStack[0].type = 0;
			
			// feed the root node into the calculation
			calcStack[0].node = expand(rootNode);
		}
		
		private function checkCalc():Boolean {
			return (calcItr > -1);
		}
		
		private function finishCalc():void {
			// set the root node to the result node of the calculation
			rootNode = calcStack[0].node;
			
			_generationFloat += timeStep;
			
			// redraw
			_tailData.fillRect(_tailData.rect, CLEAR);
			_headData.fillRect(_headData.rect, CLEAR);
			drawPixels(rootNode, 0, 0, rootWidth);
			
			// advance the overdrive
			if (_overdriveActive) {
				_overdriveStart += 1;
				if (_overdriveStart > timeStep) {
					timePow += 1;
					timeStep <<= 1;
					_overdriveStart = 0;
				}
			}
			
			if (nodeCount > CONSTRUCTOR_THRESHOLD) {
				nodeCount = 0;
			}
			
			dispatchEvent(IDLE_EVENT);
		}
		
		private function partialCalc():void {
			calcBite = 0;
			// When calcItr is -1, the process has ended.
			while (calcItr > -1 && calcBite++ < MAX_CALC_BITE) {
				calcScope = calcStack[calcItr];
				switch (calcScope.state) {
					case 0:
						if (calcScope.type == 0) {
							if (currentCalcDepth > 0) {
								// start hop mode
								if (!((calcScope.node.cold || calcScope.node.hopLev == calcDepth) && getNextNode(calcScope.node))) {
									// the node we want isn't in the hash; dig in hop
									calcScope.node.hopLev = calcDepth;
									currentCalcDepth--;
									writeCalcTable(calcScope);
									calcItr++;
									calcStack[calcItr].mult = 0;
									calcStack[calcItr].state = 0;
									calcStack[calcItr].type = 0;
									calcStack[calcItr].node = calcScope.table[calcScope.state];
									calcScope.state++;
								} else {
									// point to the node and back out
									calcScope.node = getNextNode(calcScope.node);
									calcItr--;
								}
							} else {
								// start skip mode
								calcScope.mult = Math.pow(2, -currentCalcDepth);
								calcScope.type = 1;
								calcScope.state = 0;
							}
						} else if (calcScope.type == 1) {
							// we're in skip mode
							if (!getNextNode(calcScope.node, true)) {
								// the node we want isn't in the hash
								if (calcScope.node.lev == 2) {
									// the current node is at the active level
									scrap.nw = NEXT_LEAF[calcScope.node.nw.se.address];
									scrap.ne = NEXT_LEAF[calcScope.node.ne.sw.address];
									scrap.se = NEXT_LEAF[calcScope.node.se.nw.address];
									scrap.sw = NEXT_LEAF[calcScope.node.sw.ne.address];
		
									if (scrap.nw == HEAD_LEAF && !excite(calcScope.node, 0)) scrap.nw = WIRE_LEAF;
									if (scrap.ne == HEAD_LEAF && !excite(calcScope.node, 1)) scrap.ne = WIRE_LEAF;
									if (scrap.se == HEAD_LEAF && !excite(calcScope.node, 2)) scrap.se = WIRE_LEAF;
									if (scrap.sw == HEAD_LEAF && !excite(calcScope.node, 3)) scrap.sw = WIRE_LEAF;
		
									setNextNode(calcScope.node, getParentNode(scrap.nw, scrap.ne, scrap.se, scrap.sw), true);
									calcScope.node = getNextNode(calcScope.node, true);
									calcItr--;
								} else {
									// the current node is above the active level; dig in skip
									writeCalcTable(calcScope);
									calcItr++;
									calcStack[calcItr].type = 1;
									calcStack[calcItr].mult = 1;
									calcStack[calcItr].state = 0;
									calcStack[calcItr].node = calcScope.table[calcScope.state];
									calcScope.state++;
								}
							} else {
								// point to the node and back out
								calcScope.node = getNextNode(calcScope.node, true);
								calcItr--;
							}
						}
						break;
					case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8:
					case 10: case 11: case 12:
						// copy the result to the table and dig in again
						calcItr++;
						calcScope.table[calcScope.state - 1] = calcStack[calcItr].node;
						calcStack[calcItr].node = calcScope.table[calcScope.state];
						calcScope.state++;
						break;
					case 9:
						// copy the last result to the table
						calcScope.table[calcScope.state - 1] = calcStack[calcItr + 1].node;
						if (calcScope.type == 0) {
							// hop mode: glue together the table's contents
							calcScope.table[09] = getParentNode(calcScope.table[0].se, calcScope.table[1].sw, calcScope.table[4].nw, calcScope.table[3].ne);
							calcScope.table[10] = getParentNode(calcScope.table[1].se, calcScope.table[2].sw, calcScope.table[5].nw, calcScope.table[4].ne);
							calcScope.table[11] = getParentNode(calcScope.table[4].se, calcScope.table[5].sw, calcScope.table[8].nw, calcScope.table[7].ne);
							calcScope.table[12] = getParentNode(calcScope.table[3].se, calcScope.table[4].sw, calcScope.table[7].nw, calcScope.table[6].ne);
							
							// set the next node and point to it
							setNextNode(calcScope.node, getParentNode(calcScope.table[09], calcScope.table[10], calcScope.table[11], calcScope.table[12]));
							calcScope.node = getNextNode(calcScope.node);
							
							// reset the scope and back out
							calcScope.state = 0;
							calcScope.type = 0;
		
							currentCalcDepth++;
							calcItr--;
						} else if (calcScope.type == 1) {
							
							// skip mode: glue together the table's contents
							calcScope.table[09] = getParentNode(calcScope.table[0], calcScope.table[1], calcScope.table[4], calcScope.table[3]);
							calcScope.table[10] = getParentNode(calcScope.table[1], calcScope.table[2], calcScope.table[5], calcScope.table[4]);
							calcScope.table[11] = getParentNode(calcScope.table[4], calcScope.table[5], calcScope.table[8], calcScope.table[7]);
							calcScope.table[12] = getParentNode(calcScope.table[3], calcScope.table[4], calcScope.table[7], calcScope.table[6]);
							
							// dig in skip again
							calcItr++;
							calcStack[calcItr].node = calcScope.table[calcScope.state];
							calcScope.state++;
						}
						break;
					case 13:
						
						// wrap up skip mode
						
						// copy the last result to the table
						calcScope.table[calcScope.state - 1] = calcStack[calcItr + 1].node;
		
						// set the next node and point to it
						setNextNode(calcScope.node, getParentNode(calcScope.table[09], calcScope.table[10], calcScope.table[11], calcScope.table[12]), true);
						calcScope.node = getNextNode(calcScope.node, true);
						
						// reset the scope
						calcScope.state = 0;
						calcScope.type = 1;
		
						// if the multiplier hasn't run down
						if (calcItr == 0 && --calcScope.mult > 0) {
							// repeat
							calcScope.node = expand(calcScope.node);
						} else {
							// otherwise back out
							calcItr--;
						}
						break;
				}
			}
		}
		
		private function excite(tn:TreeNode, quadrant:int):Boolean {
			
			switch (quadrant) {
				case 0: exciteNodes = [tn.nw.nw, tn.nw.ne, tn.ne.nw, tn.nw.sw, tn.ne.sw, tn.sw.nw, tn.sw.ne, tn.se.nw]; break;
				case 1: exciteNodes = [tn.nw.ne, tn.ne.nw, tn.ne.ne, tn.nw.se, tn.ne.se, tn.sw.ne, tn.se.nw, tn.se.ne]; break;
				case 3: exciteNodes = [tn.nw.sw, tn.nw.se, tn.ne.sw, tn.sw.nw, tn.se.nw, tn.sw.sw, tn.sw.se, tn.se.sw]; break;
				case 2: exciteNodes = [tn.nw.se, tn.ne.sw, tn.ne.se, tn.sw.ne, tn.se.ne, tn.sw.se, tn.se.sw, tn.se.se]; break;
			}
			
			ike = 0;
			while (exciteNodes.length) {
				if (exciteNodes.pop() == HEAD_LEAF) ike++;
			}
			
			return (ike == 1 || ike == 2);
		}
	}
}