﻿/*** Wireworld Player by Jeremy Sachs. June 8, 2010** Feel free to distribute the source, just try not to hand it off to some douchebag.* Keep this header here.** Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.*/package net.rezmason.wireworld {	//---------------------------------------	// IMPORT STATEMENTS	//---------------------------------------	import flash.display.Sprite;	/**	*	Application entry point for Wireworld Player.	*	*	@langversion ActionScript 3.0	*	@playerversion Flash 10.0.0	*	*	@author Jeremy Sachs	*	@since 01.23.2010	*/	[SWF(width='800', height='648', backgroundColor='#000000', frameRate='30')]	public final class Main extends Sprite {		//---------------------------------------		// CONSTRUCTOR		//---------------------------------------		public function Main():void {			// Grab the Model determined by the proper compiler directive			BRAIN::STANDARD var model:IModel = 				new TDSIModel;						BRAIN::CONVOLUTION_FILTER var model:IModel = 	new FilterModel; 		// POOR			BRAIN::PIXEL_BENDER var model:IModel = 			new PixelBenderModel; 	// NOT WORTH FIXING			BRAIN::LINKED_LIST var model:IModel = 			new LinkedListModel; 	// GOOD			BRAIN::TDSI var model:IModel = 					new TDSIModel; 			// GREAT			BRAIN::VECTOR var model:IModel = 				new VectorModel; 		// GOOD						BRAIN::TREE var model:IModel = 					new TreeModel; 			// PENDING			//BRAIN::TREE_TDSI var model:IModel = 			new TDSITreeModel;		// TODO						//BRAIN::HAXE var model:IModel = 					new HaXeModel;			// PENDING									// The BRAIN::ALL directive tells the compiler to include all these classes			// in the SWF, allowing them all to be checked by the Flex compiler for errors. 			BRAIN::ALL {				var model:IModel = new TDSIModel;				var models:Array = [				TDSIModel, 				FilterModel, 				PixelBenderModel, 				LinkedListModel, 				TDSIModel, 				VectorModel, 				TreeModel,				//TDSITreeModel, 				//HaXeModel,				];			} 						trace("Model type:", model);						// Not a flawless MVC implementation, but it's good enough.			addChild(new View(new Controller(model)));		}	}}