package {

	import flash.display.Sprite;
	
	import net.rezmason.wireworld.Main;

	[SWF(width='800', height='648', backgroundColor='#000000', frameRate='30')]
	public final class Wireworld extends Sprite {
		
		// Entry point.
		
		public function Wireworld():void {
			stage.addChild(new Main);
		}
	}
}
