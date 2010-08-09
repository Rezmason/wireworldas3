/**
* Wireworld Player by Jeremy Sachs. July 25, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.events.IEventDispatcher;
import flash.geom.Rectangle;

extern interface IModel implements IEventDispatcher {
	
	public function width():Int;
	public function height():Int;
	public function wireData():flash.display.BitmapData;
	public function headData():flash.display.BitmapData;
	public function tailData():flash.display.BitmapData;
	public function credit():String;
	public function baseGraphics():flash.display.Graphics;
	public function generation():Float;
	public function headGraphics():flash.display.Graphics;
	public function heatGraphics():flash.display.Graphics;
	public function implementsOverdrive():Bool;
	public function overdriveActive():Bool;
	public function set_overdriveActive(value:Bool):Void;
	public function tailGraphics():flash.display.Graphics;
	public function wireGraphics():flash.display.Graphics;
	
	public function eraseRect(rect:flash.geom.Rectangle):Void;
	public function getState(__x:Int, __y:Int):UInt;
	public function init(txt:String, isMCell:Bool):Void;
	public function refresh(flags:Int):Void;
	public function reset():Void;
	public function setBounds(t:Int, l:Int, b:Int, r:Int):Void;
	public function update():Void;
}
