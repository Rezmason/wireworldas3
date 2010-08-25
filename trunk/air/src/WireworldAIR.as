package {
	
	import flash.desktop.ClipboardFormats;
	import flash.desktop.DockIcon;
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeDragManager;
	import flash.desktop.SystemTrayIcon;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.profiler.showRedrawRegions;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.ui.Keyboard;
	
	import mx.controls.Menu;

	[SWF(width='800', height='648', backgroundColor='#000000', frameRate='30')]
	public final class WireworldAIR extends Sprite {
		
		private static const SWF_EXTENSION:String = ".swf";
		private static const MAX_RECENT_FILES:int = 10;
		private static const DEFAULT_FILE_REL_PATH:String = "./examples/mcl/owen_moore/computer_by_mark_owen_horizontal.mcl";
		private static const DEFAULT_FILE_URL:String = File.applicationDirectory.resolvePath(DEFAULT_FILE_REL_PATH).url;
		private static const BRAIN_PATH:String = "./bin/";
		private static const ASSETS_PATH:String = "./lib/assets.swf";
		private static const FOLLOW_MAC_CONVENTIONS:Boolean = Capabilities.os.toLowerCase().indexOf("mac") != -1;
		
		private var currentBrain:Object;
		private var bridge:Object, state:Object = {}, assets:Object;
		private var loader:Loader;
		private var assetLoader:Loader;
		private var scene:Sprite;
		private var request:URLRequest;
		private var menu:NativeMenu, mainMIs:Object, aboutMI:NativeMenuItem, quitMI:NativeMenuItem;
		private var window:NativeWindow;
		private var brainFilename:String;
		private var lastURL:String, recentURLs:Array = [];
		private var recentMenu:NativeMenu, clearRecentMI:NativeMenuItem, recentSep:NativeMenuItem;
		private var increaseSpeedMI:NativeMenuItem, decreaseSpeedMI:NativeMenuItem, lastBrainMI:NativeMenuItem;
		private var increaseZoomMI:NativeMenuItem, decreaseZoomMI:NativeMenuItem;
		private var overdriveMI:NativeMenuItem, heatMI:NativeMenuItem, toolMI:NativeMenuItem;
		private var togglePlayPauseMI:NativeMenuItem;
		private var validFileExtensions:String;
		private var prefs:SharedObject;
		
		public function WireworldAIR():void {
			
			prefs = SharedObject.getLocal("wireworldAIR");
			if (prefs.data.recentURLs) {
				recentURLs = prefs.data.recentURLs;
			}
			if (prefs.data.state) {
				state = prefs.data.state;
			}
			
			state.interactive = true;
			state.dx = state.dy = 0;
			state.zoom = 1;
			state.running = false;
			state.speed = 1;
			
			state.overdrive ||= false;
			state.overdrive ||= false;
			state.heatmap ||= false;
			state.tool ||= "hand";
			state.brain ||= 0;
			state.brainFilename ||= "wireworld" + SWF_EXTENSION;
			
			window = stage.nativeWindow;
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, saveState);
			
			buildMenu();
			updateGUI();
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT, initInstance);
			request = new URLRequest();
			
			stage.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, validateDrag);
			stage.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, loadDroppedFile);
			stage.addEventListener(FocusEvent.FOCUS_IN, handleFocusChange);
			
			assetLoader = new Loader();
			assetLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, registerAssets);
			assetLoader.load(new URLRequest(File.applicationDirectory.resolvePath(ASSETS_PATH).url));
		}
		
		private function registerAssets(event:Event):void {
			assetLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadBrain);
			assets = assetLoader.content["assets"];
			loadBrain();
		}
		
		private function loadBrain(event:Event = null):void {
			
			state.running = false;
			
			if (bridge) {
				// grab whatever important data is still on the api, then kill it
				lastURL = bridge.file;
				lastURL = lastURL.replace(/app\:/g, ".");
				for (var prop:String in bridge.eventTypes) {
					bridge.removeEventListener(bridge.eventTypes[prop], bridgeEventResponder);
				}
				tryAPICall("dispose");
			}
			
			lastURL ||= DEFAULT_FILE_REL_PATH;
			
			if (scene) {
				while (scene.numChildren) scene.removeChildAt(0);
				if (scene.parent == stage) stage.removeChild(scene);
			}
			
			scene = new Sprite();
			stage.addChild(scene);
			
			if (loader.content) loader.unloadAndStop();
			
			if (lastURL.indexOf("file://") == -1 && lastURL.indexOf("http://") == -1) {
				lastURL = File.applicationDirectory.resolvePath(lastURL).url;
			}
			
			request.url = File.applicationDirectory.resolvePath(BRAIN_PATH + brainFilename).url;
			request.url += "?file=" + lastURL;
			request.url += "&showSplash=false";
			
			trace(request.url);
			
			loader.load(request);
		}
		
		private function initInstance(event:Event):void {
			currentBrain = loader.content;
			bridge = currentBrain.bridge;
			bridge.state = state;
			bridge.assets = assets;
			currentBrain.init(scene);
			for (var prop:String in bridge.eventTypes) {
				bridge.addEventListener(bridge.eventTypes[prop], bridgeEventResponder, false, 0, true);
			}
			addRecentURL(bridge.file || "");
			updateGUI();
		}
		
		private function validateDrag(event:NativeDragEvent):void {
			var draggedFile:File = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT)[0];
			
			if (!validFileExtensions) {
				validFileExtensions = "";
				var validFileTypes:Array = bridge.validFileTypes;
				for (var ike:int = 0; ike < validFileTypes.length; ike++) {
					validFileExtensions += validFileTypes[ike].extension;
				}
			}
			
			if (validFileExtensions.indexOf(draggedFile.extension) != -1) {
				NativeDragManager.acceptDragDrop(event.currentTarget as InteractiveObject);
			}
		}
		
		private function loadDroppedFile(event:NativeDragEvent):void {
			var draggedFile:File = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT)[0];
			tryAPICall("loadFromURL", [draggedFile.url]);
		}
		
		private function buildMenu():void {
			
			mainMIs = {};
			
			if (FOLLOW_MAC_CONVENTIONS) {
				menu = NativeApplication.nativeApplication.menu;
				mainMIs.window = menu.getItemAt(menu.numItems - 1);
				item = mainMIs.app = menu.getItemAt(0);
				menu.removeAllItems();
				
				menu.addItem(item);
				aboutMI = item.submenu.getItemAt(0);
				aboutMI.data = {command:"showAbout"};
				quitMI = item.submenu.getItemAt(item.submenu.numItems - 1);
			} else {
				menu = window.menu = new NativeMenu();
			}
			menu.addEventListener(Event.SELECT, menuResponder);
			
			var item:NativeMenuItem;
			
			// make the File menu
			item = setupMainMI("File");
			setupMI(item.submenu, "Open File", "o", {command:"loadFromDisk"});
			setupMI(item.submenu, "Open Location", "l", {command:"showURLBox"});
			var openRecentMI:NativeMenuItem = setupMI(item.submenu, "Open Recent");
			openRecentMI.submenu = recentMenu = new NativeMenu();
			setupMI(recentMenu, "Wireworld Computer", "", {command:"loadFromURL", params:[DEFAULT_FILE_URL]});
			recentMenu.addItem(new NativeMenuItem("", true));
			recentSep = new NativeMenuItem("", true);
			clearRecentMI = setupMI(recentMenu, "Clear Menu", "", {command: "clearRecentMenu"}, false);
			recentMenu.addEventListener(Event.DISPLAYING, refreshRecentMenu);
			refreshRecentMenu();
			setupMI(item.submenu, "Save Snapshot", "S", {command:"snapshot"}, true);
			quitMI ||= this.setupMI(item.submenu, "Exit", "", {command: "exit"}, true);
			
			// make the Edit menu
			item = setupMainMI("Edit");
			setupMI(item.submenu, "Cut", "x", {command:"relayToFocus", event:Event.CUT});
			setupMI(item.submenu, "Copy", "c", {command:"relayToFocus", event:Event.COPY});
			setupMI(item.submenu, "Paste", "v", {command:"relayToFocus", event:Event.PASTE});
			setupMI(item.submenu, "Select All", "a", {command:"relayToFocus", event:Event.SELECT_ALL}, true);
			
			// make the Playback menu
			item = setupMainMI("Playback");
			overdriveMI = setupMI(item.submenu, "Overdrive", "O", {command:"changeState", key:"overdrive", toggle:true});
			decreaseSpeedMI = setupMI(item.submenu, "Decrease Speed", "[", {command:"changeState", key:"speed", change:-0.1}, true);
			increaseSpeedMI = setupMI(item.submenu, "Increase Speed", "]", {command:"changeState", key:"speed", change:+0.1}, false);
			toolMI = setupMI(item.submenu, "Tools", "", null, true);
			toolMI.submenu = new NativeMenu();
			setupMI(toolMI.submenu, "Hand", "h", {command:"changeState", key:"tool", value:"hand"}, false, []);
			setupMI(toolMI.submenu, "Eraser", "e", {command:"changeState", key:"tool", value:"eraser"}, false, []);
			togglePlayPauseMI = setupMI(item.submenu, "Play", " ", {command:"changeState", key:"running", toggle:true}, true, []);
			setupMI(item.submenu, "Reset", String.fromCharCode(27), {command:"reset"}, false, []);
			setupMI(item.submenu, "Step", ".", {command:"step"}, false, []);
			
			// make the Brain menu
			item = setupMainMI("Brain");
			setupMI(item.submenu, "Standard (TDSI)", "1", {command:"chooseBrain", brainName:"wireworld"});
			setupMI(item.submenu, "HaXe Memory", "2", {command:"chooseBrain", brainName:"wwhx"});
			setupMI(item.submenu, "ByteArray", "3", {command:"chooseBrain", brainName:"wwbytes"});
			setupMI(item.submenu, "Vector", "4", {command:"chooseBrain", brainName:"wwvec"});
			setupMI(item.submenu, "Linked List",  "5", {command:"chooseBrain", brainName:"wwll"});
			setupMI(item.submenu, "Pixel Bender", "6", {command:"chooseBrain", brainName:"wwpb"});
			setupMI(item.submenu, "Convolution Filter", "7", {command:"chooseBrain", brainName:"wwcf"});
			setupMI(item.submenu, "Stupid", "8", {command:"chooseBrain", brainName:"wwfirst"});
			setupMI(item.submenu, "DEBUG",  "",  {command:"chooseBrain", brainName:"wwdebug"});
			
			lastBrainMI = item.submenu.getItemAt(state.brain);
			lastBrainMI.checked = true;
			
			// make the View menu
			item = setupMainMI("View");
			decreaseZoomMI = setupMI(item.submenu, "Zoom Out", "-", {command:"zoom", params:[-0.1, true]}, false, null);
			increaseZoomMI = setupMI(item.submenu, "Zoom In",  "=", {command:"zoom", params:[+0.1, true]}, false, null);
			setupMI(item.submenu, "Reset Zoom", "0", {command:"resetView"}, false);
			heatMI = setupMI(item.submenu, "Heatmap", "t", {command:"changeState", key:"heatmap", toggle:true}, true);
			
			if (mainMIs.window) menu.addItem(mainMIs.window);
			
			// make the Help menu
			item = setupMainMI("Help");
			aboutMI ||= setupMI(item.submenu, "About Wireworld Player", "", {command:"showAbout"}, false);
			setupMI(item.submenu, "What is this?", "?", {command:"showHelp"}, false);
		}
		
		private function setupMainMI(label:String):NativeMenuItem {
			var item:NativeMenuItem = mainMIs[label.toLowerCase()] ||= new NativeMenuItem();
			item.name = item.label = label;
			if (!menu.containsItem(item)) menu.addItem(item);
			item.submenu ||= new NativeMenu();
			return item;
		}
		
		private function setupMI(targetMenu:NativeMenu, label:String = "", keyEq:String = "", 
				data:Object = null, addSepFirst:Boolean = false, modifiers:Array = null, addedModifiers:Array = null):NativeMenuItem {
			var item:NativeMenuItem = new NativeMenuItem();
			item.name = item.label = label;
			item.data = data;
			item.keyEquivalent = keyEq;
			if (addSepFirst) targetMenu.addItem(new NativeMenuItem("", true));
			targetMenu.addItem(item);
			if (modifiers) item.keyEquivalentModifiers = modifiers;
			if (addedModifiers) item.keyEquivalentModifiers = item.keyEquivalentModifiers.concat(addedModifiers); // WRONG ORDER
			return item;
		}
		
		private function tryAPICall(functionName:String, params:Array = null):* {
			if (bridge && bridge[functionName] && bridge[functionName] is Function) {
				return bridge[functionName].apply(null, params || []);
			} else {
				trace("Function \"" + functionName + "\" not found on API.");
			}
		}
		
		private function bridgeEventResponder(event:Event):void {
			switch (event.type) {
				case bridge.eventTypes.FILE_LOADED:
					addRecentURL(bridge.file);
					if (state.revisit != true) {
						state.revisit = true;
						tryAPICall("showHelp");	
					}
					System.gc(); // Why not.
					break;
				case bridge.eventTypes.CHANGE_STATE:
					updateGUI();
					break;
			}
		}
		
		private function menuResponder(event:Event):void {
			
			var targetData:Object = event.target.data;
			if (!targetData) return;
			
			var noMatch:Boolean = false;
			switch (targetData.command) {
				case "exit": 
					NativeApplication.nativeApplication.exit(); 
					break;
				case "showAbout":
					event.preventDefault();
					tryAPICall(targetData.command);
					break;
				case "clearRecentMenu": 
					recentURLs.length = 0;
					break;
				case "chooseBrain":
					if ((event.target as NativeMenuItem).checked) break;
					lastBrainMI.checked = false;
					lastBrainMI = event.target as NativeMenuItem;
					lastBrainMI.checked = true;
					state.brain = lastBrainMI.menu.getItemIndex(lastBrainMI);
					brainFilename = state.brainFilename = targetData.brainName + SWF_EXTENSION;
					loadBrain();
					break;
				case "changeState":
					if (targetData.toggle == true) {
						tryAPICall("changeState", [targetData.key, state[targetData.key] ? false : true]);
					} else if (targetData.change != undefined) {
						tryAPICall("changeState", [targetData.key, state[targetData.key] + targetData.change]);
					} else {
						tryAPICall("changeState", [targetData.key, targetData.value]);
					}
					updateGUI();
					break;
				case "relayToFocus":
					if (stage.focus) stage.focus.dispatchEvent(new Event(targetData.event));
					break;
				default: noMatch = true;
			}
			
			if (!noMatch) return;
			
			if (targetData.command) tryAPICall(targetData.command, targetData.params);
		}
		
		private function addRecentURL(url:String):void {
			// maintain the URL array
			
			if (url.length && url != DEFAULT_FILE_URL) {
				var index:int = recentURLs.indexOf(url);
				if (index != -1) recentURLs.splice(index, 1);
				recentURLs.push(url);
				if (recentURLs.length > MAX_RECENT_FILES) {
					recentURLs.splice(1, 1);
				}
			}
		}
		
		private function refreshRecentMenu(event:Event = null):void {
			var reusables:Array = [];
			var labels:Object = {};
			var item:NativeMenuItem = recentMenu.getItemAt(2);
			var testFile:File = new File();
			var itemsByLabel:Object = {};
			
			while (item != recentSep && item != clearRecentMI) {
				reusables.push(item);
				recentMenu.removeItem(item);
				item = recentMenu.getItemAt(2);
			}
			if (recentMenu.containsItem(recentSep)) recentMenu.removeItem(recentSep);
			
			for (var ike:int = 0; ike < recentURLs.length; ike++) {
				var url:String = recentURLs[ike];
				if (url.indexOf("file") != 0) {
					item = reusables.pop() || new NativeMenuItem();
					item.data = {};
					item.data.url = url;
					item.data.name = url;
					item.data.command = "loadFromURL";
					item.data.params = [url];
					item.label = item.data.name;
					itemsByLabel[item.label] ||= [];
					itemsByLabel[item.label].push(item);
					recentMenu.addItemAt(item, 2);
				} else {
					testFile.url = recentURLs[ike];
					if (testFile.exists) {
						item = reusables.pop() || new NativeMenuItem();
						item.data = {};
						item.data.url = recentURLs[ike];
						item.data.parents = testFile.nativePath.split("/").reverse();
						item.data.shownParents = [];
						item.data.name = item.data.parents.shift();
						item.data.command = "loadFromURL";
						item.data.params = [url];
						item.label = item.data.name;
						itemsByLabel[item.label] ||= [];
						itemsByLabel[item.label].push(item);
						recentMenu.addItemAt(item, 2);
					} else {
						recentURLs.splice(ike, 1);
						ike--;
					}
				}
			}
			
			var newItemsByLabel:Object;
			while (itemsByLabel) {
				newItemsByLabel = null;
				for (var prop:String in itemsByLabel) {
					var items:Array = itemsByLabel[prop];
					if (items.length <= 1) continue;
					newItemsByLabel ||= {};
					for (ike = 0; ike < items.length; ike++) {
						
						item = items[ike];
						item.data.shownParents.push(item.data.parents.shift());
						item.label = item.data.name + " — " + item.data.shownParents.join(" ▶ ");
						
						newItemsByLabel[item.label] ||= [];
						newItemsByLabel[item.label].push(item);
					}
				}
				itemsByLabel = newItemsByLabel;
			}
			
			if (recentURLs.length > 0) {
				recentMenu.addItemAt(recentSep, recentMenu.getItemIndex(clearRecentMI));
				clearRecentMI.enabled = true;
			} else {
				clearRecentMI.enabled = false;
			}
		}
		
		private function updateGUI():void {
			brainFilename = state.brainFilename;
			
			var fileMenu:NativeMenu = mainMIs.file.submenu;
			for (var ike:int = 0; ike < fileMenu.numItems; ike++) {
				fileMenu.getItemAt(ike).enabled = state.interactive;
			}
			quitMI.enabled = true;
			
			handleFocusChange();
			
			mainMIs.playback.enabled = state.interactive;
			mainMIs.brain.enabled = state.interactive;
			mainMIs.view.enabled = state.interactive;
			mainMIs.help.enabled = state.interactive;
			
			increaseSpeedMI.enabled = state.speed < 1;
			decreaseSpeedMI.enabled = state.speed > 0;
			
			increaseZoomMI.enabled = state.zoom < 1;
			decreaseZoomMI.enabled = state.zoom > 0;
			
			overdriveMI.checked = state.overdrive;
			heatMI.checked = state.heatmap;
			var toolMenu:NativeMenu = toolMI.submenu;
			for (ike = 0; ike < toolMenu.numItems; ike++) {
				var item:NativeMenuItem = toolMenu.getItemAt(ike);
				item.checked = (item.data.tool == state.tool);
			}
			togglePlayPauseMI.label = state.running ? "Pause" : "Play";
		}
		
		private function saveState(event:Event):void {
			prefs.data.state = state;
			prefs.data.recentURLs = recentURLs;
			prefs.flush();
		}
		
		private function handleFocusChange(event:FocusEvent = null):void {
			mainMIs.edit.enabled = (stage.focus && stage.focus.hasOwnProperty("text"));
		}
	}
}
