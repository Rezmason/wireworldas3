package {

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;

	import net.rezmason.gui.SimpleBridge;
	import net.rezmason.wireworld.Main;

	//import com.flashdynamix.utils.SWFProfiler;

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

		public var bridge:SimpleBridge = new SimpleBridge();

		// Entry point.

		public function Wireworld():void {
			for (var prop:String in loaderInfo.parameters) {
				bridge[prop] = loaderInfo.parameters[prop];
			}

			connectToStage();
		}
		public function init(_scene:Sprite):void { new Main(_scene, bridge); }

		private function connectToStage(event:Event = null):void {
			if (stage) {
				var scene:Sprite = new Sprite();
				stage.addChild(scene);
				init(scene);
				//SWFProfiler.init(stage, scene);
				removeEventListener(Event.ADDED_TO_STAGE, connectToStage);
			} else if (!event) {
				addEventListener(Event.ADDED_TO_STAGE, connectToStage);
			}
		}
	}
}
