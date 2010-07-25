package net.rezmason.wireworld.views {
	
	//---------------------------------------
	// IMPORT STATEMENTS
	//---------------------------------------
	import flash.display.Sprite;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	// linkTo turns Sprites into links.
	
	internal function linkTo(target:Sprite, link:String):void {
		
		function go(event:Event):void {
			navigateToURL(new URLRequest(link), "_blank");
		}
		
		target.buttonMode = target.useHandCursor = true;
		target.addEventListener(MouseEvent.CLICK, go);
	}
}