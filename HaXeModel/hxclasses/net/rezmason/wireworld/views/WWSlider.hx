package net.rezmason.wireworld.views;

extern class WWSlider extends WWElement {
	var thumbRatio : Float;
	var value : Float;
	function new(__label : String, ?__width : Float, ?__height : Float, ?__thumbRatio : Float) : Void;
	function startZip(amount : Float) : Void;
	function stopZip() : Void;
	static var ZIP_STEP : Float;
}
