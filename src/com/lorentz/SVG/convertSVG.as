package com.lorentz.SVG {
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	public function convertSVG(svgType:Class, returnLeaf:Boolean = false, svgDict:Dictionary = null, imageCache:Object = null):DisplayObject {
		
		var sprite:Sprite = new Sprite();
		var svgRenderer:SVGRenderer;
		
		if (svgDict) {
			svgDict[svgType] ||= new SVGParser(XML(String(new svgType))).parse();
			svgRenderer = new SVGRenderer(svgDict[svgType], true, false, imageCache);
		} else {
			svgRenderer = new SVGRenderer(XML(String(new svgType)), true, false, imageCache);
		}
		
		while (svgRenderer.numChildren) {
			sprite.addChild(svgRenderer.getChildAt(0));
		}
		
		var returnVal:DisplayObject = sprite;
		
		if (returnLeaf) {
			while (returnVal is DisplayObjectContainer && (returnVal as DisplayObjectContainer).numChildren == 1) {
				returnVal = (returnVal as DisplayObjectContainer).getChildAt(0);
			} 
		}
		
		return returnVal;
	}	
}