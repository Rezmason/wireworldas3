﻿/*** Wireworld Player by Jeremy Sachs. June 22, 2010** Feel free to distribute the source, just try not to hand it off to some douchebag.* Keep this header here.** Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.*/package net.rezmason.wireworld.views {	//---------------------------------------	// IMPORT STATEMENTS	//---------------------------------------	//import __AS3__.vec.Vector;		import __AS3__.vec.Vector;		import apparat.math.FastMath;		import com.pixelbreaker.ui.osx.MacMouseWheel;		import flash.display.BitmapData;	import flash.display.DisplayObjectContainer;	import flash.display.Loader;	import flash.display.Shape;	import flash.display.Sprite;	import flash.display.Stage;	import flash.display.StageAlign;	import flash.display.StageScaleMode;	import flash.events.Event;	import flash.events.EventDispatcher;	import flash.events.MouseEvent;	import flash.geom.Point;	import flash.net.URLRequest;	import flash.system.Capabilities;	import flash.system.Security;	import flash.ui.Mouse;		import net.rezmason.display.Grid;	import net.rezmason.gui.SimpleBridge;	import net.rezmason.gui.Toolbar;	import net.rezmason.gui.ToolbarAlign;	import net.rezmason.wireworld.IModel;	import net.rezmason.wireworld.IView;	import net.rezmason.wireworld.WWCommand;	import net.rezmason.wireworld.WWEvent;		// This class is responsible for managing all visual assets and the display of all information.		public final class View extends EventDispatcher implements IView {				//---------------------------------------		// CLASS CONSTANTS		//---------------------------------------				private static const CHANGE_STATE_EVENT:Event = new Event(WWCommand.CHANGE_STATE);		private static const OPAQUE_BACKGROUND_COLOR:int = 0x222222;		private static const READY_EVENT:WWEvent = new WWEvent(WWEvent.READY);		private static const ASSET_URL:String = "../lib/assets.swf";				//---------------------------------------		// PRIVATE VARIABLES		//---------------------------------------		private var _model:IModel;		private var _scene:Sprite;		private var _assets:Object;				private var _callback:Function;				private var state:Object;		private var stage:Stage, stageListeners:Object = {};		private var window:EventDispatcher, windowListeners:Object = {};		private var _bridge:SimpleBridge;		private var _flag:int;				private var board:Sprite;		private var grid:Grid;		private var paper:Paper;		private var disabler:Shape;		private var dialogContainer:Sprite;		private var topBar:Toolbar, bottomBar:Toolbar;		private var resizeX:int, resizeY:int, uiScale:Number;		private var gui:Object;				private var cursors:Object, cursor:Cursor, tool:String;				private var assetLoader:Loader;				//---------------------------------------		// CONSTRUCTOR		//---------------------------------------		public function View(__model:IModel, __scene:Sprite, __bridge:SimpleBridge):void {					_scene = __scene;			_model = __model;			_bridge = __bridge;			state = _bridge.state;			_bridge.eventTypes.CHANGE_STATE ||= WWCommand.CHANGE_STATE;			buildAPI();						_scene.opaqueBackground = OPAQUE_BACKGROUND_COLOR;						// If the assets aren't already available, they get loaded in 			if (_bridge.assets) {				_assets = _bridge.assets;				proceed();			} else {				assetLoader = new Loader();				assetLoader.contentLoaderInfo.addEventListener(Event.INIT, proceed);				assetLoader.load(new URLRequest(ASSET_URL));			}		}				//---------------------------------------		// GETTER / SETTERS		//---------------------------------------				// this callback is how the View propagates events to the Controller.		public function set callback(func:Function):void {			_callback = func;		}				public function get initialized():Boolean {			return stage != null;		}				//---------------------------------------		// PUBLIC METHODS		//---------------------------------------				public function addGUIEventListeners():void {					}				public function setFileName(__fileName:String):void {					}				public function showLoading():void {					}				// initializes the View		public function prime():void {			paper.init(				_model.baseGraphics, 				_model.wireGraphics, 				_model.headGraphics, 				_model.tailGraphics, 				_model.heatGraphics,				ColorPalette.appropriatePalette			);		}				// wipes clean the gui of the View that are particular to the open document		public function resetView(event:Event = null):void {					}				// turns all toggles back to their default states		public function resetState(event:Event = null):void {					}				public function placeAnnouncer(event:Event = null):void {					}				public function updateAnnouncers():void {					}				public function showAbout(event:Event = null):void {					}				public function hideAbout(event:Event = null):void {					}				// Populates the alert box with a title, message, and maybe a close button		public function giveAlert(titleText:String, messageText:String, allowClose:Boolean = true):void {					}				public function hideAlert(event:Event = null):void {					}				// resizes the View when the stage has changed dimensions		public function resize(event:Event = null):void {			resizeX = FastMath.max(FastMath.max(topBar.minWidth, bottomBar.minWidth), stage.stageWidth);			resizeY = FastMath.max(160, stage.stageHeight);						// resize toolbars			uiScale = FastMath.max(1, resizeY / 600);			topBar.scale = bottomBar.scale = uiScale;			topBar.width = resizeX / uiScale;			bottomBar.width = resizeX / uiScale;			if (window) {				var minSize:Point = window["minSize"] as Point;				minSize.x = FastMath.max(topBar.minWidth, bottomBar.minWidth);				window["minSize"] = minSize;			}			bottomBar.y = resizeY - bottomBar.realHeight;						// refresh board			board.y = topBar.realHeight;			grid.width = resizeX;			grid.height = resizeY - topBar.realHeight - bottomBar.realHeight;			paper.reposition(grid.width, grid.height);			disabler.width = resizeX;			disabler.height = resizeY;			disabler.visible = false;						dialogContainer.x = int(resizeX * 0.5);			dialogContainer.y = int(resizeY * 0.5);			dialogContainer.visible = false;		}				public function updatePaper(flags:int = 0):void {			_model.refresh(flags | _flag);		}				public function updateGeneration(gen:uint):void {					}				public function updateFPS(__fps:int):void {					}				// Staples together a snapshot of the current Wireworld instance		// to a text field containing its description, stamped on a bitmap		public function snapshot():BitmapData {			return null;		}				// Disabler methods. This shows and hides a big dark transparent shape		// that goes behind modal dialogs to disable the rest of the GUI.				public function showDisabler(event:Event = null):void {			disabler.visible = true;		}				public function hideDisabler(event:Event = null):void {			disabler.visible = false;		}				//---------------------------------------		// PRIVATE METHODS		//---------------------------------------				// Instantiates GUI gui once the assets are available		private function proceed(event:Event = null):void {						assetLoader.removeEventListener(Event.COMPLETE, proceed);			_assets ||= assetLoader.content["library"];						board = new Sprite();			grid = new Grid(12, 0, 0);			paper = new Paper(0, 0, _model.setBounds);			disabler = new Shape();						disabler.graphics.beginFill(0x0, 0.5);			disabler.graphics.drawRect(0, 0, 10, 10);			disabler.graphics.endFill();						dialogContainer = new Sprite();						cursors = {};			cursors.hand = new Cursor(_assets.HandCursorUp, _assets.HandCursorDown);			cursors.eraser = new Cursor(_assets.EraserCursorUp, _assets.EraserCursorDown);			changeTool("hand");						topBar = new Toolbar(0, 24, OPAQUE_BACKGROUND_COLOR);			topBar.rightMargin = 0;			bottomBar = new Toolbar(0, 24, OPAQUE_BACKGROUND_COLOR);						// Populate the GUI with elements.						gui = {};			gui.reset = 		new WWButton("@@@Reset", new _assets.Stop, 18, "(]");			gui.playPause = 	new WWButton("@@@Play / Pause", new _assets.PlayPause, 18, "[]");			gui.step = 			new WWButton("@@@Step", new _assets.Step, 18, "[)");			gui.heatmap = 		new WWButton("@@@Toggle heat vision", new _assets.Heatmap, 18, "()", ButtonType.TOGGLABLE);			gui.handTool = 		new WWButton("@@@Hand tool", new _assets.HandTool, 18, "(]", ButtonType.IN_A_SET, "tool", "hand");			gui.eraserTool = 	new WWButton("@@@Eraser tool", new _assets.EraserTool, 18, "[)", ButtonType.IN_A_SET, "tool", "eraser");			gui.slow = 			new WWButton("@@@Slow down", new _assets.Slower, 18, "(]", ButtonType.CONTINUOUS);			gui.speedSlider = 	new WWSlider("@@@Adjust speed", 100, 18);			gui.fast = 			new WWButton("@@@Speed up", new _assets.Faster, 18, "[)", ButtonType.CONTINUOUS);			gui.overdrive = 	new WWButton("@@@Overdrive", new _assets.Overdrive, 18, "()", ButtonType.TOGGLABLE);			gui.snapshot = 		new WWButton("@@@Save picture", new _assets.Snapshot, 18);			gui.help = 			new WWButton("@@@Help!", new _assets.Help, 18);			gui.about = 		new WWButton("@@@About Wireworld player", new _assets.WWAbout, 24, "(]");			gui.zoomOut = 		new WWButton("@@@Zoom out", new _assets.ZoomOut, 18, "(]", ButtonType.CONTINUOUS);			gui.zoomSlider = 	new WWSlider("@@@Adjust zoom", 100, 18);			gui.resetView = 	new WWButton("@@@Reset view", new _assets.ResetView, 18, "[]");			gui.zoomIn = 		new WWButton("@@@Zoom in", new _assets.ZoomIn, 18, "[)", ButtonType.CONTINUOUS);			gui.txtGeneration = new WWTextField("@@@Current generation", 80, 18, "-)");			gui.load = 			new WWButton("@@@Load file", new _assets.File, 18, "(]");			gui.txtFilename = 	new WWTextField("@@@Current file", 200, 18, "[)");			gui.txtAnnouncer = 	new WWTextField("@@@Announcer label", 100, 18, "(]", true, "<label>");			gui.announcer = 	new WWButton("@@@Add announcer", new _assets.Announcer, 18, "[)");			gui.txtFramerate = 	new WWTextField("@@@Framerate", 40, 18, "(-");						// Set up the GUI triggers.						gui.reset.bind(showResetPrompt);			gui.playPause.bind(togglePlayPause);			gui.step.bind(yell, false, WWCommand.STEP);			gui.heatmap.bind(changeState, true, "heatmap");			gui.handTool.bind(changeState, true);			gui.eraserTool.bind(changeState, true);			gui.slow.bind(zipSpeed, true, -2);			gui.speedSlider.bind(changeState, true, "speed");			gui.fast.bind(zipSpeed, true, 2);			gui.overdrive.bind(changeState, true, "overdrive");			gui.snapshot.bind(yell, false, WWCommand.SAVE);			gui.help.bind(showHelp);			gui.about.bind(showAbout);			gui.zoomOut.bind(zipZoom, true, -2);			gui.zoomSlider.bind(changeState, true, "zoom");			gui.zoomIn.bind(zipZoom, true, 2);			gui.load.bind(showLoadPrompt);			gui.txtAnnouncer.bind(nameAnnouncer, true);			gui.announcer.bind(addAnnouncer);						// Set up the default GUI values						gui.txtFramerate.text = "100";			gui.txtGeneration.text = "575600";			gui.txtFilename.text = "we_like_to_party.mcl";						// Insert the GUI elements into the toolbars.						topBar.addGUIElements(ToolbarAlign.LEFT, true, gui.reset, gui.playPause, gui.step);			topBar.addGUIElements(ToolbarAlign.LEFT, false, gui.heatmap);			topBar.addGUIElements(ToolbarAlign.LEFT, true, gui.handTool, gui.eraserTool);			topBar.addGUIElements(ToolbarAlign.CENTER, true, gui.slow, gui.speedSlider, gui.fast);			topBar.addGUIElements(ToolbarAlign.CENTER, false, gui.overdrive);			topBar.addGUIElements(ToolbarAlign.RIGHT, false, gui.snapshot, gui.help, gui.about);						bottomBar.addGUIElements(ToolbarAlign.LEFT, true, gui.zoomOut, gui.zoomSlider, gui.resetView, gui.zoomIn);			bottomBar.addGUIElements(ToolbarAlign.LEFT, false, gui.txtGeneration);			bottomBar.addGUIElements(ToolbarAlign.CENTER, true, gui.load, gui.txtFilename);			bottomBar.addGUIElements(ToolbarAlign.RIGHT, true, gui.txtAnnouncer, gui.announcer);			bottomBar.addGUIElements(ToolbarAlign.RIGHT, false, gui.txtFramerate);						// URL box: 320, 240			// Load from the Web			// Enter the URL of the file you want to load.			// Cancel			// Load						// Help box: 480, 480			// What is all this?			// hovertext: README			// 			// Great						// About box: 320, 240			// Wireworld player			// written by <a>Jeremy Sachs</a>			// original concept by <a>Brian Silverman</a>			// ...			// CC_BY_NC, Google_Project			// Close			// top right corner: TDSI						board.addEventListener(MouseEvent.ROLL_OVER, showCursor);			board.addEventListener(MouseEvent.ROLL_OUT, hideCursor);			board.addEventListener(MouseEvent.MOUSE_MOVE, moveCursor);			board.addEventListener(MouseEvent.MOUSE_DOWN, closeCursor);			board.addEventListener(MouseEvent.MOUSE_UP, openCursor);						_scene.addChild(board);			board.addChild(grid);			board.addChild(paper);			_scene.addChild(topBar);			_scene.addChild(bottomBar);			_scene.addChild(disabler);			_scene.addChild(dialogContainer);			for (var prop:String in cursors) {				_scene.addChild(cursors[prop]);			}						if (_scene.stage) {				connectToStage();			} else {				_scene.addEventListener(Event.ADDED_TO_STAGE, connectToStage);			}		}				// sets up the stage once it's available		private function connectToStage(event:Event = null):void {			_scene.removeEventListener(Event.ADDED_TO_STAGE, connectToStage);						stage = _scene.stage;						stage.align = StageAlign.TOP_LEFT;			stage.scaleMode = StageScaleMode.NO_SCALE;						if (Security.sandboxType != "application") {				if (Capabilities.os.toLowerCase().indexOf("mac") != -1) {					// This util is actually kind of expensive, isn't it.					MacMouseWheel.setup(stage);				}			}						listenToStage(Event.RESIZE, resize);			listenToStage(MouseEvent.MOUSE_UP, WWElement.releaseInstances);						if (stage.hasOwnProperty("nativeWindow")) {				window = stage["nativeWindow"] as EventDispatcher;				//listenToWindow("resizing", disableCursorsDuringResize);			}						resize();			dispatchEvent(READY_EVENT);		}				// passing mouse wheel events to the Paper.		private function zoomScroll(event:MouseEvent):void {			paper.zoom(NaN, true, stage.mouseX, stage.mouseY);			_bridge.state.atMinZoom = paper.atMinZoom;			_bridge.state.atMaxZoom = paper.atMaxZoom;			yell(WWCommand.PAUSE_MOTION);			_bridge.dispatchEvent(CHANGE_STATE_EVENT);		}				private function zoomIn(event:MouseEvent = null):void {			paper.zoom(0.2);			_bridge.state.atMinZoom = paper.atMinZoom;			_bridge.state.atMaxZoom = paper.atMaxZoom;			_bridge.dispatchEvent(CHANGE_STATE_EVENT);		}				private function zoomOut(event:MouseEvent = null):void {			paper.zoom(-0.2);			_bridge.state.atMinZoom = paper.atMinZoom;			_bridge.state.atMaxZoom = paper.atMaxZoom;			_bridge.dispatchEvent(CHANGE_STATE_EVENT);		}				private function updateFlag():void {			_flag = 0;		}				private function yell(type:String, value:* = null):void {			if (_callback != null) _callback(type, value);			//dispatchEvent(new WWEvent(type, value));		}				private function buildAPI():void {					}				private function dissolve(container:DisplayObjectContainer):int {			var total:int = 0;			if (!container) return 0;			while (container.numChildren) {				total += 1 + dissolve(container.removeChildAt(0) as DisplayObjectContainer);			}			clearListeners();			return total;		}				private function listenToStage(type:String, listener:Function):void {			if (!stage) return;						stageListeners[type] ||= [];			if (stageListeners[type].indexOf(listener) == -1) {				stageListeners[type].push(listener);				stage.addEventListener(type, listener, false, 0, true);			}		}				private function listenToWindow(type:String, listener:Function):void {			if (!window) return;						windowListeners[type] ||= [];			if (windowListeners[type].indexOf(listener) == -1) {				windowListeners[type].push(listener);				window.addEventListener(type, listener, false, 0, true);			}		}				private function clearListeners(event:Event = null):void {			var prop:String;			for (prop in stageListeners) {				while (stageListeners[prop].length) {					stage.removeEventListener(prop, stageListeners[prop].pop());				}				delete stageListeners[prop];			}						for (prop in windowListeners) {				while (windowListeners[prop].length) {					window.removeEventListener(prop, windowListeners[prop].pop());				}				delete windowListeners[prop];			}		}				private function addAnnouncer():void {					}				private function nameAnnouncer(name:String):void {			trace("nameAnnouncer: \"" + name + "\"");		}				private function showHelp():void {					}				private function showLoadPrompt():void {					}				private function showResetPrompt():void {					}				private function togglePlayPause():void {					}				private function zipSpeed(amount:Number, down:Boolean = false):void {			if (down) {				gui.speedSlider.startZip(amount);			} else {				gui.speedSlider.stopZip();			}		}				private function zipZoom(amount:Number, down:Boolean = false):void {			if (down) {				gui.zoomSlider.startZip(amount);			} else {				gui.zoomSlider.stopZip();			}		}				private function changeState(key:String, newValue:*):void {			trace("CHANGE", key, newValue);						switch (key) {				case "tool": changeTool(newValue); break;			}		}				private function changeTool(newTool:String):void {			var newCursor:Cursor = cursors[newTool];			if (cursor && cursor != newCursor) {				newCursor.mouseDown = cursor.mouseDown;				newCursor.x = cursor.x;				newCursor.x = cursor.x;				newCursor.visible = cursor.visible = false;			}							cursor = newCursor;			tool = newTool;		}				private function showCursor(event:Event = null):void { cursor.visible = true; Mouse.hide(); moveCursor(); }		private function moveCursor(event:Event = null):void { cursor.x = _scene.mouseX; cursor.y = _scene.mouseY; }		private function hideCursor(event:Event = null):void { cursor.visible = false; Mouse.show(); }		private function closeCursor(event:Event = null):void { cursor.mouseDown = true; }		private function openCursor(event:Event = null):void { cursor.mouseDown = false; }	}}