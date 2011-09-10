package net.rezmason.gui {
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public dynamic final class SimpleBridge extends EventDispatcher {
		public var eventTypes:Object = {};
		public var state:Object = {};
		public var config:Object = {};
		public var assets:Object;
		/*
		public var uiScaleMag:Number = 1;
		public var keyboardPrompt:Function;
		public var useSimpleText:Boolean = false;
		*/
		public function SimpleBridge(target:IEventDispatcher=null) { super(target); }
	}
}