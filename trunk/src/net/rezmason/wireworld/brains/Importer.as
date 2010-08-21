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
	import apparat.math.IntMath;
	
	import flash.events.EventDispatcher;
	
	import net.rezmason.utils.GreenThread;
	import net.rezmason.wireworld.WWEvent;
	
	// Helps to convert TXT and MCL files.
	// All the models used to do this, so the job
	// was broken off into a separate class.
	
	public final class Importer extends EventDispatcher {
		
		// This class used to be called ParserExtractor. What a terrible name!

		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		private static const STEP:int = 6000;
		private static const PARSED_EVENT:WWEvent = new WWEvent(WWEvent.DATA_PARSED);
		private static const EXTRACTED_EVENT:WWEvent = new WWEvent(WWEvent.DATA_EXTRACTED);

		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private var _width:int, _height:int, _totalNodes:int;
		private var _credit:String;
		private var offset:int;
		private var multiplier:int = 0;
		private var column:int, row:int;
		private var mclWidth:int, mclHeight:int;
		private var txtFile:String, mclFile:String;
		private var isNumeric:RegExp = /[0-9]/;
		private var isMCL:RegExp = /[A-C]|.|$/;
		private var thread:GreenThread = new GreenThread;
		private var char:String;
		private var digitString:String;
		private var tempStringVector:Vector.<String> = new <String>[];
		private var ike:int, jen:int;
		private var _extractFunc:Function;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		public function Importer():void {}

		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		public function get width():int { return _width; }
		public function get height():int { return _height; }
		public function get totalNodes():int { return _totalNodes; }
		public function get credit():String { return _credit; }
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		public function parse(txt:String, isMCell:Boolean = false):void {
			
			txtFile = txt;
			tempStringVector = Vector.<String>(txtFile.substr(0, 10).split(" "));
			
			if (isMCell) {

				mclWidth = 0;
				mclHeight = 0;
				char = "";
				
				// grabs the credit from the MCL file
				var neck:int = txtFile.indexOf("#L");
				_credit = "\n" + txtFile.substring(txtFile.indexOf("#D"), neck);
				_credit = _credit.replace(/[\n\r]#D [\n\r]#D /g,"!!").replace(/[\n\r]#D /g, "•");
				_credit = _credit.replace(/!!/g, "\n\n").replace(/•/g, "").replace(/#D/g, "");
				
				mclFile = txtFile.substr(neck + 3).replace(/\n#L /g, "");
				txtFile = "";
				
				// convert the MCL data to text
				
				// sets up and starts the thread on converting the MCL to TXT.
				thread.taskFragment = partialMCLConversion;
				thread.condition = checkMCLConversion;
				thread.prologue = beginMCLConversion;
				thread.epilogue = finishMCLConversion;
				thread.start();
				
			} else {
				
				// TXT files can't specify a credit string.
				_credit = null;
				
				// grab the width and height
				if (tempStringVector.length > 1) {
					_width = int(tempStringVector[0]);
					_height = int(tempStringVector[1]);
				} else {
					_width = _height = 0;
				}       
				
				_totalNodes = txtFile.split(WWFormat.ALIVE_REG_EXP).length;
				
				dispatchEvent(PARSED_EVENT);
			}
		}
		
		public function extract(extractFunc:Function = null):void {
			_extractFunc = extractFunc;
			
			// starts the thread on extracting nodes from the TXT
			thread.taskFragment = partialExtraction;
			thread.condition = checkExtraction;
			thread.prologue = beginExtraction;
			thread.epilogue = finishExtraction;
			thread.start();
		}
		
		public function dump():void {
			_width, _height, _totalNodes;
			_credit;
			txtFile, mclFile;
			digitString;
			tempStringVector;
		}

		//---------------------------------------
		// PRIVATE METHODS
		//---------------------------------------
		
		private function beginMCLConversion():void {
			ike = 0;
			row = 0, column = 0;
			digitString = "";
			offset = 0;
		}
		
		private function checkMCLConversion():Boolean {
			return (ike < mclFile.length);
		}
		
		private function partialMCLConversion():void {
			
			// MCL has a weird way of folding data together. Look it up.
			
			for (ike = offset; ike < mclFile.length && ike - offset < STEP; ike += 1) {
				char = mclFile.charAt(ike);
				if (isNumeric.test(char)) {
					digitString += char;
				} else if (isMCL.test(char)) {
					
					multiplier = parseInt(digitString, 10) || 1;
					
					char = WWFormat.MCL_CONVERSION_TABLE[char];
					if (char) {

						for (jen = 0; jen < multiplier; jen += 1) {
							txtFile += char;
						}

						if (char == "*") {
							row += multiplier;
							column = 0;
							mclHeight = IntMath.max(row, mclHeight);
						} else {
							column += multiplier;
							mclWidth = IntMath.max(mclWidth, column);
						}
					}
					
					digitString = "";
				}
			}

			offset += STEP;
		}
		
		private function finishMCLConversion():void {
			// get the dimensions
			_width = mclWidth, _height = mclHeight;
			
			// Some final tweaks, and the MCL file has become a TXT string
			tempStringVector = Vector.<String>(txtFile.split("*"));
			txtFile = "";

			for (ike = 0; ike < tempStringVector.length; ike += 1) {
				// padding
				var str:String = tempStringVector[ike];
				while (str.length < _width) str += "          ";
				txtFile += str.substr(0, _width);
			}
			
			_totalNodes = txtFile.split(WWFormat.ALIVE_REG_EXP).length;
			
			dispatchEvent(PARSED_EVENT);
		}
		
		private function beginExtraction():void {
			tempStringVector.splice(0, tempStringVector.length);
			offset = 0;
			ike = 0;
			jen = 0;
		}
		
		private function checkExtraction():Boolean {
			return (ike < txtFile.length);
		}
		
		private function partialExtraction():void {
			// Get the x and y of every character, translate it 
			// into a state and pass it to the extract function.
			
			for (ike = offset; ike < txtFile.length && ike - offset < STEP; ike += 1) {
				column = ike % _width;
				row = (ike - column) / _width;
				char = txtFile.charAt(ike);
				if (WWFormat.CHAR_MAP[char] != undefined) {
					_extractFunc(column, row, WWFormat.CHAR_MAP[char]);
				}
			}
			offset += STEP;
		}
		
		private function finishExtraction():void {
			tempStringVector.splice(0, tempStringVector.length);
			dispatchEvent(EXTRACTED_EVENT);
		}
	}
}
