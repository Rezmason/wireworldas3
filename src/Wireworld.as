package {

	import flash.display.Sprite;
	import flash.events.Event;
	
	import net.rezmason.wireworld.Main;

	/**
	*	Application entry point for Wireworld Player.
	*
	*	@langversion ActionScript 3.0
	*	@playerversion Flash 10.0.0
	*
	*	@author Jeremy Sachs
	*	@since 01.23.2010
	*/
	[SWF(width='800', height='648', backgroundColor='#000000', frameRate='30')]
	public final class Wireworld extends Sprite {
		
		public var api:Object;
		
		// Entry point.
		
		public function Wireworld():void {
			loaderInfo.addEventListener(Event.INIT, init);
		}
		
		private function init(event:Event):void {
			loaderInfo.removeEventListener(Event.INIT, init);
			connectToStage();
		}
		
		private function connectToStage(event:Event = null):void {
			if (stage) {
				api = new Main(stage, loaderInfo.parameters).api;
				removeEventListener(Event.ADDED_TO_STAGE, connectToStage);
			} else if (!event) {
				addEventListener(Event.ADDED_TO_STAGE, connectToStage);
			}
		}
	}
}
