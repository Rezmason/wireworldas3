﻿/*** Wireworld Player by Jeremy Sachs. January 23, 2010** Feel free to distribute the source, just try not to hand it off to some douchebag.* Keep this header here.** Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.*/package net.rezmason.wireworld {		//---------------------------------------	// IMPORT STATEMENTS	//---------------------------------------	import __AS3__.vec.Vector;		import flash.events.ErrorEvent;	import flash.events.Event;	import flash.events.TimerEvent;	import flash.net.FileReference;	import flash.utils.ByteArray;	import flash.utils.Timer;	import flash.utils.getDefinitionByName;	import flash.utils.getTimer;		import net.rezmason.gui.SimpleBridge;	import net.rezmason.net.Reader;	internal final class Controller {				// Most of the boss logic is in this class.		// The Controller is mainly used to load, upload		// and download data into the player, and to manage		// the timer which drives the simulation.				//---------------------------------------		// CLASS CONSTANTS		//---------------------------------------				[Embed(source='../../../../examples/mcl/owen_moore/computer_by_mark_owen_horizontal.mcl', mimeType="application/octet-stream")]		private static const COMP_DATA:Class;		private static const COMP_FILE:String = "computer_by_mark_owen_horizontal.mcl";				private static const OVERDRIVE_CLIMB:Number = 0.05;				private static const HISTORY_FREQUENCY:int = 10;				//---------------------------------------		// PRIVATE VARIABLES		//---------------------------------------				private var FileClass:Class;		private var botherModel:Boolean = true;		private var dirtyFPS:Boolean = false;		private var fps:Vector.<int>= new <int>[];		private var currentTimer:Timer;		private var variableTimer:Timer = new Timer(1);		private var overdriveTimer:Timer = new Timer(0);		private var overdrivePeriodTimer:Timer = new Timer(250);		private var overdriveRefreshTimer:Timer = new Timer(100);		private var refreshFn:Function;		private var pauseMotionTimer:Timer = new Timer(50, 1);		private var initialized:Boolean = false;		private var _updateHeat:Boolean = false;		private var fileReference:FileReference;		private var imageSaver:ImageSaver = new ImageSaver();				private var _view:View;		private var _model:IModel;		private var _bridge:SimpleBridge;				private var loadingBytes:Boolean = false;		private var _data:String;		private var possibleURL:String;				private var fileName:String;		private var loadTimer:Timer = new Timer(10000, 1);		private var fpsTimer:Timer = new Timer(500);				private var ike:int;		private var overdriveSpeed:int, overdriveTime:int, overdriveUpdates:int, overdriveRate:Number;				//---------------------------------------		// CONSTRUCTOR		//---------------------------------------		public function Controller(__model:IModel, __view:View, __bridge:SimpleBridge = null):void {						_model = __model;			_model.addEventListener(WWEvent.MODEL_BUSY, toggleModelUpdates);			_model.addEventListener(WWEvent.MODEL_IDLE, toggleModelUpdates);						_view = __view;			_view.addEventListener(WWEvent.READY, init);			_view.addEventListener(WWEvent.PAUSE, pauseMotion);			_view.addEventListener(WWEvent.SAVE, save);			_view.addEventListener(WWEvent.STEP, step);			_view.addEventListener(WWEvent.TOGGLE_OVERDRIVE, toggleOverdrive);			_view.addEventListener(WWEvent.TOGGLE_PLAY_PAUSE, togglePlayPause);			_view.addEventListener(WWEvent.TOGGLE_HEAT, toggleHeat);			_view.addEventListener(WWEvent.ADJUST_SPEED, adjustSpeed);			_view.addEventListener(WWEvent.LOAD_FROM_DISK, loadFromDisk);			_view.addEventListener(WWEvent.LOAD_FROM_URL, loadFromURL);			_view.addEventListener(WWEvent.RESET, reset);			_view.addEventListener(Event.ACTIVATE, changeOverdriveRefreshRate);			_view.addEventListener(Event.DEACTIVATE, changeOverdriveRefreshRate);						_bridge = __bridge;			_bridge.eventTypes.FILE_LOADED = "fileLoaded";						refreshFn = _model.refreshImage;						// timer setup			variableTimer.addEventListener(TimerEvent.TIMER, updateNormal);			overdriveTimer.addEventListener(TimerEvent.TIMER, updateOverdrive);			currentTimer = variableTimer;			pauseMotionTimer.addEventListener(TimerEvent.TIMER_COMPLETE, unpauseMotion);						// listen to data structure			_model.addEventListener(Event.COMPLETE, begin);						fpsTimer.addEventListener(TimerEvent.TIMER, checkFPS);			fpsTimer.start();			_model.addEventListener(ErrorEvent.ERROR, showError);						Reader.addEventListener(Reader.PATH_ERROR, showError);			Reader.addEventListener(Reader.LOAD_ERROR, showError);			Reader.addEventListener(Event.COMPLETE, initializeModel);						try {				FileClass = getDefinitionByName("flash.filesystem.File") as Class;			} catch (error:Error) {				FileClass = FileReference;			}						fileReference = new FileClass();						fileReference.addEventListener(Event.SELECT, loadFile);			fileReference.addEventListener(Event.CANCEL, escapeFileBrowser);			fileReference.addEventListener(Event.COMPLETE, initializeModel);			loadTimer.addEventListener(TimerEvent.TIMER_COMPLETE, cancelLoad);						overdrivePeriodTimer.addEventListener(TimerEvent.TIMER, checkOverdrive);			overdriveRefreshTimer.addEventListener(TimerEvent.TIMER, refreshOverdrive);						if (_view.isReady()) init();		}				//---------------------------------------		// PRIVATE METHODS		//---------------------------------------				private function init(event:Event = null):void {						// default file - the Wireworld computer by Owen and Moore			if (_bridge && _bridge.file != undefined && _bridge.file.toString().length) {				possibleURL = _bridge.file.toString();				fileName = possibleURL.split("/").pop();				trace("Loading file:", possibleURL);				loadingBytes = false;				if (possibleURL.indexOf("://") == -1 && possibleURL.indexOf("app:/") == -1) possibleURL = "http://" + possibleURL;				Reader.load(possibleURL);			} else {				fileName = COMP_FILE;				Reader.loadBytes(new COMP_DATA as ByteArray);			}			_view.setFileName(fileName);						if (!(_bridge && _bridge.showSplash == "false")) {				_view.showAbout();			} else {				_view.showLoading();			}					}				private function play(event:Event = null):void {			if (!currentTimer.running) {				currentTimer.start();			}		}				private function pause(event:Event = null):void {			if (currentTimer.running) {				currentTimer.stop();			}		}				private function togglePlayPause(event:Event = null):void {			if (!currentTimer.running) {				play();			} else {				pause();			}		}				private function step(event:Event = null):void {			updateNormal(null, true);		}				private function reset(event:Event = null):void {			pause();			_model.reset();			_view.updateGeneration(_model.generation);		}				private function adjustSpeed(event:WWEvent):void {			if (variableTimer.running) updateNormal();			variableTimer.delay = int(Math.max(0, Math.pow(2, 10 * (1 - event.value))));		}				// Overdrive is that button that looks like a radioactive symbol.		// It changes the Controller's behavior to accelerate the model		// and slow down updates from the model to the view.		private function toggleOverdrive(event:Event = null):void {			if (_model.implementsOverdrive) {				_model.overdriveActive = !_model.overdriveActive;			} else {				var wasRunning:Boolean = currentTimer.running;				currentTimer.stop();				currentTimer.reset();				if (currentTimer == variableTimer) {					resetOverdrive();					currentTimer = overdriveTimer;				} else {					overdrivePeriodTimer.reset();					overdriveRefreshTimer.reset();					currentTimer = variableTimer;				}				if (wasRunning) {					currentTimer.start();				}			}		}				// The sim is paused and unpaused when the user starts 		// and stops moving the mouse. This keeps the GUI responsive.				private function pauseMotion(event:Event = null):void {			if (currentTimer.running || pauseMotionTimer.running) {				currentTimer.stop();				pauseMotionTimer.reset();				pauseMotionTimer.start();				overdrivePeriodTimer.stop();				overdriveRefreshTimer.stop();			}		}				private function unpauseMotion(event:TimerEvent):void {			currentTimer.start();			if (currentTimer == overdriveTimer) {				overdrivePeriodTimer.start();				overdriveRefreshTimer.start();			}		}				// Opens the save dialog, lets you download a PNG.				private function save(event:Event = null):void {			var snapshotSuspended:Boolean = false;						if (currentTimer.running) {				currentTimer.stop();				snapshotSuspended = true;			}						imageSaver.save(_view.snapshot());						if (snapshotSuspended) {				currentTimer.start();			}		}				// load methods.				private function loadFromDisk(event:Event = null):void {			loadingBytes = true;			pause();			_view.showDisabler();			fileReference.browse([WireworldFileType.TXT_TYPE, WireworldFileType.MCL_TYPE]);		}				private function loadFromURL(event:WWEvent):void {			possibleURL = event.value;			fileName = possibleURL.substr(possibleURL.lastIndexOf("/") + 1);			_view.setFileName(fileName);			_view.showLoading();			loadingBytes = false;			if (possibleURL.indexOf("://") == -1) {				Reader.load("http://" + possibleURL);			} else {				Reader.load("http://" + possibleURL.substr(possibleURL.indexOf("://") + 3));			}		}				// Heat view. Shows the busiest parts of a simulation over time.		private function toggleHeat():void {			_updateHeat = !_updateHeat;			if (_updateHeat) {				refreshFn = refreshHeat;			} else {				refreshFn = _model.refreshImage;			}						_model.refreshAll();		}				private function toggleModelUpdates(event:Event):void {			if (event.type == WWEvent.MODEL_BUSY) {				botherModel = false;			} else if (event.type == WWEvent.MODEL_IDLE) {				botherModel = true;			}		}				// Standard update. Slow and steady. 				private function updateNormal(event:TimerEvent = null, forceHeatUpdate:Boolean = false):void {						if (botherModel) {				_model.update();				if (forceHeatUpdate) {					_model.refreshAll();				} else {					refreshFn();				}				_view.updateAnnouncers();				_view.updateGeneration(_model.generation);			}						if (dirtyFPS) {				trackFPS();			}						if (event) {				event.updateAfterEvent();			}		}				// Overdrive methods.				private function resetOverdrive():void {			overdriveSpeed = 1;			overdriveTime = getTimer();			overdriveTime = 0;			overdriveUpdates = 0;			overdriveRate = 0;			overdrivePeriodTimer.reset();			overdrivePeriodTimer.start();			overdriveRefreshTimer.reset();			overdriveRefreshTimer.start();		}				// Overdrive gets faster if the FPS of the view is beyond a certain threshold.		private function checkOverdrive(event:TimerEvent = null):void {			overdriveTime = getTimer() - overdriveTime;						if ((overdriveUpdates / overdriveTime) / overdriveRate - 1 > OVERDRIVE_CLIMB) {				overdriveSpeed++;				overdriveRate = overdriveUpdates / overdriveTime;				overdrivePeriodTimer.delay = 250;			} else if (overdriveSpeed > 1) {				overdrivePeriodTimer.delay = 1000;			}						overdriveTime = getTimer();			overdriveUpdates = 0;		}				private function refreshOverdrive(event:TimerEvent = null):void {			_model.refreshAll();			_view.updateAnnouncers();			_view.updateGeneration(_model.generation);		}				private function changeOverdriveRefreshRate(event:Event):void {			overdriveRefreshTimer.delay = event.type == Event.ACTIVATE ? 100 : 1000; 		}				private function updateOverdrive(event:TimerEvent = null, forceHeatUpdate:Boolean = false):void {						if (botherModel) {				ike = 0;				while (ike++ < overdriveSpeed) {					_model.update(); _model.update(); _model.update();					_model.update(); _model.update(); _model.update();				}							overdriveUpdates += 6 * overdriveSpeed;			}						if (dirtyFPS) {				trackFPS();			}						if (event) {				event.updateAfterEvent();			}		}				private function refreshHeat():void {			if (!(_model.generation % HISTORY_FREQUENCY)) {				_model.refreshHeat();			}		}				// FPS functions				private function checkFPS(event:TimerEvent):void {			dirtyFPS = true;			fps = new <int>[getTimer()];		}				private function trackFPS():void {			fps[fps.length - 1] = 1000 / (getTimer() - fps[fps.length - 1]);						if (fps.length == 5) {				_view.updateFPS((fps[0] + fps[1] + fps[2] + fps[3] + fps[4]) * 0.2);				dirtyFPS = false;			} else {				fps.push(getTimer());			}		}				private function showError(event:ErrorEvent):void {			if (loadTimer.running) {				loadTimer.reset();			}			_view.giveAlert("Error", event.text, true);		}				private function escapeFileBrowser(event:Event):void {			_view.hideDisabler();		}				private function loadFile(event:Event):void {			_view.hideDisabler();			_view.resetToggles();						if (currentTimer.running) {				currentTimer.stop();			}						loadTimer.start();						fileName = fileReference.name;			_view.setFileName(fileName);			_view.showLoading();			loadingBytes = true;			fileReference.load();		}				private function cancelLoad(event:TimerEvent):void {			_view.hideAbout();			_view.giveAlert("Error","Your load timed out.", true);			fileReference.cancel();		}				// Passes file data to the model.		private function initializeModel(event:Event = null):void {						loadTimer.reset();						if (loadingBytes) {				_data = fileReference.data.readUTFBytes(fileReference.data.length);				if (_bridge) {					_bridge.file = fileReference.hasOwnProperty("url") ? fileReference["url"] : undefined;				}			} else {				_data = Reader.data;				if (_bridge) _bridge.file = possibleURL;			}						if (_bridge) {				_bridge.dispatchEvent(new Event(_bridge.eventTypes.FILE_LOADED));			}						_model.init(_data, _data.indexOf("#MCell") != -1);		}				// Resets itself and the view once the model has successfully initialized.		private function begin(event:Event = null):void {			reset();			_view.prime();			if (!initialized) {				_view.addGUIEventListeners();				initialized = true;			}			imageSaver.resetCount();			imageSaver.fileName = fileName;		}	}}