﻿/*** Wireworld Player by Jeremy Sachs. July 25, 2010** Feel free to distribute the source, just try not to hand it off to some douchebag.* Keep this header here.** Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.*/package net.rezmason.wireworld.views {	//---------------------------------------	// IMPORT STATEMENTS	//---------------------------------------	import __AS3__.vec.Vector;		import apparat.math.FastMath;		import com.greensock.TweenLite;	import com.greensock.easing.Cubic;	import com.greensock.plugins.TintPlugin;	import com.greensock.plugins.TweenPlugin;	import com.pixelbreaker.ui.osx.MacMouseWheel;		import flash.display.BitmapData;	import flash.display.DisplayObject;	import flash.display.DisplayObjectContainer;	import flash.display.Loader;	import flash.display.Shape;	import flash.display.Sprite;	import flash.display.Stage;	import flash.display.StageAlign;	import flash.display.StageScaleMode;	import flash.events.Event;	import flash.events.EventDispatcher;	import flash.events.MouseEvent;	import flash.events.TimerEvent;	import flash.filters.GlowFilter;	import flash.geom.Point;	import flash.geom.Rectangle;	import flash.net.URLRequest;	import flash.system.Capabilities;	import flash.system.Security;	import flash.text.Font;	import flash.ui.Mouse;	import flash.utils.Timer;	import flash.utils.getTimer;		import net.rezmason.display.Grid;	import net.rezmason.gui.SimpleBridge;	import net.rezmason.gui.Toolbar;	import net.rezmason.gui.ToolbarAlign;	import net.rezmason.wireworld.IModel;	import net.rezmason.wireworld.IView;	import net.rezmason.wireworld.WWCommand;	import net.rezmason.wireworld.WWEvent;	import net.rezmason.wireworld.WWRefreshFlag;		// This class is responsible for managing all visual assets and the display of all information.		public final class View extends EventDispatcher implements IView {				//---------------------------------------		// CLASS CONSTANTS		//---------------------------------------				private static const CHANGE_STATE_EVENT:Event = new Event(WWCommand.CHANGE_STATE);		private static const OPAQUE_BACKGROUND_COLOR:int = 0x222222;		private static const READY_EVENT:WWEvent = new WWEvent(WWEvent.READY);		private static const ASSET_URL:String = "../lib/assets.swf";				private static const FILE_LOADED:String = "fileLoaded";		private static const FILE_LOADED_EVENT:Event = new Event(FILE_LOADED);				//---------------------------------------		// PRIVATE VARIABLES		//---------------------------------------		private var _model:IModel;		private var _scene:Sprite;		private var _assets:Object, _library:Object, _fonts:Object, _files:Object;				private var _callback:Function;				private var frozen:Boolean = false;		private var dragging:Boolean = false;		private var windowResizing:Boolean = false;		private var state:Object;		private var stage:Stage, stageListeners:Object = {};		private var window:EventDispatcher, windowListeners:Object = {};		private var _bridge:SimpleBridge;		private var _flag:int;		private var _fileName:String;		private var hint:Hint;				private var bound:Boolean = true;		private var board:Sprite;		private var grid:Grid;		private var paper:Paper;		private var disabler:Shape, disablerTween:Object = {ease:Cubic.easeOut};		private var cameraFlashTween:Object = {tint:0xFFFFFF, ease:Cubic.easeIn};		private var dialogContainer:Sprite, dialog:WWDialog, promptTarget:DisplayObject;		private var topBar:Toolbar, bottomBar:Toolbar;		private var resizeX:int, resizeY:int, uiScale:Number;		private var gui:Object, dialogs:Object;		private var cursors:Object, cursor:Cursor;		private var dirty:Boolean = false;		private var lastTime:Number = 0;				private var freezeTimer:Timer = new Timer(100, 1);				private var assetLoader:Loader;		private var creditBox:CreditBox;				private var imageSaver:ImageSaver = new ImageSaver();		private var _image:BitmapData;				//---------------------------------------		// CONSTRUCTOR		//---------------------------------------		public function View(__model:IModel, __scene:Sprite, __bridge:SimpleBridge):void {					_scene = __scene;			_model = __model;			_bridge = __bridge;			state = _bridge.state;									_bridge.eventTypes.CHANGE_STATE = WWCommand.CHANGE_STATE;			_bridge.eventTypes.FILE_LOADED = FILE_LOADED;			buildAPI();						_scene.opaqueBackground = OPAQUE_BACKGROUND_COLOR;						// If the assets aren't already available, they get loaded in 			if (_bridge.assets) {				_assets = _bridge.assets;				proceed();			} else {				assetLoader = new Loader();				assetLoader.contentLoaderInfo.addEventListener(Event.INIT, proceed);				assetLoader.load(new URLRequest(ASSET_URL));			}						TweenPlugin.activate([TintPlugin]);			imageSaver.addEventListener(Event.CANCEL, finishSnapshot);			imageSaver.addEventListener(Event.SELECT, finishSnapshot);		}				//---------------------------------------		// GETTER / SETTERS		//---------------------------------------				// this callback is how the View propagates events to the Controller.		public function set callback(func:Function):void {			_callback = func;		}				public function get initialized():Boolean {			return stage != null;		}				//---------------------------------------		// PUBLIC METHODS		//---------------------------------------				public function addGUIEventListeners():void {						listenToStage(MouseEvent.MOUSE_UP, WWElement.releaseInstances);			listenToStage(MouseEvent.MOUSE_UP, drop);			listenToStage(MouseEvent.MOUSE_DOWN, hint.hide);						board.addEventListener(MouseEvent.ROLL_OVER, showCursor);			board.addEventListener(MouseEvent.ROLL_OUT, hideCursor);			board.addEventListener(MouseEvent.MOUSE_MOVE, moveCursor);			board.addEventListener(MouseEvent.MOUSE_DOWN, closeCursor);			board.addEventListener(MouseEvent.MOUSE_UP, openCursor);						board.addEventListener(MouseEvent.MOUSE_DOWN, lift);			board.addEventListener(MouseEvent.MOUSE_MOVE, freeze);			board.addEventListener(MouseEvent.MOUSE_WHEEL, zoomByScroll);						freezeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, thaw);						_scene.addEventListener(MouseEvent.MOUSE_OVER, hint.check);		}				public function setFileName(__fileName:String):void {			_fileName = __fileName;			imageSaver.resetCount();			imageSaver.fileName = _fileName;		}				public function showLoading():void {			giveAlert("Loading file", null, false);		}				// initializes the View		public function prime():void {			hideDialog();			gui.txtFilename.text = _fileName;			paper.init(				_model.baseGraphics(), 				_model.wireGraphics(), 				_model.headGraphics(), 				_model.tailGraphics(), 				_model.heatGraphics(),				ColorPalette.appropriatePalette			);			zoom(state.zoom);			_bridge.dispatchEvent(FILE_LOADED_EVENT);		}				// wipes clean the gui of the View that are particular to the open document		public function resetView(event:Event = null):void {			paper.reset(true);			gui.zoomSlider.value = paper.zoomRatio;			_bridge.dispatchEvent(CHANGE_STATE_EVENT);		}				// restores state to its default		public function resetState(event:Event = null):void {			state.heatmap = false;			state.tool = Tool.HAND;			state.speed = 1;			state.overdrive = false;						updateGUI();			resetView();		}				public function showAbout(event:Event = null, interactive:Boolean = true):void {			showDialog(dialogs.about, interactive);		}				// Populates the alert box with a title, message, and maybe a close button		public function giveAlert(titleText:String = null, messageText:String = null, interactive:Boolean = true):void {			dialogs.alert.clearContents();			if (titleText) dialogs.alert.title = titleText;			if (messageText) dialogs.alert.addHTML(XML(messageText));			showDialog(dialogs.alert, interactive);		}				private function showPrompt(__dialog:WWDialog, target:DisplayObject):void {			showDialog(__dialog, true);			promptTarget = target;			positionPrompt();		}				private function positionPrompt():void {			var rect:Rectangle = promptTarget.getBounds(board);			if (dialog) {				dialogContainer.x = (rect.left + rect.right) * 0.5 - (dialog.speechX * dialogContainer.scaleX);				dialogContainer.y = (rect.top + rect.bottom) * 0.5 - (dialog.speechY * dialogContainer.scaleY);			} 		}				private function showDialog(__dialog:WWDialog, interactive:Boolean = false):void {			if (dialog == __dialog) {				dialog.interactive = interactive;				return;			}			hideDialog();						promptTarget = null;			dialogContainer.x = disabler.width * 0.5;			dialogContainer.y = disabler.height * 0.5;			dialog = __dialog;			dialog.visible = true;			dialog.interactive = interactive;			dialogContainer.visible = true;			dialogContainer.addChild(dialog);			showDisabler();		}				public function hideDialog(target:DisplayObject = null):void {			if (!dialog) return;			dialog.visible = false;			dialog.interactive = true;			dialogContainer.visible = false;			dialogContainer.removeChild(dialog);						hideDisabler();			var oldDialog:WWDialog = dialog;			dialog = null;						switch (target) {				case gui.url_load:					loadFromURL(gui.url_txtURL.text);					showLoading();				break;				case gui.reset_yes:					state.running = false;					reset(); 					break;				case gui.load_web:					showURLBox();				break;				case gui.load_disk:					loadFromDisk();				break;			}		}				// resizes the View when the stage has changed dimensions		public function resize(event:Event = null):void {			resizeX = FastMath.max(FastMath.max(topBar.minWidth, bottomBar.minWidth), stage.stageWidth);			resizeY = FastMath.max(160, stage.stageHeight);						// resize toolbars			uiScale = FastMath.max(1, resizeY / 600);			topBar.scale = bottomBar.scale = uiScale;			topBar.width = resizeX / uiScale;			bottomBar.width = resizeX / uiScale;			if (window) {				var minSize:Point = window["minSize"] as Point;				minSize.x = FastMath.max(topBar.minWidth, bottomBar.minWidth);				window["minSize"] = minSize;			}			bottomBar.y = resizeY - bottomBar.realHeight;						// refresh board			board.y = topBar.realHeight;			grid.width = resizeX;			grid.height = resizeY - topBar.realHeight - bottomBar.realHeight;			paper.reposition(grid.width, grid.height);			disabler.width = resizeX;			disabler.height = resizeY;			dialogContainer.scaleX = dialogContainer.scaleY = uiScale;									if (!promptTarget) {				dialogContainer.x = disabler.width  * 0.5;				dialogContainer.y = disabler.height * 0.5;			} else {				positionPrompt();			}		}				// Refreshes the paper selectively. The flags are used to indictae what needs selecting.		public function updatePaper(flags:int = 0):void {			_model.refresh(flags | _flag);			updateFPS(int(1000.0 / (getTimer() - lastTime)));			lastTime = getTimer();			dirty = true;		}				public function updateGeneration(gen:uint):void {			gui.txtGeneration.num = gen;		}				public function updateFPS(__fps:int):void {			gui.txtFramerate.num = __fps;		}				// Staples together a snapshot of the current Wireworld instance		// to a text field containing its description, stamped on a bitmap		public function snapshot():void {			_model.refresh(WWRefreshFlag.FULL | WWRefreshFlag.TAIL);			_image = paper.print();			_image = creditBox.appendCredit(_image, _model.credit());			yell(WWCommand.SET_RUNNING, false);			board.cacheAsBitmap = topBar.cacheAsBitmap = bottomBar.cacheAsBitmap = true;			showDisabler(null, true);			imageSaver.save(_image);		}				// Disabler methods. This shows and hides a big dark transparent shape		// that goes behind modal dialogs to disable the rest of the GUI.				public function showDisabler(event:Event = null, instantly:Boolean = false):void {			TweenLite.killTweensOf(disabler, true);			disabler.visible = true;			if (instantly) {				disabler.alpha = 1;			} else {				disablerTween.alpha = 1;				TweenLite.to(disabler, 1, disablerTween);			}			board.mouseEnabled = board.mouseChildren = false;			topBar.mouseChildren = bottomBar.mouseChildren = false;			hideCursor();			state.interactive = false;			_bridge.dispatchEvent(CHANGE_STATE_EVENT);		}				public function hideDisabler(event:Event = null, instantly:Boolean = false):void {			TweenLite.killTweensOf(disabler, true);			if (instantly) {				disabler.alpha = 0;				disabler.visible = false;			} else {				disablerTween.alpha = 0;				disablerTween.visible = false;				TweenLite.to(disabler, 1, disablerTween);			}			board.mouseEnabled = board.mouseChildren = true;			topBar.mouseChildren = bottomBar.mouseChildren = true;			var objects:Array = _scene.getObjectsUnderPoint(new Point(_scene.mouseX, _scene.mouseY));			if (objects.length && board.contains(objects.pop())) showCursor();			state.interactive = true;			_bridge.dispatchEvent(CHANGE_STATE_EVENT);		}				//---------------------------------------		// PRIVATE METHODS		//---------------------------------------				// Instantiates GUI once the assets are available		private function proceed(event:Event = null):void {						var prop:String;						// Absorb all the assets						if (assetLoader) {				assetLoader.removeEventListener(Event.COMPLETE, proceed);				_assets ||= assetLoader.content["assets"];			}			_bridge.assets ||= _assets;			_library = _assets.library;			_fonts = _assets.fonts;			_files = _assets.files;						for (prop in _fonts) {				Font.registerFont(_fonts[prop] as Class);			}						WWDialog.css = new _files.STYLESHEET;						// Instantiate the major display objects						board = new Sprite();			grid = new Grid(12, 0, 0);			paper = new Paper(0, 0, _model.setBounds);			disabler = new Shape();						disabler.graphics.beginFill(0x0, 0.5);			disabler.graphics.drawRect(0, 0, 10, 10);			disabler.graphics.endFill();			disabler.visible = false;						dialogContainer = new Sprite();			dialogContainer.visible = false;						hint = new Hint();						cursors = {};			cursors[Tool.HAND] = new Cursor(_library.HandCursorUp, _library.HandCursorDown);			cursors[Tool.ERASER] = new Cursor(_library.EraserCursorUp, _library.EraserCursorDown);						topBar = new Toolbar(0, 24, OPAQUE_BACKGROUND_COLOR);			topBar.rightMargin = 0;			bottomBar = new Toolbar(0, 24, OPAQUE_BACKGROUND_COLOR);						creditBox = new CreditBox((new _fonts.pixel as Font).fontName, ColorPalette.appropriatePalette);						// Populate the GUI with elements.						gui = {};			gui.reset = 		new WWButton("Reset", new _library.Stop, 18, "(]");			gui.playPause = 	new WWButton("Play / Pause", new _library.PlayPause, 18, "[]");			gui.step = 			new WWButton("Step", new _library.Step, 18, "[)");			gui.heatmap = 		new WWButton("Toggle heat vision", new _library.Heatmap, 18, "()", ButtonType.TOGGLABLE);			gui.handTool = 		new WWButton("Hand tool", new _library.HandTool, 18, "(]", ButtonType.IN_A_SET, "tool", "hand");			gui.eraserTool = 	new WWButton("Eraser tool", new _library.EraserTool, 18, "[)", ButtonType.IN_A_SET, "tool", "eraser");			gui.slow = 			new WWButton("Slow down", new _library.Slower, 18, "(]", ButtonType.CONTINUOUS);			gui.speedSlider = 	new WWSlider("Adjust speed", 100, 18, 0.25);			gui.fast = 			new WWButton("Speed up", new _library.Faster, 18, "[)", ButtonType.CONTINUOUS);			gui.overdrive = 	new WWButton("Toggle overdrive", new _library.Overdrive, 18, "()", ButtonType.TOGGLABLE);			gui.snapshot = 		new WWButton("Save picture", new _library.Snapshot, 18);			gui.help = 			new WWButton("Help!", new _library.Help, 18);			gui.about = 		new WWButton("About Wireworld player", new _library.WWAbout, 22, "(]");			gui.zoomOut = 		new WWButton("Zoom out", new _library.ZoomOut, 18, "(]", ButtonType.CONTINUOUS);			gui.resetView = 	new WWButton("Reset view", new _library.ResetView, 18, "[]");			gui.zoomSlider = 	new WWSlider("Adjust zoom", 100, 18, 0.25);			gui.zoomIn = 		new WWButton("Zoom in", new _library.ZoomIn, 18, "[)", ButtonType.CONTINUOUS);			gui.txtGeneration = new WWNumberField("Current generation", 50, 18, "-)");			gui.load = 			new WWButton("Load file", new _library.File, 18, "(]");			gui.txtFilename = 	new WWTextField("Current file", 200, 18, 25, "[)");			gui.txtFramerate = 	new WWNumberField("Framerate", 40, 18, "(-");						// Elements that go in the dialogs' toolbars						gui.alert_close = 		new WWTextButton("", "Close", 18, ButtonType.IN_A_DIALOG);			gui.about_okay = 		new WWTextButton(";-)", "OK", 18, ButtonType.IN_A_DIALOG);			gui.url_txtURL = 		new WWTextField("File URL", 320, 24, -1, "()", true);			gui.url_cancel = 		new WWTextButton("", "Cancel", 18, ButtonType.IN_A_DIALOG);			gui.url_load = 			new WWTextButton("", "Load", 18, ButtonType.IN_A_DIALOG);			gui.help_close = 		new WWTextButton("", "Great", 18, ButtonType.IN_A_DIALOG);			gui.reset_no = 			new WWTextButton("", "No", 18, ButtonType.IN_A_DIALOG);			gui.reset_yes = 		new WWTextButton("", "Yes", 18, ButtonType.IN_A_DIALOG);			gui.load_cancel = 		new WWTextButton("", "Cancel", 18, ButtonType.IN_A_DIALOG);			gui.load_web = 			new WWTextButton("", "Web", 18, ButtonType.IN_A_DIALOG);			gui.load_disk = 		new WWTextButton("", "Disk", 18, ButtonType.IN_A_DIALOG);			gui.gallery_close = 	new WWTextButton("", "Cancel", 18, ButtonType.IN_A_DIALOG);			gui.gallery_load =	 	new WWTextButton("", "Close", 18, ButtonType.IN_A_DIALOG);			gui.alert_close = 		new WWTextButton("", "OK", 18, ButtonType.IN_A_DIALOG);						// Set up and populate the dialogs						dialogs = {};						dialogs.url = new WWDialog(320, "Load from the Web", "Enter the URL of the file you want to load.");			dialogs.help = new WWDialog(600, "Help");			dialogs.about = new WWDialog(320, "Wireworld player");			dialogs.reset = new WWDialog(175, null, "Are you sure you wish to reset?", -92, -44, 8);			dialogs.load = new WWDialog(225, null, "Where is the file?", -20, -4, 8);			dialogs.gallery = new WWDialog(480, "Example Gallery");			dialogs.alert = new WWDialog();						gui.url_txtURL.filters = [new GlowFilter(0x222222, 1, 4, 4, 20, 3)];			dialogs.url.addSpacer(30);			dialogs.url.addContent(gui.url_txtURL, false);			dialogs.url.addGUIElementsToToolbar(ToolbarAlign.LEFT, false, gui.url_cancel);			dialogs.url.addGUIElementsToToolbar(ToolbarAlign.RIGHT, false, gui.url_load);						dialogs.help.addHTML(new _files.README, 300);			dialogs.help.addGUIElementsToToolbar(ToolbarAlign.RIGHT, false, gui.help_close);						// Set up the GUI triggers.						gui.reset.bind(showPrompt, false, dialogs.reset, gui.reset);			gui.playPause.bind(changeState, true, "running");			gui.step.bind(step);			gui.heatmap.bind(changeState, true, "heatmap");			gui.handTool.bind(changeState, true);			gui.eraserTool.bind(changeState, true);			gui.slow.bind(zipSpeed, true, -2);			gui.speedSlider.bind(changeState, true, "speed");			gui.fast.bind(zipSpeed, true, 2);			gui.overdrive.bind(changeState, true, "overdrive");			gui.snapshot.bind(snapshot, false);			gui.help.bind(showHelp);			gui.about.bind(showAbout);			gui.zoomOut.bind(zipZoom, true, -2);			gui.resetView.bind(resetView, false);			gui.zoomSlider.bind(changeState, true, "zoom");			gui.zoomIn.bind(zipZoom, true, 2);			gui.load.bind(showPrompt, false, dialogs.load, gui.load);						gui.alert_close.bind(hideDialog);			gui.about_okay.bind(hideDialog);			gui.url_cancel.bind(hideDialog);			gui.url_load.bind(hideDialog, false, gui.url_load);			gui.help_close.bind(hideDialog);			gui.reset_no.bind(hideDialog);			gui.reset_yes.bind(hideDialog, false, gui.reset_yes);			gui.load_cancel.bind(hideDialog);			gui.load_web.bind(hideDialog, false, gui.load_web);			gui.load_disk.bind(hideDialog, false, gui.load_disk);			gui.gallery_close.bind(hideDialog);			gui.gallery_load.bind(hideDialog);			gui.alert_close.bind(hideDialog);						// Insert the GUI elements into the toolbars.						topBar.addGUIElements(ToolbarAlign.LEFT, true, gui.reset, gui.playPause, gui.step);			topBar.addGUIElements(ToolbarAlign.LEFT, false, gui.heatmap);			topBar.addGUIElements(ToolbarAlign.LEFT, true, gui.handTool, gui.eraserTool);			topBar.addGUIElements(ToolbarAlign.CENTER, true, gui.slow, gui.speedSlider, gui.fast);			topBar.addGUIElements(ToolbarAlign.CENTER, false, gui.overdrive);			topBar.addGUIElements(ToolbarAlign.RIGHT, false, gui.snapshot, gui.help, gui.about);						bottomBar.addGUIElements(ToolbarAlign.LEFT, true, gui.zoomOut, gui.resetView, gui.zoomSlider, gui.zoomIn);			bottomBar.addGUIElements(ToolbarAlign.LEFT, false, gui.txtGeneration);			bottomBar.addGUIElements(ToolbarAlign.CENTER, true, gui.load, gui.txtFilename);			bottomBar.addGUIElements(ToolbarAlign.RIGHT, false, gui.txtFramerate);						// Populate the dialogs with content. The about box gets a little extra attention.						var ccLabel:Sprite = new Sprite();			ccLabel.addChild(new _library.CC_BY_NC).y = ccLabel.height * -0.5;			linkTo(ccLabel, "http://creativecommons.org/licenses/by-nc/3.0/");						var projectLabel:Sprite = new Sprite();			projectLabel.addChild(new _library.GoogleProject).y = projectLabel.height * -0.5;			linkTo(projectLabel, "http://code.google.com/p/wireworldas3");						dialogs.about.addGUIElementsToToolbar(ToolbarAlign.LEFT, false, ccLabel, projectLabel);			dialogs.about.addGUIElementsToToolbar(ToolbarAlign.RIGHT, false, gui.about_okay);			dialogs.about.addHTML(new _files.ABOUT);			dialogs.alert.addGUIElementsToToolbar(ToolbarAlign.RIGHT, false, gui.alert_close);			dialogs.reset.addGUIElementsToToolbar(ToolbarAlign.LEFT, false, gui.reset_no);			dialogs.reset.addGUIElementsToToolbar(ToolbarAlign.RIGHT, false, gui.reset_yes);			dialogs.load.addGUIElementsToToolbar(ToolbarAlign.LEFT, false, gui.load_cancel);			dialogs.load.addGUIElementsToToolbar(ToolbarAlign.RIGHT, false, gui.load_web, gui.load_disk);						// Set up the display list			_scene.addChild(board);			board.addChild(grid);			board.addChild(paper);			_scene.addChild(topBar);			_scene.addChild(bottomBar);			_scene.addChild(disabler);			_scene.addChild(dialogContainer);			_scene.addChild(hint);						for (prop in cursors) _scene.addChild(cursors[prop]);						// populate the GUI with default values			state.tool ||= Tool.HAND;			cursor = cursors[state.tool];			updateGUI();									if (_scene.stage) {				connectToStage();			} else {				_scene.addEventListener(Event.ADDED_TO_STAGE, connectToStage);			}		}				// Updates all the GUI elements so that they match the state		private function updateGUI():void {			bound = false;			changeState("tool", state.tool);			gui.heatmap.down = state.heatmap;			switch (state.tool) {				case Tool.ERASER: gui.eraserTool.down = true; break;				case Tool.HAND: gui.handTool.down = true; break;			}			gui.speedSlider.value = state.speed;			gui.zoomSlider.value = state.zoom;			gui.overdrive.down = state.overdrive;			bound = true;		}				// sets up the stage once it's available		private function connectToStage(event:Event = null):void {			_scene.removeEventListener(Event.ADDED_TO_STAGE, connectToStage);						stage = _scene.stage;						stage.align = StageAlign.TOP_LEFT;			stage.scaleMode = StageScaleMode.NO_SCALE;						if (Security.sandboxType != "application") {				if (Capabilities.os.toLowerCase().indexOf("mac") != -1) {					// This util is actually kind of expensive, isn't it.					MacMouseWheel.setup(stage);				}			}						listenToStage(Event.RESIZE, resize);						if (stage.hasOwnProperty("nativeWindow")) {				window = stage["nativeWindow"] as EventDispatcher;				listenToWindow("resizing", disableCursorDuringResize);			}						addGUIEventListeners();			resize();						state.heatmap ||= false;			state.tool ||= Tool.HAND;			state.speed ||= 1;			state.overdrive ||= false;						updateGUI();			resetView();						dispatchEvent(READY_EVENT);		}				// zoom methods				private function zoom(amount:Number, incremental:Boolean = false, underX:Number = NaN, underY:Number = NaN):void {			if (!state.running && dirty) {				dirty = false;				_model.refresh(WWRefreshFlag.FULL | WWRefreshFlag.TAIL | _flag);			}			paper.zoom(amount, incremental, underX, underY);			state.zoom = paper.zoomRatio;			updateGUI();			_bridge.dispatchEvent(CHANGE_STATE_EVENT);		}				private function zoomByScroll(event:MouseEvent):void {			zoom(event.delta * 0.0025, true, board.mouseX, board.mouseY);			gui.zoomSlider.value = paper.zoomRatio;			freeze();		}				private function zoomIn(event:MouseEvent = null):void { zoom(0.1, true); }		private function zoomOut(event:MouseEvent = null):void { zoom(-0.1, true); }				private function updateFlag():void {			_flag = 0;			if (state.heatmap) _flag |= WWRefreshFlag.HEAT;		}				private function yell(type:String, value:* = null):void {			if (_callback != null) _callback(type, value);		}				// Populates the bridge with functions for changing the program's state		private function buildAPI():void {						function api_changeState(key:String, value:*):void { changeState(key, value, true); }			_bridge.loadFromURL = loadFromURL;			_bridge.loadFromDisk = loadFromDisk;			_bridge.reset = reset;			_bridge.step = step;			_bridge.updateGUI = updateGUI;			_bridge.changeState = api_changeState;			_bridge.showURLBox = showURLBox;			_bridge.zoom = zoom;			_bridge.resetView = resetView;			_bridge.showHelp = showHelp;			_bridge.showAbout = showAbout;			_bridge.snapshot = snapshot;			_bridge.dispose = dispose;						_bridge.dispatchEvent(CHANGE_STATE_EVENT);		}				private function loadFromDisk():void { yell(WWCommand.LOAD_FROM_DISK); }		private function reset():void { yell(WWCommand.RESET); }		private function step():void { yell(WWCommand.STEP); }		private function loadFromURL(url:String):void { yell(WWCommand.LOAD_FROM_URL, url); }				private function dispose():void {			trace("DISSOLVE", dissolve(_scene));			stage = null;			window = null;		}				private function dissolve(container:DisplayObjectContainer):int {			var total:int = 0;			if (!container) return 0;			while (container.numChildren) {				total += 1 + dissolve(container.removeChildAt(0) as DisplayObjectContainer);			}			clearListeners();			return total;		}				// Handy for cleaning up all those event listeners				private function listenToStage(type:String, listener:Function):void {			if (!stage) return;						stageListeners[type] ||= [];			if (stageListeners[type].indexOf(listener) == -1) {				stageListeners[type].push(listener);				stage.addEventListener(type, listener, false, 0, true);			}		}				private function listenToWindow(type:String, listener:Function):void {			if (!window) return;						windowListeners[type] ||= [];			if (windowListeners[type].indexOf(listener) == -1) {				windowListeners[type].push(listener);				window.addEventListener(type, listener, false, 0, true);			}		}				private function clearListeners(event:Event = null):void {			var prop:String;			for (prop in stageListeners) {				while (stageListeners[prop].length) {					stage.removeEventListener(prop, stageListeners[prop].pop());				}				delete stageListeners[prop];			}						for (prop in windowListeners) {				while (windowListeners[prop].length) {					window.removeEventListener(prop, windowListeners[prop].pop());				}				delete windowListeners[prop];			}		}				// Functions for displaying the dialogs.				private function showHelp():void {			showDialog(dialogs.help, true);		}				private function showURLBox():void {			showDialog(dialogs.url, true);			gui.url_txtURL.text = "";			gui.url_txtURL.grabFocus();		}				// Functions that modify the View's state.				private function zipSpeed(amount:Number, down:Boolean = false):void {			down ? gui.speedSlider.startZip(amount) : gui.speedSlider.stopZip();		}				private function zipZoom(amount:Number, down:Boolean = false):void {			down ? gui.zoomSlider.startZip(amount) : gui.zoomSlider.stopZip();		}				private function changeState(key:String, value:*, fromAPI:Boolean = false):void {						if (!bound) return;						if (value != null && value != undefined) {				//if (state[key] == value) return;				state[key] = value;			}						switch (key) {				case "speed":					yell(WWCommand.ADJUST_SPEED, state.speed);				break;				case "zoom":					paper.zoomRatio = state.zoom;				break;				case "tool":				var newCursor:Cursor = cursors[state.tool];				if (cursor && cursor != newCursor) {					newCursor.mouseDown = cursor.mouseDown;					newCursor.x = cursor.x;					newCursor.x = cursor.x;					newCursor.visible = cursor.visible = false;				}				cursor = newCursor;				break;				case "running":					if (value == null) state.running = (state.running != true);					if (!state.running) _model.refresh(WWRefreshFlag.FULL | WWRefreshFlag.TAIL | _flag);					yell(WWCommand.SET_RUNNING, state.running);					board.cacheAsBitmap = topBar.cacheAsBitmap = bottomBar.cacheAsBitmap = !state.running;				break;				case "heatmap":					paper.showHeat = state.heatmap;					updateFlag();					_model.refresh(WWRefreshFlag.FULL | WWRefreshFlag.TAIL | _flag);				break;				case "overdrive":					yell(WWCommand.SET_OVERDRIVE, state.overdrive);				break;			}						if (fromAPI) {				updateGUI();			} else {				_bridge.dispatchEvent(CHANGE_STATE_EVENT);			}		}				// cursor-related functions		private function showCursor(event:Event = null):void { if (!cursor) return; cursor.visible = true; Mouse.hide(); moveCursor(); }		private function moveCursor(event:Event = null):void { if (!cursor) return; cursor.x = _scene.mouseX; cursor.y = _scene.mouseY; }		private function hideCursor(event:Event = null):void { if (!cursor) return; cursor.visible = false; Mouse.show(); }		private function closeCursor(event:Event = null):void { if (!cursor) return; cursor.mouseDown = true; }		private function openCursor(event:Event = null):void { if (!cursor) return; cursor.mouseDown = false; }				private function disableCursorDuringResize(event:Event = null):void {			if (!window) return;			stage.addEventListener(MouseEvent.MOUSE_MOVE, enableCursorAfterResize, false, 0, true);			windowResizing = true;			hideCursor();		}				private function enableCursorAfterResize(event:Event):void {			stage.removeEventListener(MouseEvent.MOUSE_MOVE, enableCursorAfterResize);			windowResizing = false;		}				private function freeze(event:Event = null):void {			if (!state.running || dragging) return;						if (freezeTimer.running) freezeTimer.reset();			freezeTimer.start();						if (frozen) return;			frozen = true;			yell(WWCommand.SET_RUNNING, false);		}				private function thaw(event:Event = null):void {			if (!frozen) return;			frozen = false;			yell(WWCommand.SET_RUNNING, state.running);		}				// The cursors' responses to a mouse up action in the app window.		private function lift(event:MouseEvent):void {			if (!state.interactive) return;			thaw();			dragging = true;			yell(WWCommand.SET_RUNNING, false);			board.cacheAsBitmap = topBar.cacheAsBitmap = bottomBar.cacheAsBitmap = true;			switch (state.tool) {				case Tool.HAND: paper.beginDrag(); _model.refresh(WWRefreshFlag.FULL | WWRefreshFlag.TAIL | _flag); break;				case Tool.ERASER:				eraseUnderCursor();				stage.addEventListener(MouseEvent.MOUSE_MOVE, eraseUnderCursor, false, 0, true);				break;			}			state.interactive = false;			_bridge.dispatchEvent(CHANGE_STATE_EVENT);		}				// The cursors' responses to a mouse down action in the app window.		private function drop(event:Event):void {			if (!dragging) return;			dragging = false;			yell(WWCommand.SET_RUNNING, state.running);			board.cacheAsBitmap = topBar.cacheAsBitmap = bottomBar.cacheAsBitmap = !state.running;			switch (state.tool) {				case Tool.HAND: paper.endDrag(); break;				case Tool.ERASER: stage.removeEventListener(MouseEvent.MOUSE_MOVE, eraseUnderCursor); break;			}			state.interactive = true;			_bridge.dispatchEvent(CHANGE_STATE_EVENT);		}				// Passes the eraser's bounds to the model for "erase" action		private function eraseUnderCursor(event:Event = null):void {			_model.eraseRect(cursor.getBounds(paper));			_model.refresh(_flag | WWRefreshFlag.TAIL);		}				// Resumes playback when the snapshot save dialog is closed		private function finishSnapshot(event:Event):void {			yell(WWCommand.SET_RUNNING, state.running);			board.cacheAsBitmap = topBar.cacheAsBitmap = bottomBar.cacheAsBitmap = !state.running;						if (event.type == Event.CANCEL) {				hideDisabler(null);			} else {				// A little eye candy				hideDisabler(null, true);				TweenLite.killTweensOf(board, true);				TweenLite.from(board, 0.25, cameraFlashTween);			}		}	}}