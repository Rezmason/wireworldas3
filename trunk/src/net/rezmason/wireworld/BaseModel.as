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
	import flash.display.Graphics;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.rezmason.utils.makeGraphics;
	
	import spark.primitives.Rect;
	
	// While models don't necessarily have to 
	// subclass BaseModel, it's a good starting point.
	
	internal class BaseModel extends EventDispatcher implements IModel {
		
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		
		protected static const ORIGIN:Point = new Point();
		
		protected static const BUSY_EVENT:WWEvent = new WWEvent(WWEvent.MODEL_BUSY);
		protected static const IDLE_EVENT:WWEvent = new WWEvent(WWEvent.MODEL_IDLE);
		
		protected static const STEP:int = 6000;
		protected static const CLEAR:uint = 0x00000000, BLACK:uint = 0xFF000000, WHITE:uint = 0xFFFFFFFF;
		protected static const COMPLETE_EVENT:Event = new Event(Event.COMPLETE);
		protected static const INVALID_SIZE_ERROR:String = "Invalid dimensions.";
		protected static const INVALID_SIZE_ERROR_EVENT:ErrorEvent = new ErrorEvent(ErrorEvent.ERROR, false, false, INVALID_SIZE_ERROR);
		
		//---------------------------------------
		// PRIVATE & PROTECTED VARIABLES
		//---------------------------------------
		protected var _initialized:Boolean = false;
		protected var _width:int, _height:int;
		protected var _credit:String;
		protected var totalNodes:int = 0;
		protected var _headData:BitmapData, _tailData:BitmapData, _wireData:BitmapData, _heatData:BitmapData;
		protected var _generation:uint = 1;
		protected var _baseGraphics:Graphics = makeGraphics();
		protected var _wireGraphics:Graphics = makeGraphics();
		protected var _headGraphics:Graphics = makeGraphics();
		protected var _tailGraphics:Graphics = makeGraphics();
		protected var _heatGraphics:Graphics = makeGraphics();
		protected var importer:Importer = new Importer();
		protected var bound:Rectangle = new Rectangle(0, 0, int.MAX_VALUE, int.MAX_VALUE);
		protected var leftBound:int = 0, rightBound:int = int.MAX_VALUE;
		protected var topBound:int = 0, bottomBound:int = int.MAX_VALUE;
		protected var activeRect:Rectangle = new Rectangle(), activeCorner:Point = new Point();
		
		// These are useful for certain kinds of drawing. 
		// They're color gradient lookup tables.
		private var heatSpectrum:HeatSpectrum = new HeatSpectrum;
		private var spectrum:Spectrum = new Spectrum();
		
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function BaseModel():void {
			super();
			importer.addEventListener(WWEvent.DATA_PARSED, finishParse);
			importer.addEventListener(WWEvent.DATA_EXTRACTED, finishExtraction);
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		public function get initialized():Boolean { return _initialized; }
		public function get width():int { return _width; }
		public function get height():int { return _height; }
		public function get base():BitmapData { return new BitmapData(_width, _height, false, BLACK); }
		public function get wireData():BitmapData { return _wireData.clone(); }
		public function get headData():BitmapData { return _headData.clone(); }
		public function get tailData():BitmapData { return _tailData.clone(); }
		public function get credit():String { return _credit; }
		public function set credit(value:String):void { _credit = value; }
		public function get generation():Number { return _generation; }
		public function get baseGraphics():Graphics { return makeGraphics(_baseGraphics); }
		public function get wireGraphics():Graphics { return makeGraphics(_wireGraphics); }
		public function get headGraphics():Graphics { return makeGraphics(_headGraphics); }
		public function get tailGraphics():Graphics { return makeGraphics(_tailGraphics); }
		public function get heatGraphics():Graphics { return makeGraphics(_heatGraphics); }
		
		public function get implementsOverdrive():Boolean { return false; }
		public function get overdriveActive():Boolean { return false; }
		public function set overdriveActive(value:Boolean):void {}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		// Most of the implemented methods of IModel are empty here.
		public function init(txt:String, isMCell:Boolean = false):void { _initialized = true; importer.parse(txt, isMCell); }
		public function update():void {}
		public function refreshHeat(fully:Boolean = false):void {}
		public function refreshImage(fully:Boolean = false):void {}
		public function refreshAll(fully:Boolean = false):void { refreshImage(fully); }
		public function getState(__x:int, __y:int):uint { return 0; }
		public function reset():void {}
		public function eraseRect(rect:Rectangle):void {}
		
		public function setBounds(top:int, left:int, bottom:int, right:int):void {
			topBound = top - activeCorner.x;
			leftBound = left - activeCorner.y;
			bottomBound = bottom - activeCorner.x;
			rightBound = right - activeCorner.y;
			
			bound.x = leftBound;
			bound.y = topBound;
			bound.width = rightBound - leftBound;
			bound.height = bottomBound - topBound;
		}

		//---------------------------------------
		// PRIVATE & PROTECTED METHODS
		//---------------------------------------
		
		// More of an example than an actual implementation.
		// Performs dimension validation.
		protected function finishParse(event:Event):void {
			if (importer.width  > WWFormat.MAX_SIZE || importer.height  > WWFormat.MAX_SIZE || importer.width * importer.height < 1) {
				dispatchEvent(INVALID_SIZE_ERROR_EVENT);
			} else {
				_width = importer.width;
				_height = importer.height;
				_credit = importer.credit;
				
				totalNodes = 0;
				importer.extract(addNode);
			}
		}
		
		protected function finishExtraction(event:Event):void {
			trace(totalNodes, "total nodes");
			dispatchEvent(COMPLETE_EVENT);
		}
		
		// Draws the passed BitmapData into a Graphics object.
		protected function drawData(graphicsObject:Graphics, rect:Rectangle, data:BitmapData):void {
			graphicsObject.clear();
			graphicsObject.beginBitmapFill(data, new Matrix(1, 0, 0, 1, rect.x, rect.y), false);
			graphicsObject.drawRect(rect.x, rect.y, rect.width, rect.height);
			graphicsObject.endFill();
		}
		
		// Draws the passed BitmapData into a Graphics object.
		protected function drawBackground(graphicsObject:Graphics, w:Number, h:Number, color:int):void {
			graphicsObject.clear();
			graphicsObject.beginFill(color);
			graphicsObject.drawRect(0, 0, w, h);
			graphicsObject.endFill();
		}
		
		protected function addNode(__x:int, __y:int, __state:int):void {
			totalNodes++;
		}
		
		protected final function heatColorOf(input:Number):int {
			if (input > 1) return heatSpectrum.getPixel(heatSpectrum.width, 0);
			return heatSpectrum.getPixel(input * heatSpectrum.width, 0);
		}
		
		protected final function colorOf(input:Number):int {
			if (input > 1) return spectrum.getPixel(spectrum.width, 0);
			return spectrum.getPixel(input * spectrum.width, 0);
		}
	}
}
