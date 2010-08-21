/**
* Wireworld Player by Jeremy Sachs. August 21, 2010
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
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Shader;
	import flash.events.Event;
	import flash.filters.ShaderFilter;
	import flash.utils.ByteArray;
	
	import net.rezmason.wireworld.IModel;
	import net.rezmason.wireworld.WWRefreshFlag;
	
	// Lightweight, similar to FilterModel.
	// This model's actually pretty slow.
	
	public final class PixelBenderModel extends BaseModel {
		
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		private static const SURVEY_TEMPLATE:Vector.<int> = new <int>[0, 0, 0, 0, 0, 0, 0, 0, 0];
		
		[Embed(source='../../../../../pixelbender/wireworldnaive.pbj', mimeType="application/octet-stream")]
		private static const WireworldPBJ:Class;
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		
		private var _initData:BitmapData;
		private var _tempData:BitmapData;
		private var _wireMask:BitmapData;
		private var _outputData:BitmapData;
		
		private var wireworldShader:Shader;
		private var wireworldFilter:ShaderFilter;
		

		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function PixelBenderModel():void {
			wireworldShader = new Shader(new WireworldPBJ() as ByteArray);
			wireworldFilter = new ShaderFilter(wireworldShader);
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		// update
		override public function update():void {
			// Most of the dirty work is done by the filter.
			_outputData.applyFilter(_outputData, activeRect, ORIGIN, wireworldFilter);
			_generation++;
		}
		override public function getState(__x:int, __y:int):uint {
			__x -= activeCorner.x;
			__y -= activeCorner.y;
			return _headData.getPixel32(__x, __y) | _tailData.getPixel32(__x, __y);
		}

		override public function reset():void {
			_wireMask.threshold(_initData, activeRect, ORIGIN, "!=", BLACK, WHITE, WHITE);
			_wireData.copyChannel(_wireMask, activeRect, ORIGIN, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
			_headData.copyChannel(_outputData, activeRect, ORIGIN, BitmapDataChannel.GREEN, BitmapDataChannel.ALPHA);
			_tailData.copyChannel(_outputData, activeRect, ORIGIN, BitmapDataChannel.BLUE,  BitmapDataChannel.ALPHA);
			_outputData.copyPixels(_initData, activeRect, ORIGIN);
			
			_heatData.fillRect(activeRect, BLACK);
			
			refresh(WWRefreshFlag.FULL | WWRefreshFlag.TAIL);
			
			_generation = 1;
		}

		//---------------------------------------
		// PRIVATE METHODS
		//---------------------------------------
		
		// Validates the imported data dimensions 
		// and passes addNode to the importer
		override protected function finishParse(event:Event):void {
			if (importer.width  > WWFormat.MAX_SIZE || importer.height  > WWFormat.MAX_SIZE || importer.width * importer.height < 1) {
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
		
		// Finds the active portion of the Wireworld instance and draws it
		// over a solid background
		private function initDrawData():void {
			
			activeRect = _tempData.getColorBoundsRect(WHITE, BLACK, false);
			activeCorner = activeRect.topLeft;
			
			if (_initData) _initData.dispose();
			if (_wireMask) _wireMask.dispose();
			if (_outputData) _outputData.dispose();
			if (_heatData) _heatData.dispose();
			if (_wireData) _wireData.dispose();
			if (_headData) _headData.dispose();
			if (_tailData) _tailData.dispose();
			
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
			
			drawBackground(_baseGraphics, _width, _height, BLACK);
			drawData(_wireGraphics, activeRect, _wireData);
			drawData(_headGraphics, activeRect, _headData);
			drawData(_tailGraphics, activeRect, _tailData);
			drawData(_heatGraphics, activeRect, _heatData);
			
			activeRect = _initData.rect;
		}
		
		// Draws the node as a colored pixel to a temporary bitmap.
		override protected function addNode(__x:int, __y:int, __state:int):void {
			totalNodes++;
			_tempData.setPixel32(__x, __y, WWFormat.COLOR_MAP[__state]);
		}
		
		override protected function refreshHeat(fully:int):void {
			// not implemented. Nyaahh!
		}
		
		// The model IS its own view, in a sense 
		override protected function refreshImage(fully:int, freshTails:int):void {
			_headData.lock();
			_tailData.lock();
			_headData.copyChannel(_outputData, activeRect, ORIGIN, BitmapDataChannel.GREEN, BitmapDataChannel.ALPHA);
			_tailData.copyChannel(_outputData, activeRect, ORIGIN, BitmapDataChannel.BLUE,  BitmapDataChannel.ALPHA);
			_headData.unlock();
			_tailData.unlock();
		}
		
	}
}
