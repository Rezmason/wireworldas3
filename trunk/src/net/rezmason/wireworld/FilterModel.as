/**
* Wireworld Player by Jeremy Sachs. June 8, 2010
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
	import flash.display.BitmapDataChannel;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	
	import flash.filters.ConvolutionFilter;
	
	// Cells in a 2D CA like Wireworld are basically pixels, or image fragments.
	// This model tries to map the simulation to a bitmap filtering problem.
	// Pretty slow.
	
	internal final class FilterModel extends BaseModel {
		
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		private static const RED:uint = 0xFFFF0000, GREEN:uint = 0xFF00FF00, BLUE:uint = 0xFF0000FF;
		private static const SURVEY_TEMPLATE:Vector.<int> = new <int>[0, 0, 0, 0, 0, 0, 0, 0, 0];
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		
		private var _initData:BitmapData;
		private var _tempData:BitmapData;
		private var _wireMask:BitmapData;
		private var _outputData:BitmapData;
		private var _scratchData:BitmapData;
		private var _scratch2Data:BitmapData;
		private var propagate:ConvolutionFilter = new ConvolutionFilter(3, 3, [
			1, 1, 1, 
			1, 0, 1, 
			1, 1, 1
		], 8, 0, true, false, BLACK, 1);

		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function FilterModel():void {}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		// update
		override public function update():void {
			
			// get last state
			_scratchData.copyChannel(_outputData, activeRect, ORIGIN, BitmapDataChannel.BLUE , BitmapDataChannel.BLUE);
			_scratchData.copyChannel(_outputData, activeRect, ORIGIN, BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);
			//_scratchData.copyPixels(_outputData, activeRect, DUMB_POINT);
			
			// These bitmaps a pretty fun to watch.
			_outputData.copyChannel(_wireMask, activeRect, ORIGIN, BitmapDataChannel.RED, BitmapDataChannel.RED); // draw wires
			_scratch2Data.applyFilter(_outputData, activeRect, ORIGIN, propagate); // neighbor data propagates one pixel
			_scratch2Data.threshold(_wireMask, activeRect, ORIGIN, "==", 0, BLACK,	0x00000001); // dead must stay dead
			_scratch2Data.threshold(_scratch2Data, activeRect, ORIGIN, "==", 0, GREEN,	0x00000100); // No less than 1 head neighbor
			_outputData.threshold(_scratch2Data, activeRect, ORIGIN, "==", 0, GREEN,	0x00004000); // No more than 2 head neighbors
			_outputData.threshold(_scratchData, activeRect, ORIGIN, "==", 1, RED, 	0x00000001); // last tails must become wire
			_outputData.threshold(_scratchData, activeRect, ORIGIN, "!=", 0, BLUE,	0x00000100); // last heads must become tails
			
			_generation++;
		}
		
		override public function eraseRect(rect:Rectangle):void {
			// not implemented. Boo!
		}
		
		override public function refreshHeat():void {
			// not implemented. Nyaahh!
		}

		override public function refreshImage():void {
			_headData.copyChannel(_outputData, activeRect, ORIGIN, BitmapDataChannel.GREEN, BitmapDataChannel.ALPHA);
			_tailData.copyChannel(_outputData, activeRect, ORIGIN, BitmapDataChannel.BLUE,  BitmapDataChannel.ALPHA);
		}
		
		override public function refreshAll():void {
			refreshImage();
			refreshHeat();
		}

		override public function getState(__x:int, __y:int):uint {
			__x -= activeCorner.x;
			__y -= activeCorner.y;
			return _headData.getPixel32(__x, __y) | _tailData.getPixel32(__x, __y);
		}

		override public function reset():void {
			
			// returns the bitmaps to their original states
			_wireMask.threshold(_initData, activeRect, ORIGIN, "!=", BLACK, WHITE, WHITE);
			_wireData.copyChannel(_wireMask, activeRect, ORIGIN, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
			_headData.copyChannel(_outputData, activeRect, ORIGIN, BitmapDataChannel.GREEN, BitmapDataChannel.ALPHA);
			_tailData.copyChannel(_outputData, activeRect, ORIGIN, BitmapDataChannel.BLUE,  BitmapDataChannel.ALPHA);
			_outputData.copyPixels(_initData, activeRect, ORIGIN);
			
			_heatData.fillRect(activeRect, BLACK);
			
			refreshAll();
			
			_generation = 1;
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
			
				_tempData = new BitmapData(_width, _height, true, BLACK);
				totalNodes = 0;
			
				importer.extract(addNode);
			}
		}
		
		override protected function finishExtraction(event:Event):void {
			importer.dump();
			trace("node count:", totalNodes);
			initDrawData();
			dispatchEvent(COMPLETE_EVENT);
		}
		
		private function initDrawData():void {
			
			activeRect = _tempData.getColorBoundsRect(WHITE, BLACK, false);
			activeCorner = activeRect.topLeft;
			
			_initData = new BitmapData(activeRect.width, activeRect.height, true, BLACK);
			_initData.copyPixels(_tempData, activeRect, ORIGIN);
			_tempData.dispose();
			_tempData = null;
			
			_wireMask = _initData.clone();
			_outputData = _initData.clone();
			_heatData = _initData.clone();
			_wireData = _initData.clone();
			_headData = _initData.clone();
			_tailData = _initData.clone();
			_scratchData = _initData.clone();
			_scratch2Data = _initData.clone();
			
			
			drawBackground(_baseGraphics, _width, _height, BLACK);
			drawData(_wireGraphics, activeRect, _wireData);
			drawData(_headGraphics, activeRect, _headData);
			drawData(_tailGraphics, activeRect, _tailData);
			drawData(_heatGraphics, activeRect, _heatData);
			
			activeRect = _initData.rect;
		}
		
		override protected function addNode(__x:int, __y:int, __state:int):void {
			totalNodes++;
			_tempData.setPixel32(__x, __y, WireFormat.COLOR_MAP[__state]);
		}
	}
}
