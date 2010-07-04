﻿/*** Wireworld Player by Jeremy Sachs. June 22, 2010** Feel free to distribute the source, just try not to hand it off to some douchebag.* Keep this header here.** Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.*/package net.rezmason.wireworld.views {	//---------------------------------------	// IMPORT STATEMENTS	//---------------------------------------	//import __AS3__.vec.Vector;		import apparat.math.FastMath;		import com.pixelbreaker.ui.osx.MacMouseWheel;		import flash.display.BitmapData;	import flash.display.DisplayObjectContainer;	import flash.display.Loader;	import flash.display.Sprite;	import flash.display.Stage;	import flash.display.StageAlign;	import flash.display.StageScaleMode;	import flash.events.Event;	import flash.events.EventDispatcher;	import flash.events.MouseEvent;	import flash.geom.Point;	import flash.net.URLRequest;	import flash.system.Capabilities;	import flash.system.Security;		import net.rezmason.display.Grid;	import net.rezmason.gui.SimpleBridge;	import net.rezmason.gui.Toolbar;	import net.rezmason.gui.ToolbarAlign;	import net.rezmason.wireworld.ColorPalette;	import net.rezmason.wireworld.IModel;	import net.rezmason.wireworld.IView;	import net.rezmason.wireworld.WWCommand;	import net.rezmason.wireworld.WWEvent;		// This class is responsible for managing all visual assets and the display of all information.		public final class View extends EventDispatcher implements IView {				//---------------------------------------		// CLASS CONSTANTS		//---------------------------------------				private static const CHANGE_STATE_EVENT:Event = new Event(WWCommand.CHANGE_STATE);		private static const OPAQUE_BACKGROUND_COLOR:int = 0x222222;		private static const READY_EVENT:WWEvent = new WWEvent(WWEvent.READY);		private static const ASSET_URL:String = "../lib/assets.swf";				//---------------------------------------		// PRIVATE VARIABLES		//---------------------------------------		private var _model:IModel;		private var _scene:Sprite;		private var _assets:Object;				private var _callback:Function;				private var stage:Stage;		private var window:EventDispatcher;		private var _bridge:SimpleBridge;		private var _flag:int;				private var board:Sprite;		private var grid:Grid;		private var paper:Paper;		private var topToolbar:Toolbar, bottomToolbar:Toolbar;		private var resizeX:int, resizeY:int, uiScale:Number;				private var assetLoader:Loader;				//---------------------------------------		// CONSTRUCTOR		//---------------------------------------		public function View(__model:IModel, __scene:Sprite, __bridge:SimpleBridge):void {					_scene = __scene;			_model = __model;			_bridge = __bridge;			_bridge.eventTypes.CHANGE_STATE ||= WWCommand.CHANGE_STATE;			buildAPI();						_scene.opaqueBackground = OPAQUE_BACKGROUND_COLOR;						// If the assets aren't already available, they get loaded in 			if (_bridge.assets) {				_assets = _bridge.assets;				proceed();			} else {				assetLoader = new Loader();				assetLoader.contentLoaderInfo.addEventListener(Event.INIT, proceed);				assetLoader.load(new URLRequest(ASSET_URL));			}		}				//---------------------------------------		// GETTER / SETTERS		//---------------------------------------				// this callback is how the View propagates events to the Controller.		public function set callback(func:Function):void {			_callback = func;		}				public function get initialized():Boolean {			return stage != null;		}				//---------------------------------------		// PUBLIC METHODS		//---------------------------------------				public function addGUIEventListeners():void {					}				public function setFileName(__fileName:String):void {					}				public function showLoading():void {					}				// initializes the View		public function prime():void {			paper.init(				_model.baseGraphics, 				_model.wireGraphics, 				_model.headGraphics, 				_model.tailGraphics, 				_model.heatGraphics,				ColorPalette.appropriatePalette			);		}				// wipes clean the elements of the View that are particular to the open document		public function resetView(event:Event = null):void {					}				// turns all toggles back to their default states		public function resetState(event:Event = null):void {					}				public function placeAnnouncer(event:Event = null):void {					}				public function updateAnnouncers():void {					}				public function showAbout(event:Event = null):void {					}				public function hideAbout(event:Event = null):void {					}				// Populates the alert box with a title, message, and maybe a close button		public function giveAlert(titleText:String, messageText:String, allowClose:Boolean = true):void {					}				public function hideAlert(event:Event = null):void {					}				// resizes the View when the stage has changed dimensions		public function resize(event:Event = null):void {			resizeX = FastMath.max(FastMath.max(topToolbar.minWidth, bottomToolbar.minWidth), stage.stageWidth);			resizeY = FastMath.max(160, stage.stageHeight);						// resize toolbars			uiScale = FastMath.max(1, resizeY / 600);			topToolbar.scale = bottomToolbar.scale = uiScale;			topToolbar.width = resizeX / uiScale;			bottomToolbar.width = resizeX / uiScale;			if (window) {				var minSize:Point = window["minSize"] as Point;				minSize.x = FastMath.max(topToolbar.minWidth, bottomToolbar.minWidth);				window["minSize"] = minSize;			}			bottomToolbar.y = resizeY - bottomToolbar.realHeight;						// refresh board			board.y = topToolbar.realHeight;			grid.width = resizeX;			grid.height = resizeY - topToolbar.realHeight - bottomToolbar.realHeight;			paper.reposition(grid.width, grid.height);		}				public function updatePaper(flags:int = 0):void {			_model.refresh(flags | _flag);		}				public function updateGeneration(gen:uint):void {					}				public function updateFPS(__fps:int):void {					}				// Staples together a snapshot of the current Wireworld instance		// to a text field containing its description, stamped on a bitmap		public function snapshot():BitmapData {			return null;		}				// Disabler methods. This shows and hides a big dark transparent shape		// that goes behind modal dialogs to disable the rest of the GUI.				public function showDisabler(event:Event = null):void {					}				public function hideDisabler(event:Event = null):void {					}				//---------------------------------------		// PRIVATE METHODS		//---------------------------------------				// Instantiates GUI elements once the assets are available		private function proceed(event:Event = null):void {						assetLoader.removeEventListener(Event.COMPLETE, proceed);			_assets ||= assetLoader.content["library"];						board = new Sprite();			grid = new Grid(12, 0, 0);			paper = new Paper(0, 0, _model.setBounds);						topToolbar = new Toolbar(0, 24, OPAQUE_BACKGROUND_COLOR);			bottomToolbar = new Toolbar(0, 24, OPAQUE_BACKGROUND_COLOR);						_scene.addChild(board);			board.addChild(grid);			board.addChild(paper);			_scene.addChild(topToolbar);			_scene.addChild(bottomToolbar);						if (_scene.stage) {				connectToStage();			} else {				_scene.addEventListener(Event.ADDED_TO_STAGE, connectToStage);			}		}				// sets up the stage once it's available		private function connectToStage(event:Event = null):void {			_scene.removeEventListener(Event.ADDED_TO_STAGE, connectToStage);						stage = _scene.stage;						stage.align = StageAlign.TOP_LEFT;			stage.scaleMode = StageScaleMode.NO_SCALE;						if (Security.sandboxType != "application") {				if (Capabilities.os.toLowerCase().indexOf("mac") != -1) {					// This util is actually kind of expensive, isn't it.					MacMouseWheel.setup(stage);				}			}						stage.addEventListener(Event.RESIZE, resize, false, 0, true);						if (stage.hasOwnProperty("nativeWindow")) {				window = stage["nativeWindow"] as EventDispatcher;			}						resize();			dispatchEvent(READY_EVENT);		}				// passing mouse wheel events to the Paper.		private function zoomScroll(event:MouseEvent):void {			paper.zoom(NaN, true, stage.mouseX, stage.mouseY);			_bridge.state.atMinZoom = paper.atMinZoom;			_bridge.state.atMaxZoom = paper.atMaxZoom;			yell(WWCommand.PAUSE_MOTION);			_bridge.dispatchEvent(CHANGE_STATE_EVENT);		}				private function zoomIn(event:MouseEvent = null):void {			paper.zoom(0.2);			_bridge.state.atMinZoom = paper.atMinZoom;			_bridge.state.atMaxZoom = paper.atMaxZoom;			_bridge.dispatchEvent(CHANGE_STATE_EVENT);		}				private function zoomOut(event:MouseEvent = null):void {			paper.zoom(-0.2);			_bridge.state.atMinZoom = paper.atMinZoom;			_bridge.state.atMaxZoom = paper.atMaxZoom;			_bridge.dispatchEvent(CHANGE_STATE_EVENT);		}				private function updateFlag():void {			_flag = 0;		}				private function yell(type:String, value:* = null):void {			if (_callback != null) _callback(type, value);			//dispatchEvent(new WWEvent(type, value));		}				private function buildAPI():void {					}				private function dissolve(container:DisplayObjectContainer):int {			var total:int = 0;			if (!container) return 0;			while (container.numChildren) {				total += 1 + dissolve(container.removeChildAt(0) as DisplayObjectContainer);			}			return total;		}	}}