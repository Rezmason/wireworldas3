package net.rezmason.wireworld {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.Font;

	public final class Assets extends Sprite {
		
		[Embed(source='../../../../lib/symbols/announcer.svg')]
		private static const Symbol_announcer:Class;
		
		[Embed(source='../../../../lib/symbols/cc_by-nc.png')]
		private static const Symbol_cc_by_nc:Class;
		
		[Embed(source='../../../../lib/symbols/eraser-tool.svg')]
		private static const Symbol_eraser_tool:Class;
		
		[Embed(source='../../../../lib/symbols/eraser_cursor_down.png')]
		private static const Symbol_eraser_cursor_down:Class;
		
		[Embed(source='../../../../lib/symbols/eraser_cursor_up.png')]
		private static const Symbol_eraser_cursor_up:Class;
		
		[Embed(source='../../../../lib/symbols/faster.svg')]
		private static const Symbol_faster:Class;
		
		[Embed(source='../../../../lib/symbols/file.svg')]
		private static const Symbol_file:Class;
		
		[Embed(source='../../../../lib/symbols/gallery.svg')]
		private static const Symbol_gallery:Class;
		
		[Embed(source='../../../../lib/symbols/google_project.svg')]
		private static const Symbol_google_project:Class;
		
		[Embed(source='../../../../lib/symbols/hand-tool.svg')]
		private static const Symbol_hand_tool:Class;
		
		[Embed(source='../../../../lib/symbols/hand_cursor_down.png')]
		private static const Symbol_hand_cursor_down:Class;
		
		[Embed(source='../../../../lib/symbols/hand_cursor_up.png')]
		private static const Symbol_hand_cursor_up:Class;
		
		[Embed(source='../../../../lib/symbols/heatmap.svg')]
		private static const Symbol_heatmap:Class;
		
		[Embed(source='../../../../lib/symbols/help.svg')]
		private static const Symbol_help:Class;
		
		[Embed(source='../../../../lib/symbols/overdrive.svg')]
		private static const Symbol_overdrive:Class;
		
		[Embed(source='../../../../lib/symbols/play-pause.svg')]
		private static const Symbol_play_pause:Class;
		
		[Embed(source='../../../../lib/symbols/reset-view.svg')]
		private static const Symbol_reset_view:Class;
		
		[Embed(source='../../../../lib/symbols/slower.svg')]
		private static const Symbol_slower:Class;
		
		[Embed(source='../../../../lib/symbols/snapshot.svg')]
		private static const Symbol_snapshot:Class;
		
		[Embed(source='../../../../lib/symbols/step.svg')]
		private static const Symbol_step:Class;
		
		[Embed(source='../../../../lib/symbols/stop.svg')]
		private static const Symbol_stop:Class;
		
		[Embed(source='../../../../lib/symbols/tdsi.svg')]
		private static const Symbol_tdsi:Class;
		
		[Embed(source='../../../../lib/symbols/ww_about.svg')]
		private static const Symbol_ww_about:Class;
		
		[Embed(source='../../../../lib/symbols/zoom-in.svg')]
		private static const Symbol_zoom_in:Class;
		
		[Embed(source='../../../../lib/symbols/zoom-out.svg')]
		private static const Symbol_zoom_out:Class;
		
		public var library:Object = {
			Announcer:Symbol_announcer,
			CC_BY_NC:Symbol_cc_by_nc,
			EraserCursorDown:Symbol_eraser_cursor_down,
			EraserCursorUp:Symbol_eraser_cursor_up,
			EraserTool:Symbol_eraser_tool,
			Faster:Symbol_faster,
			File:Symbol_file,
			Gallery:Symbol_gallery,
			GoogleProject:Symbol_google_project,
			HandCursorDown:Symbol_hand_cursor_down,
			HandCursorUp:Symbol_hand_cursor_up,
			HandTool:Symbol_hand_tool,
			Heatmap:Symbol_heatmap,
			Help:Symbol_help,
			Overdrive:Symbol_overdrive,
			PlayPause:Symbol_play_pause,
			ResetView:Symbol_reset_view,
			Slower:Symbol_slower,
			Snapshot:Symbol_snapshot,
			Step:Symbol_step,
			Stop:Symbol_stop,
			TDSI:Symbol_tdsi,
			WWAbout:Symbol_ww_about,
			ZoomIn:Symbol_zoom_in,
			ZoomOut:Symbol_zoom_out
		};
		
		[Embed(source='../../../../lib/fru_med_reg/FRUCM___.TTF', fontName="Frucade Medium", mimeType="application/x-font-truetype")]
		private static const FrucadeMedium:Class;

		public var fonts:Object = {
			FrucadeMedium:FrucadeMedium
		};
		
		[Embed(source='../../../../lib/web/readme.html', mimeType="application/octet-stream")]
		private static const README:Class;
		
		public var files:Object = {
			README:README
		};
		
		public function Assets():void {
			for (var prop:String in fonts) { Font.registerFont(fonts[prop]); }
		}
	}
}