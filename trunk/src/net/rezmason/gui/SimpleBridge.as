package net.rezmason.gui {
	
	import __AS3__.vec.Vector;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public dynamic final class SimpleBridge extends EventDispatcher {
		public var eventTypes:Object = {};
		public function SimpleBridge(target:IEventDispatcher=null) { super(target); }
	}
}