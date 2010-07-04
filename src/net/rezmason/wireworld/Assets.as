package net.rezmason.wireworld {
	
	import flash.display.Sprite;

	public final class Assets extends Sprite {
		
		[Embed(source='../../../../lib/symbols/announcer.svg', mimeType="application/octet-stream")]
		private static const AnnouncerSymbol:Class;
		
		public var library:Object = {
			AnnouncerSymbol:AnnouncerSymbol
		};
		
		public function Assets():void {
			
		}
	}
}