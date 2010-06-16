﻿/*** Wireworld Player by Jeremy Sachs. January 23, 2010** Feel free to distribute the source, just try not to hand it off to some douchebag.* Keep this header here.** Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.*/package net.rezmason.wireworld {		//---------------------------------------	// IMPORT STATEMENTS	//---------------------------------------	import __AS3__.vec.Vector;		import flash.events.ErrorEvent;	import flash.events.Event;	import flash.events.TimerEvent;	import flash.net.FileReference;	import flash.utils.ByteArray;	import flash.utils.Timer;	import flash.utils.getTimer;		import net.rezmason.net.Reader;	internal final class Controller {				// Most of the boss logic is in this class.		// The Controller is mainly used to load, upload		// and download data into the player, and to manage		// the timer which drives the simulation.				//---------------------------------------		// CLASS CONSTANTS		//---------------------------------------				[Embed(source='../../../../examples/txt/owen_moore/owen_moore.txt', mimeType="application/octet-stream")]		private static const COMP_DATA:Class;				private static const COMP_CRED:String = 			"Wireworld computer\n" + 			"©2004-2007 David Moore and Mark Owen\nwww.quinapalus.com\n" + 			"\nbetter a witty fool than a foolish wit";		private static const COMP_FILE:String = "owen_moore.txt";				private static const OVERDRIVE_CLIMB:Number = 0.05;				private static const HISTORY_FREQUENCY:int = 10;				//---------------------------------------		// PRIVATE VARIABLES		//---------------------------------------		private var botherModel:Boolean = true;		private var dirtyFPS:Boolean = false;		private var fps:Vector.<int>= new <int>[];		private var currentTimer:Timer;		private var variableTimer:Timer = new Timer(1);		private var overdriveTimer:Timer = new Timer(0);		private var overdrivePeriodTimer:Timer = new Timer(250);		private var refreshFn:Function;		private var pauseMotionTimer:Timer = new Timer(50, 1);		private var initialized:Boolean = false;		private var _updateHeat:Boolean = false;		private var fileReference:FileReference = new FileReference();		private var imageSaver:ImageSaver = new ImageSaver();				private var _view:View;		private var _model:IModel;				private var loadingFromLocal:Boolean = false;		private var _data:String;				private var fileName:String;		private var loadTimer:Timer = new Timer(10000, 1);		private var fpsTimer:Timer = new Timer(500);				private var ike:int;		private var overdriveSpeed:int, overdriveTime:int, overdriveUpdates:int, overdriveRate:Number;				//---------------------------------------		// CONSTRUCTOR		//---------------------------------------		public function Controller(__model:IModel):void {						_model = __model;			_model.addEventListener(WireworldEvent.MODEL_BUSY, toggleModelUpdates);			_model.addEventListener(WireworldEvent.MODEL_IDLE, toggleModelUpdates);						refreshFn = _model.refreshImage;						// timer setup			variableTimer.addEventListener(TimerEvent.TIMER, updateNormal);			overdriveTimer.addEventListener(TimerEvent.TIMER, updateOverdrive);			currentTimer = variableTimer;			pauseMotionTimer.addEventListener(TimerEvent.TIMER_COMPLETE, unpauseMotion);						// listen to data structure			_model.addEventListener(Event.COMPLETE, begin);						fpsTimer.addEventListener(TimerEvent.TIMER, checkFPS);			fpsTimer.start();			_model.addEventListener(ErrorEvent.ERROR, showError);						Reader.addEventListener(Reader.PATH_ERROR, showError);			Reader.addEventListener(Reader.LOAD_ERROR, showError);			Reader.addEventListener(Event.COMPLETE, initializeModel);						fileReference.addEventListener(Event.SELECT, loadFile);			fileReference.addEventListener(Event.CANCEL, escapeFileBrowser);			fileReference.addEventListener(Event.COMPLETE, initializeModel);			loadTimer.addEventListener(TimerEvent.TIMER_COMPLETE, cancelLoad);						overdrivePeriodTimer.addEventListener(TimerEvent.TIMER, checkOverdrive);		}				//---------------------------------------		// GETTER / SETTERS		//---------------------------------------				internal function get model():IModel {			return _model;		}				//---------------------------------------		// INTERNAL METHODS		//---------------------------------------				internal function init(__view:View):void {			_view = __view;			_view.showAbout();						// default file - the Wireworld computer by Owen and Moore			fileName = COMP_FILE;			_view.setFileName(fileName);			loadingFromLocal = false;			Reader.loadBytes(new COMP_DATA as ByteArray);		}				internal function play(event:Event = null):void {			if (!currentTimer.running) {				currentTimer.start();			}		}				internal function pause(event:Event = null):void {			if (currentTimer.running) {				currentTimer.stop();			}		}				internal function togglePlayPause(event:Event = null):void {			if (!currentTimer.running) {				play();			} else {				pause();			}		}				internal function step(event:Event = null):void {			updateNormal(null, true);		}				internal function reset(event:Event = null):void {			pause();			_model.reset();			_view.updateGeneration(_model.generation);		}				internal function adjustSpeed(value:Number):void {			if (variableTimer.running) updateNormal();			variableTimer.delay = int(Math.max(0, Math.pow(2, 10 * (1 - value))));		}				// Overdrive is that button that looks like a radioactive symbol.		// It changes the Controller's behavior to accelerate the model		// and slow down updates from the model to the view.		internal function toggleOverdrive(event:Event = null):void {			if (_model.implementsOverdrive) {				_model.overdriveActive = !_model.overdriveActive;			} else {				var wasRunning:Boolean = currentTimer.running;				currentTimer.stop();				currentTimer.reset();				if (currentTimer == variableTimer) {					resetOverdrive();					currentTimer = overdriveTimer;				} else {					overdrivePeriodTimer.reset();					currentTimer = variableTimer;				}				if (wasRunning) {					currentTimer.start();				}			}		}				// The sim is paused and unpaused when the user starts 		// and stops moving the mouse. This keeps the GUI responsive.				internal function pauseMotion(event:Event = null):void {			if (currentTimer.running || pauseMotionTimer.running) {				currentTimer.stop();				pauseMotionTimer.reset();				pauseMotionTimer.start();				overdrivePeriodTimer.stop();			}		}				internal function unpauseMotion(event:TimerEvent):void {			currentTimer.start();			if (currentTimer == overdriveTimer) {				overdrivePeriodTimer.start();			}		}				// Opens the save dialog, lets you download a PNG.				internal function save(event:Event = null):void {			var snapshotSuspended:Boolean = false;						if (currentTimer.running) {				currentTimer.stop();				snapshotSuspended = true;			}						imageSaver.save(_view.snapshot());						if (snapshotSuspended) {				currentTimer.start();			}		}				// load methods.				internal function loadFromDisk(event:Event = null):void {			loadingFromLocal = true;			pause();			_view.showDisabler();			fileReference.browse([WireworldFileType.TXT_TYPE, WireworldFileType.MCL_TYPE]);		}				internal function loadFromWeb(event:Event = null):void {			var _url:String = _view.loadURL;			fileName = _url.substr(_url.lastIndexOf("/") + 1);			_view.setFileName(fileName);			_view.showLoading();			loadingFromLocal = false;			if (_url.indexOf("://") == -1) {				Reader.load("http://" + _url);			} else {				Reader.load("http://" + _url.substr(_url.indexOf("://") + 3));			}		}				// Heat view. Shows the busiest parts of a simulation over time.		internal function toggleHeat():void {			_updateHeat = !_updateHeat;			if (_updateHeat) {				refreshFn = refreshHeat;			} else {				refreshFn = _model.refreshImage;			}						_model.refreshAll();		}				//---------------------------------------		// PRIVATE METHODS		//---------------------------------------				private function toggleModelUpdates(event:Event):void {			if (event.type == WireworldEvent.MODEL_BUSY) {				botherModel = false;			} else if (event.type == WireworldEvent.MODEL_IDLE) {				botherModel = true;			}		}				// Standard update. Slow and steady. 				private function updateNormal(event:TimerEvent = null, forceHeatUpdate:Boolean = false):void {						if (botherModel) {				_model.update();				if (forceHeatUpdate) {					_model.refreshAll();				} else {					refreshFn();				}				_view.updateAnnouncers();				_view.updateGeneration(_model.generation);			}						if (dirtyFPS) {				trackFPS();			}						if (event) {				event.updateAfterEvent();			}		}				// Overdrive methods.				private function resetOverdrive():void {			overdriveSpeed = 1;			overdriveTime = getTimer();			overdriveTime = 0;			overdriveUpdates = 0;			overdriveRate = 0;			overdrivePeriodTimer.reset();			overdrivePeriodTimer.start();		}				// Overdrive gets faster if the FPS of the view is beyond a certain threshold.		private function checkOverdrive(event:TimerEvent = null):void {			overdriveTime = getTimer() - overdriveTime;						if ((overdriveUpdates / overdriveTime) / overdriveRate - 1 > OVERDRIVE_CLIMB) {				overdriveSpeed++;				overdriveRate = overdriveUpdates / overdriveTime;				overdrivePeriodTimer.delay = 250;			} else if (overdriveSpeed > 1) {				overdrivePeriodTimer.delay = 1000;			}						overdriveTime = getTimer();			overdriveUpdates = 0;		}				private function updateOverdrive(event:TimerEvent = null, forceHeatUpdate:Boolean = false):void {						if (botherModel) {				ike = 0;				while (ike++ < overdriveSpeed) {					_model.update(); _model.update(); _model.update();					_model.update(); _model.update(); _model.update();				}							overdriveUpdates += 6 * overdriveSpeed;							_model.refreshAll();								_view.updateAnnouncers();				_view.updateGeneration(model.generation);			}						if (dirtyFPS) {				trackFPS();			}						if (event) {				event.updateAfterEvent();			}		}				private function refreshHeat():void {			if (!(_model.generation % HISTORY_FREQUENCY)) {				_model.refreshHeat();			}		}				// FPS functions				private function checkFPS(event:TimerEvent):void {			dirtyFPS = true;			fps = new <int>[getTimer()];		}				private function trackFPS():void {			fps[fps.length - 1] = 1000 / (getTimer() - fps[fps.length - 1]);						if (fps.length == 5) {				_view.updateFPS((fps[0] + fps[1] + fps[2] + fps[3] + fps[4]) * 0.2);				dirtyFPS = false;			} else {				fps.push(getTimer());			}		}				private function showError(event:ErrorEvent):void {			if (loadTimer.running) {				loadTimer.reset();			}			_view.giveAlert("Error", event.text, true);		}				private function escapeFileBrowser(event:Event):void {			_view.hideDisabler();		}				private function loadFile(event:Event):void {			_view.hideDisabler();			_view.resetToggles();						if (currentTimer.running) {				currentTimer.stop();			}						loadTimer.start();						fileName = fileReference.name;			_view.setFileName(fileName);			_view.showLoading();			loadingFromLocal = true;			fileReference.load();		}				private function cancelLoad(event:TimerEvent):void {			_view.hideAbout();			_view.giveAlert("Error","Your load timed out.", true);			fileReference.cancel();		}				// Passes file data to the model.		private function initializeModel(event:Event = null):void {						loadTimer.reset();						if (loadingFromLocal) {				_data = fileReference.data.readUTFBytes(fileReference.data.length);			} else {				_data = Reader.data;			}						_model.init(_data, _data.indexOf("#MCell") != -1);		}				// Resets itself and the view once the model has successfully initialized.		private function begin(event:Event = null):void {			reset();			_view.prime();			if (!initialized) {				_view.addEventListeners();				_model.credit = COMP_CRED;				initialized = true;			}			imageSaver.resetCount();			imageSaver.fileName = fileName;		}	}}