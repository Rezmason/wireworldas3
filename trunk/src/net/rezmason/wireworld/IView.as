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
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import net.rezmason.gui.SimpleBridge;
	
	public interface IView extends IEventDispatcher {
		function IView(__model:IModel, __scene:Sprite, __bridge:SimpleBridge):void;
		function set callback(func:Function):void;						// Lets the Views communicate with the Controller
		function get initialized():Boolean;
		function addGUIEventListeners():void;
		function setFileName(__fileName:String):void;
		function showLoading():void;
		function prime():void;
		function resetView(event:Event = null):void;
		function resetState(event:Event = null):void;
		function placeAnnouncer(event:Event = null):void;
		function updateAnnouncers():void;
		function showAbout(event:Event = null, interactive:Boolean = true):void;
		function giveAlert(titleText:String = null, messageText:String = null, interactive:Boolean = true):void;
		function hideDialog(target:DisplayObject = null):void;
		function resize(event:Event = null):void;
		function updatePaper(flags:int = 0):void;
		function updateGeneration(gen:uint):void;
		function updateFPS(__fps:int):void;
		function showDisabler(event:Event = null, instantly:Boolean = false):void;
		function hideDisabler(event:Event = null, instantly:Boolean = false):void;
	}
}