package net.rezmason.wireworld.views;

extern class WWDialog extends flash.display.Sprite {
	var interactive : Bool;
	var speechX(default,null) : Float;
	var speechY(default,null) : Float;
	var subtitle : String;
	var title : String;
	function new(?__width : Float, ?__title : String, ?__subtitle : String, ?__speechX : Float, ?__speechY : Float, ?__margin : Float) : Void;
	function addContent(item : flash.display.DisplayObject, ?makeOpaque : Bool, ?link : String) : Void;
	function addGUIElementsToToolbar(?hAlign : Dynamic, ?kiss : Bool, ?p1 : Dynamic, ?p2 : Dynamic, ?p3 : Dynamic, ?p4 : Dynamic, ?p5 : Dynamic ) : Void;
	function addHTML(input : String, ?__height : Float) : Void;
	function addSpacer(?__height : Float) : Void;
	function clearContents() : Void;
}
