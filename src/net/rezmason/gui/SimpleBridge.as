package net.rezmason.gui {
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public dynamic final class SimpleBridge extends EventDispatcher {
		public var eventTypes:Object = {};
		public var state:Object = {};
		public function SimpleBridge(target:IEventDispatcher=null) { super(target); }
	}
}