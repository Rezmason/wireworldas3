﻿/*** Wireworld Player by Jeremy Sachs. June 22, 2010** Feel free to distribute the source, just try not to hand it off to some douchebag.* Keep this header here.** Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.*/package net.rezmason.wireworld.views {	//---------------------------------------	// IMPORT STATEMENTS	//---------------------------------------	//import __AS3__.vec.Vector;		import __AS3__.vec.Vector;		import apparat.math.FastMath;		import com.pixelbreaker.ui.osx.MacMouseWheel;		import flash.display.BitmapData;	import flash.display.DisplayObjectContainer;	import flash.display.Loader;	import flash.display.Shape;	import flash.display.Sprite;	import flash.display.Stage;	import flash.display.StageAlign;	import flash.display.StageScaleMode;	import flash.events.Event;	import flash.events.EventDispatcher;	import flash.events.MouseEvent;	import flash.geom.Point;	import flash.net.URLRequest;	import flash.system.Capabilities;	import flash.system.Security;	import flash.ui.Mouse;		import net.rezmason.display.Grid;	import net.rezmason.gui.SimpleBridge;	import net.rezmason.gui.Toolbar;	import net.rezmason.gui.ToolbarAlign;	import net.rezmason.wireworld.IModel;	import net.rezmason.wireworld.IView;	import net.rezmason.wireworld.WWCommand;	import net.rezmason.wireworld.WWEvent;	import net.rezmason.wireworld.WWRefreshFlag;		// This class is responsible for managing all visual assets and the display of all information.		public final class View extends EventDispatcher implements IView {				//---------------------------------------		// CLASS CONSTANTS		//---------------------------------------				private static const CHANGE_STATE_EVENT:Event = new Event(WWCommand.CHANGE_STATE);		private static const OPAQUE_BACKGROUND_COLOR:int = 0x222222;		private static const READY_EVENT:WWEvent = new WWEvent(WWEvent.READY);		private static const ASSET_URL:String = "../lib/assets.swf";				//---------------------------------------		// PRIVATE VARIABLES		//---------------------------------------		private var _model:IModel;		private var _scene:Sprite;		private var _assets:Object;				private var _callback:Function;				private var windowResizing:Boolean = false;		private var state:Object;		private var stage:Stage, stageListeners:Object = {};		private var window:EventDispatcher, windowListeners:Object = {};		private var _bridge:SimpleBridge;		private var _flag:int;		private var _fileName:String;		private var hint:Hint;				private var board:Sprite;		private var grid:Grid;		private var paper:Paper;		private var disabler:Shape;		private var dialogContainer:Sprite;		private var topBar:Toolbar, bottomBar:Toolbar;		private var resizeX:int, resizeY:int, uiScale:Number;		private var gui:Object, dialogs:Object;		private var cursors:Object, cursor:Cursor;		private var dirty:Boolean = false;				private var assetLoader:Loader;		private var creditBox:CreditBox;				//---------------------------------------		// CONSTRUCTOR		//---------------------------------------		public function View(__model:IModel, __scene:Sprite, __bridge:SimpleBridge):void {					_scene = __scene;			_model = __model;			_bridge = __bridge;			state = _bridge.state;									_bridge.eventTypes.CHANGE_STATE = WWCommand.CHANGE_STATE;			buildAPI();						_scene.opaqueBackground = OPAQUE_BACKGROUND_COLOR;						// If the assets aren't already available, they get loaded in 			if (_bridge.assets) {				_assets = _bridge.assets;				proceed();			} else {				assetLoader = new Loader();				assetLoader.contentLoaderInfo.addEventListener(Event.INIT, proceed);				assetLoader.load(new URLRequest(ASSET_URL));			}		}				//---------------------------------------		// GETTER / SETTERS		//---------------------------------------				// this callback is how the View propagates events to the Controller.		public function set callback(func:Function):void {			_callback = func;		}				public function get initialized():Boolean {			return stage != null;		}				//---------------------------------------		// PUBLIC METHODS		//---------------------------------------				public function addGUIEventListeners():void {						listenToStage(MouseEvent.MOUSE_UP, WWElement.releaseInstances);			listenToStage(MouseEvent.MOUSE_UP, drop);			listenToStage(MouseEvent.CLICK, hint.hide);						board.addEventListener(MouseEvent.ROLL_OVER, showCursor);			board.addEventListener(MouseEvent.ROLL_OUT, hideCursor);			board.addEventListener(MouseEvent.MOUSE_MOVE, moveCursor);			board.addEventListener(MouseEvent.MOUSE_DOWN, closeCursor);			board.addEventListener(MouseEvent.MOUSE_UP, openCursor);						board.addEventListener(MouseEvent.MOUSE_DOWN, lift);			board.addEventListener(MouseEvent.MOUSE_MOVE, pauseMotion);			board.addEventListener(MouseEvent.MOUSE_WHEEL, zoomByScroll);						_scene.addEventListener(MouseEvent.MOUSE_OVER, hint.check);		}				public function setFileName(__fileName:String):void {			_fileName = __fileName;		}				public function showLoading():void {			showDisabler();		}				// initializes the View		public function prime():void {			hideDialog();			gui.txtFilename.text = _fileName;			paper.init(				_model.baseGraphics, 				_model.wireGraphics, 				_model.headGraphics, 				_model.tailGraphics, 				_model.heatGraphics,				ColorPalette.appropriatePalette			);			gui.zoomSlider.value = paper.zoomRatio;		}				// wipes clean the gui of the View that are particular to the open document		public function resetView(event:Event = null):void {			paper.reset();			gui.zoomSlider.value = paper.zoomRatio;			state.atMinZoom = state.atMaxZoom = false;			_bridge.dispatchEvent(CHANGE_STATE_EVENT);		}				// restores state to its default		public function resetState(event:Event = null):void {					}				public function placeAnnouncer(event:Event = null):void {					}				public function updateAnnouncers():void {					}				public function showAbout(event:Event = null):void {			showDisabler();		}				// Populates the alert box with a title, message, and maybe a close button		public function giveAlert(titleText:String, messageText:String, allowClose:Boolean = true):void {					}				public function hideDialog(event:Event = null):void {			hideDisabler();			dialogContainer.visible = false;			while (dialogContainer.numChildren) dialogContainer.removeChildAt(0);		}				// resizes the View when the stage has changed dimensions		public function resize(event:Event = null):void {			resizeX = FastMath.max(FastMath.max(topBar.minWidth, bottomBar.minWidth), stage.stageWidth);			resizeY = FastMath.max(160, stage.stageHeight);						// resize toolbars			uiScale = FastMath.max(1, resizeY / 600);			topBar.scale = bottomBar.scale = uiScale;			topBar.width = resizeX / uiScale;			bottomBar.width = resizeX / uiScale;			if (window) {				var minSize:Point = window["minSize"] as Point;				minSize.x = FastMath.max(topBar.minWidth, bottomBar.minWidth);				window["minSize"] = minSize;			}			bottomBar.y = resizeY - bottomBar.realHeight;						// refresh board			board.y = topBar.realHeight;			grid.width = resizeX;			grid.height = resizeY - topBar.realHeight - bottomBar.realHeight;			paper.reposition(grid.width, grid.height);			disabler.width = resizeX;			disabler.height = resizeY;			disabler.visible = false;						dialogContainer.x = int(resizeX * 0.5);			dialogContainer.y = int(resizeY * 0.5);			dialogContainer.visible = false;		}				public function updatePaper(flags:int = 0):void {			_model.refresh(flags | _flag);			dirty = true;		}				public function updateGeneration(gen:uint):void {			gui.txtGeneration.text = gen.toString();		}				public function updateFPS(__fps:int):void {			gui.txtFramerate.text = __fps.toString();		}						// Staples together a snapshot of the current Wireworld instance		// to a text field containing its description, stamped on a bitmap		public function snapshot():BitmapData {			_model.refresh(WWRefreshFlag.FULL | WWRefreshFlag.TAIL);			var image:BitmapData = paper.print();			var credit:String = _model.credit;			if (credit) image = creditBox.appendCredit(image, credit);			return image;		}				// Disabler methods. This shows and hides a big dark transparent shape		// that goes behind modal dialogs to disable the rest of the GUI.				public function showDisabler(event:Event = null):void {			disabler.visible = true;			hideCursor();			state.interactive = false;			_bridge.dispatchEvent(CHANGE_STATE_EVENT);		}				public function hideDisabler(event:Event = null):void {			disabler.visible = false;			if (board.hitTestPoint(board.mouseX, board.mouseY)) showCursor();			state.interactive = true;			_bridge.dispatchEvent(CHANGE_STATE_EVENT);		}				//---------------------------------------		// PRIVATE METHODS		//---------------------------------------				// Instantiates GUI gui once the assets are available		private function proceed(event:Event = null):void {						var prop:String;						assetLoader.removeEventListener(Event.COMPLETE, proceed);			_assets ||= assetLoader.content["library"];						board = new Sprite();			grid = new Grid(12, 0, 0);			paper = new Paper(0, 0, _model.setBounds);			disabler = new Shape();						disabler.graphics.beginFill(0x0, 0.5);			disabler.graphics.drawRect(0, 0, 10, 10);			disabler.graphics.endFill();						dialogContainer = new Sprite();			hint = new Hint();						cursors = {};			cursors[Tool.HAND] = new Cursor(_assets.HandCursorUp, _assets.HandCursorDown);			cursors[Tool.ERASER] = new Cursor(_assets.EraserCursorUp, _assets.EraserCursorDown);			changeState("tool", Tool.HAND);						topBar = new Toolbar(0, 24, OPAQUE_BACKGROUND_COLOR);			topBar.rightMargin = 0;			bottomBar = new Toolbar(0, 24, OPAQUE_BACKGROUND_COLOR);						creditBox = new CreditBox(assetLoader.content["fonts"].FrucadeMedium);						// Populate the GUI with elements.						gui = {};			gui.reset = 		new WWButton("Reset", new _assets.Stop, 18, "(]");			gui.playPause = 	new WWButton("Play / Pause", new _assets.PlayPause, 18, "[]");			gui.step = 			new WWButton("Step", new _assets.Step, 18, "[)");			gui.heatmap = 		new WWButton("Toggle heat vision", new _assets.Heatmap, 18, "()", ButtonType.TOGGLABLE);			gui.handTool = 		new WWButton("Hand tool", new _assets.HandTool, 18, "(]", ButtonType.IN_A_SET, "tool", "hand");			gui.eraserTool = 	new WWButton("Eraser tool", new _assets.EraserTool, 18, "[)", ButtonType.IN_A_SET, "tool", "eraser");			gui.slow = 			new WWButton("Slow down", new _assets.Slower, 18, "(]", ButtonType.CONTINUOUS);			gui.speedSlider = 	new WWSlider("Adjust speed", 100, 18);			gui.fast = 			new WWButton("Speed up", new _assets.Faster, 18, "[)", ButtonType.CONTINUOUS);			gui.overdrive = 	new WWButton("Overdrive", new _assets.Overdrive, 18, "()", ButtonType.TOGGLABLE);			gui.snapshot = 		new WWButton("Save picture", new _assets.Snapshot, 18);			gui.help = 			new WWButton("Help!", new _assets.Help, 18);			gui.about = 		new WWButton("About Wireworld player", new _assets.WWAbout, 24, "(]");			gui.zoomOut = 		new WWButton("Zoom out", new _assets.ZoomOut, 18, "(]", ButtonType.CONTINUOUS);			gui.resetView = 	new WWButton("Reset view", new _assets.ResetView, 18, "[]");			gui.zoomSlider = 	new WWSlider("Adjust zoom", 100, 18);			gui.zoomIn = 		new WWButton("Zoom in", new _assets.ZoomIn, 18, "[)", ButtonType.CONTINUOUS);			gui.txtGeneration = new WWTextField("Current generation", 80, 18, 10, "-)");			gui.load = 			new WWButton("Load file", new _assets.File, 18, "(]");			gui.txtFilename = 	new WWTextField("Current file", 200, 18, 25, "[)");			gui.txtAnnouncer = 	new WWTextField("Announcer label", 100, 18, 15, "(]", true, "<label>");			gui.announcer = 	new WWButton("Add announcer", new _assets.Announcer, 18, "[)");			gui.txtFramerate = 	new WWTextField("Framerate", 40, 18, 3, "(-");						// Elements that go in the dialogs						// Set up the GUI triggers.						gui.reset.bind(showResetPrompt);			gui.playPause.bind(changeState, true, "running");			gui.step.bind(yell, false, WWCommand.STEP);			gui.heatmap.bind(changeState, true, "heatmap");			gui.handTool.bind(changeState, true);			gui.eraserTool.bind(changeState, true);			gui.slow.bind(zipSpeed, true, -2);			gui.speedSlider.bind(changeState, true, "speed");			gui.fast.bind(zipSpeed, true, 2);			gui.overdrive.bind(changeState, true, "overdrive");			gui.snapshot.bind(yell, false, WWCommand.SAVE);			gui.help.bind(showHelp);			gui.about.bind(showAbout);			gui.zoomOut.bind(zipZoom, true, -2);			gui.resetView.bind(resetView, false);			gui.zoomSlider.bind(changeState, true, "zoom");			gui.zoomIn.bind(zipZoom, true, 2);			gui.load.bind(showLoadPrompt);			gui.txtAnnouncer.bind(nameAnnouncer, true);			gui.announcer.bind(addAnnouncer);						// Set up the default GUI values						// Insert the GUI elements into the toolbars.						topBar.addGUIElements(ToolbarAlign.LEFT, true, gui.reset, gui.playPause, gui.step);			topBar.addGUIElements(ToolbarAlign.LEFT, false, gui.heatmap);			topBar.addGUIElements(ToolbarAlign.LEFT, true, gui.handTool, gui.eraserTool);			topBar.addGUIElements(ToolbarAlign.CENTER, true, gui.slow, gui.speedSlider, gui.fast);			topBar.addGUIElements(ToolbarAlign.CENTER, false, gui.overdrive);			topBar.addGUIElements(ToolbarAlign.RIGHT, false, gui.snapshot, gui.help, gui.about);						bottomBar.addGUIElements(ToolbarAlign.LEFT, true, gui.zoomOut, gui.resetView, gui.zoomSlider, gui.zoomIn);			bottomBar.addGUIElements(ToolbarAlign.LEFT, false, gui.txtGeneration);			bottomBar.addGUIElements(ToolbarAlign.CENTER, true, gui.load, gui.txtFilename);			bottomBar.addGUIElements(ToolbarAlign.RIGHT, true, gui.txtAnnouncer, gui.announcer);			bottomBar.addGUIElements(ToolbarAlign.RIGHT, false, gui.txtFramerate);						// Set up the dialogs						dialogs = {};			/*			dialogs.url = new WWDialog(320, "Load from the Web");			dialogs.help = new WWDialog(480);			dialogs.about = new WWDialog("Wireworld player");			dialogs.reset = new WWDialog(175, null, null, -90, -20);			dialogs.load = new WWDialog(225, null, null, 50, 20);			dialogs.gallery = new WWDialog(480, "Example Gallery");			*/						// URL box: 320, 240			// Load from the Web			// Enter the URL of the file you want to load.			// Cancel			// Load						// Help box: 480, 480			// What is all this?			// hovertext: README			// 			// Great						// About box: 320, 240			// Wireworld player			// written by <a>Jeremy Sachs</a>			// original concept by <a>Brian Silverman</a>			// ...			// Close			// top right corner: TDSI						_scene.addChild(board);			board.addChild(grid);			board.addChild(paper);			_scene.addChild(topBar);			_scene.addChild(bottomBar);			_scene.addChild(disabler);			_scene.addChild(dialogContainer);			_scene.addChild(hint);			for (prop in cursors) {				_scene.addChild(cursors[prop]);			}						if (_scene.stage) {				connectToStage();			} else {				_scene.addEventListener(Event.ADDED_TO_STAGE, connectToStage);			}		}				// sets up the stage once it's available		private function connectToStage(event:Event = null):void {			_scene.removeEventListener(Event.ADDED_TO_STAGE, connectToStage);						stage = _scene.stage;						stage.align = StageAlign.TOP_LEFT;			stage.scaleMode = StageScaleMode.NO_SCALE;						if (Security.sandboxType != "application") {				if (Capabilities.os.toLowerCase().indexOf("mac") != -1) {					// This util is actually kind of expensive, isn't it.					MacMouseWheel.setup(stage);				}			}						listenToStage(Event.RESIZE, resize);						if (stage.hasOwnProperty("nativeWindow")) {				window = stage["nativeWindow"] as EventDispatcher;				listenToWindow("resizing", disableCursorDuringResize);			}						resize();			dispatchEvent(READY_EVENT);		}				// zoom methods				private function zoom(amount:Number, incremental:Boolean = false, underX:Number = NaN, underY:Number = NaN):void {			if (!state.running && dirty) {				dirty = false;				_model.refresh(WWRefreshFlag.FULL | WWRefreshFlag.TAIL | _flag);			}			paper.zoom(amount, incremental, underX, underY);			state.atMinZoom = paper.zoomRatio <= 0;			state.atMaxZoom = paper.zoomRatio >= 1;			_bridge.dispatchEvent(CHANGE_STATE_EVENT);		}				private function zoomByScroll(event:MouseEvent):void {			zoom(event.delta * 0.0025, true, board.mouseX, board.mouseY);			gui.zoomSlider.value = paper.zoomRatio;			pauseMotion();		}				private function zoomIn(event:MouseEvent = null):void { zoom(0.1); }		private function zoomOut(event:MouseEvent = null):void { zoom(-0.1); }				private function updateFlag():void {			_flag = 0;			if (state.heatmap) _flag |= WWRefreshFlag.HEAT;		}				private function yell(type:String, value:* = null):void {			if (_callback != null) _callback(type, value);		}				private function pauseMotion(event:Event = null):void {			yell(WWCommand.SET_FROZEN, false);		}				private function buildAPI():void {					}				private function dissolve(container:DisplayObjectContainer):int {			var total:int = 0;			if (!container) return 0;			while (container.numChildren) {				total += 1 + dissolve(container.removeChildAt(0) as DisplayObjectContainer);			}			clearListeners();			return total;		}				private function listenToStage(type:String, listener:Function):void {			if (!stage) return;						stageListeners[type] ||= [];			if (stageListeners[type].indexOf(listener) == -1) {				stageListeners[type].push(listener);				stage.addEventListener(type, listener, false, 0, true);			}		}				private function listenToWindow(type:String, listener:Function):void {			if (!window) return;						windowListeners[type] ||= [];			if (windowListeners[type].indexOf(listener) == -1) {				windowListeners[type].push(listener);				window.addEventListener(type, listener, false, 0, true);			}		}				private function clearListeners(event:Event = null):void {			var prop:String;			for (prop in stageListeners) {				while (stageListeners[prop].length) {					stage.removeEventListener(prop, stageListeners[prop].pop());				}				delete stageListeners[prop];			}						for (prop in windowListeners) {				while (windowListeners[prop].length) {					window.removeEventListener(prop, windowListeners[prop].pop());				}				delete windowListeners[prop];			}		}				private function addAnnouncer():void {					}				private function nameAnnouncer(name:String):void {			trace("nameAnnouncer: \"" + name + "\"");		}				private function showHelp():void {			showDisabler();		}				private function showLoadPrompt():void {			showDisabler();		}				private function showResetPrompt():void {			showDisabler();		}				private function zipSpeed(amount:Number, down:Boolean = false):void {			down ? gui.speedSlider.startZip(amount) : gui.speedSlider.stopZip();		}				private function zipZoom(amount:Number, down:Boolean = false):void {			down ? gui.zoomSlider.startZip(amount) : gui.zoomSlider.stopZip();		}				private function changeState(key:String, value:*, fromAPI:Boolean = false):void {						if (value != null && value != undefined) {				if (state[key] == value) return;				state[key] = value;			}						switch (key) {				case "speed":					yell(WWCommand.ADJUST_SPEED, state.speed);				break;				case "zoom":					paper.zoomRatio = state.zoom;				break;				case "tool":				var newCursor:Cursor = cursors[state.tool];				if (cursor && cursor != newCursor) {					newCursor.mouseDown = cursor.mouseDown;					newCursor.x = cursor.x;					newCursor.x = cursor.x;					newCursor.visible = cursor.visible = false;				}				cursor = newCursor;				break;				case "running":					state.running = (state.running != true);					if (!state.running) _model.refresh(WWRefreshFlag.FULL | WWRefreshFlag.TAIL | _flag);					yell(WWCommand.SET_RUNNING, state.running);				break;				case "heatmap":					paper.showHeat = state.heatmap;					updateFlag();					_model.refresh(WWRefreshFlag.FULL | WWRefreshFlag.TAIL | _flag);				break;				case "overdrive":					yell(WWCommand.SET_OVERDRIVE, state.overdrive);				break;			}						if (!fromAPI) _bridge.dispatchEvent(CHANGE_STATE_EVENT);		}				// cursor-related functions		private function showCursor(event:Event = null):void { cursor.visible = true; Mouse.hide(); moveCursor(); }		private function moveCursor(event:Event = null):void { cursor.x = _scene.mouseX; cursor.y = _scene.mouseY; }		private function hideCursor(event:Event = null):void { cursor.visible = false; Mouse.show(); }		private function closeCursor(event:Event = null):void { cursor.mouseDown = true; }		private function openCursor(event:Event = null):void { cursor.mouseDown = false; }				private function disableCursorDuringResize(event:Event = null):void {			if (!window) return;			stage.addEventListener(MouseEvent.MOUSE_MOVE, enableCursorAfterResize, false, 0, true);			windowResizing = true;			hideCursor();		} 				private function enableCursorAfterResize(event:Event):void {			stage.removeEventListener(MouseEvent.MOUSE_MOVE, enableCursorAfterResize);			windowResizing = false;		}				// The cursors' responses to a mouse up action in the app window.		private function lift(event:MouseEvent):void {			yell(WWCommand.SET_RUNNING, false);			switch (state.tool) {				case Tool.HAND: paper.beginDrag(); _model.refresh(WWRefreshFlag.FULL | WWRefreshFlag.TAIL | _flag); break;				case Tool.ERASER:				eraseUnderCursor();				stage.addEventListener(MouseEvent.MOUSE_MOVE, eraseUnderCursor, false, 0, true);				break;			}			state.interactive = false;			_bridge.dispatchEvent(CHANGE_STATE_EVENT);		}				// The cursors' responses to a mouse down action in the app window.		private function drop(event:Event):void {			yell(WWCommand.SET_RUNNING, state.running);			switch (state.tool) {				case Tool.HAND: paper.endDrag(); break;				case Tool.ERASER: stage.removeEventListener(MouseEvent.MOUSE_MOVE, eraseUnderCursor); break;			}			state.interactive = true;			_bridge.dispatchEvent(CHANGE_STATE_EVENT);		}				// Passes the eraser's bounds to the model for "erase" action		private function eraseUnderCursor(event:Event = null):void {			_model.eraseRect(cursor.getBounds(paper));			_model.refresh(_flag | WWRefreshFlag.TAIL);		}	}}