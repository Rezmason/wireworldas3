package net.rezmason.wireworld {
	
	//---------------------------------------
	// IMPORT STATEMENTS
	//---------------------------------------
	
	import flash.display.BitmapData;
	import flash.events.Event;
	
	// Not REALLY the first model ever made; just the first solution
	// to simulating Wireworld that comes to mind. It's meant to do
	// a terrible job.
	
	public final class FirstModel extends BaseModel {
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private var nodeTable:Array = [];
		
		private var ike:int, jen:int, ken:int, leo:int;
		private var scratch:int;
		private var iNode:FirstWireNode, jNode:FirstWireNode;
		

		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function FirstModel() {
			
			super();
			
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		override public function update():void {
			for (ike = 0; ike < _height; ike++) {
				if (!nodeTable[ike]) continue;
				for (jen = 0; jen < _width; jen++) {
					iNode = nodeTable[ike][jen];
					if (!iNode) continue;
					
					switch (iNode.state) {
						case WireFormat.WIRE:
							// count head neighbors; if it's one or two, nextState = HEAD
							scratch = 0;
							outerLoop: for (ken = Math.max(0, ike - 1); ken < Math.min(_height - 1, ike + 2); ken++) {
								if (!nodeTable[ken]) continue;
								for (leo = Math.max(0, jen - 1); leo < Math.min(_width - 1, jen + 2); leo++) {
									if (nodeTable[ken][leo] && nodeTable[ken][leo].state == WireFormat.HEAD) scratch++;
									if (scratch > 2) break outerLoop;
								}
							}
							if (scratch == 1 || scratch == 2) iNode.nextState = WireFormat.HEAD;
						break;
						case WireFormat.HEAD: iNode.nextState = WireFormat.TAIL; break;
						case WireFormat.TAIL: iNode.nextState = WireFormat.WIRE; break;
					}
				}
			}
			
			for (ike = 0; ike < _height; ike++) {
				if (!nodeTable[ike]) continue;
				for (jen = 0; jen < _width; jen++) {
					iNode = nodeTable[ike][jen];
					if (iNode) {
						iNode.state = iNode.nextState;
					}
				}
			}
		}
		
		override public function refreshImage():void {
			
			_headData.fillRect(_headData.rect, 0x0);
			_tailData.fillRect(_tailData.rect, 0x0);
			
			for (ike = 0; ike < _height; ike++) {
				if (!nodeTable[ike]) continue;
				for (jen = 0; jen < _width; jen++) {
					iNode = nodeTable[ike][jen];
					if (!iNode) continue;
					if (iNode.state == WireFormat.HEAD) {
						_headData.setPixel32(jen, ike, BLACK);
					} else if (iNode.state == WireFormat.TAIL) {
						_tailData.setPixel32(jen, ike, BLACK);
					}
				}
			}
		}
		
		override public function reset():void {
			for (ike = 0; ike < _height; ike++) {
				for (jen = 0; jen < _width; jen++) {
					if (!nodeTable[ike]) continue;
					iNode = nodeTable[ike][jen];
					if (iNode) iNode.state = iNode.firstState;
				}
			}
			refreshAll();
		}
		
		//---------------------------------------
		// PRIVATE METHODS
		//---------------------------------------
		
		override protected function finishParse(event:Event):void {
			if (importer.width  > WireFormat.MAX_SIZE || importer.height  > WireFormat.MAX_SIZE || importer.width * importer.height < 1) {
				dispatchEvent(INVALID_SIZE_ERROR_EVENT);
				return;
			} else {
				_width = importer.width;
				_height = importer.height;
				_credit = importer.credit;
				
				// empty everything
				for (ike = 0; ike < nodeTable.length; ike++) {
					nodeTable[ike].length = 0;
				}
				nodeTable.length = 0;
			
				importer.extract(addNode);
			}
		}
		
		override protected function finishExtraction(event:Event):void {
			
			_wireData = new BitmapData(_width, _height, true, CLEAR);
			_headData = _wireData.clone();
			_tailData = _wireData.clone();
			
			drawBackground(_baseGraphics, _width, _height, BLACK);
			drawData(_wireGraphics, _wireData.rect, _wireData);
			drawData(_headGraphics, _headData.rect, _headData);
			drawData(_tailGraphics, _tailData.rect, _tailData);
			
			// draw wires
			for (ike = 0; ike < _height; ike++) {
				for (jen = 0; jen < _width; jen++) {
					if (nodeTable[ike] && nodeTable[ike][jen]) {
						_wireData.setPixel32(jen, ike, BLACK);
					}
				}
			}
			
			dispatchEvent(COMPLETE_EVENT);
		}
		
		override protected function addNode(__x:int, __y:int, __state:int):void {
			nodeTable[__y] ||= [];
			nodeTable[__y][__x] = new FirstWireNode(__x, __y, __state);
		}
	}
}