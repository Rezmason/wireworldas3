/**
* Wireworld Player by Jeremy Sachs. June 22, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld {

	//---------------------------------------
	// IMPORT STATEMENTS
	//---------------------------------------

	import flash.display.BitmapData;
	//import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	//import flash.display.Stage;
	//import flash.display.StageAlign;
	//import flash.display.StageScaleMode;
	import flash.events.Event;
	//import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	//import flash.events.MouseEvent;
	//import flash.system.Security;
	
	import net.rezmason.gui.SimpleBridge;
	//import net.rezmason.gui.Toolbar;
	//import net.rezmason.gui.ToolbarAlign;
	//import net.rezmason.net.Syphon;
	
	// This class is responsible for managing all visual assets and the display of all information.
	
	internal interface IView extends IEventDispatcher {
		function IView(__model:IModel, __scene:Sprite, __bridge:SimpleBridge):void;
		function set callback(func:Function):void;
		function isReady():Boolean;
		function addGUIEventListeners():void;
		function setFileName(__fileName:String):void;
		function showLoading():void;
		function prime():void;
		function resetView(event:Event = null):void;
		function resetState(event:Event = null):void;
		function placeAnnouncer(event:Event = null):void;
		function updateAnnouncers():void;
		function showAbout(event:Event = null):void;
		function hideAbout(event:Event = null):void;
		function giveAlert(titleText:String, messageText:String, allowClose:Boolean = true):void;
		function hideAlert(event:Event = null):void;
		function resize(event:Event = null):void;
		function updatePaper(flags:int = 0):void;
		function updateGeneration(gen:uint):void;
		function updateFPS(__fps:int):void;
		function snapshot():BitmapData;
		function showDisabler(event:Event = null):void;
		function hideDisabler(event:Event = null):void;
	}
}