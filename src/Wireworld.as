package {

	import flash.display.Sprite;
	import flash.events.Event;
	
	import net.rezmason.wireworld.Main;

	[SWF(width='800', height='648', backgroundColor='#000000', frameRate='30')]
	public final class Wireworld extends Sprite {
		
		// Entry point.
		
		public function Wireworld():void {
			addMainToStage();
		}
		
		private function addMainToStage(event:Event = null):void {
			if (stage) {
				stage.addChild(new Main);
				removeEventListener(Event.ADDED_TO_STAGE, addMainToStage);
			} else if (!event) {
				addEventListener(Event.ADDED_TO_STAGE, addMainToStage);
			}
		}
	}
}
