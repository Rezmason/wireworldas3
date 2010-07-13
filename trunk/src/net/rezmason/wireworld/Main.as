﻿/*** Wireworld Player by Jeremy Sachs. June 22, 2010** Feel free to distribute the source, just try not to hand it off to some douchebag.* Keep this header here.** Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.*/package net.rezmason.wireworld {	//---------------------------------------	// IMPORT STATEMENTS	//---------------------------------------	import flash.display.Sprite;
	import flash.display.Stage;
	
	import net.rezmason.gui.SimpleBridge;
	import net.rezmason.wireworld.brains.*;
	import net.rezmason.wireworld.views.*;		// This class's job is to decide on what Model to compile and to instantiate the MVC.		public final class Main {				private var model:IModel;		private var view:IView;		private var controller:Controller;				//---------------------------------------		// CONSTRUCTOR		//---------------------------------------		public function Main(scene:Sprite, bridge:SimpleBridge = null):void {						// Grab the Model determined by the compiler directive			BRAIN::STANDARD 			{ model = new TDSIModel; }						BRAIN::STUPID 				{ model = new FirstModel; } 		// STUPID			BRAIN::CONVOLUTION_FILTER 	{ model = new FilterModel; } 		// POOR			BRAIN::PIXEL_BENDER 		{ model = new PixelBenderModel; } 	// POOR			BRAIN::LINKED_LIST 			{ model = new LinkedListModel; } 	// GOOD			BRAIN::TDSI 				{ model = new TDSIModel; } 			// GREAT			BRAIN::BYTES 				{ model = new ByteModel; }			// OKAY			BRAIN::VECTOR 				{ model = new VectorModel; } 		// GOOD						BRAIN::TREE 				{ model = new TreeModel; } 			// PENDING			//BRAIN::TREE_TDSI 			{ model = new TDSITreeModel; }		// TODO			//BRAIN::HAXE 				{ model = new HaXeModel; }			// PENDING						VIEW::DESKTOP				{ view = new View(model, scene, bridge); } // WORKS			VIEW::MOBILE				{ view = new MobileView(model, scene, bridge); } // PENDING						// The BRAIN::ALL directive compiles everything related to the project,			// so that we can still see compile errors in classes we aren't using. 			BRAIN::ALL {				model = new TDSIModel;				view = new View(model, scene, bridge);				var spit:Array = [				TDSIModel, 				FilterModel, 				PixelBenderModel, 				LinkedListModel, 				TDSIModel, 				VectorModel, 				TreeModel,				//TDSITreeModel,				//HaXeModel,				FirstModel,				ByteModel,				Assets,				View,				//MobileView				];			} 						trace("Model type:", model);			trace("View type:", view);						controller = new Controller(model, view, bridge);		}	}}