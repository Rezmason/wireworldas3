/**
* Wireworld Player by Jeremy Sachs. July 25, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
package net.rezmason.wireworld {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.Font;
	
	// This class is compiled separately into the assets.swf in the lib directory.
	
	public final class Assets extends Sprite {
		
		[Embed(source='../../../../lib/symbols/announcer.svg')]
		private static const Symbol_announcer:Class;
		
		[Embed(source='../../../../lib/symbols/cc_by-nc.svg')]
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
		
		[Embed(source='../../../../lib/symbols/ww_about.svg')]
		private static const Symbol_ww_about:Class;
		
		[Embed(source='../../../../lib/symbols/zoom-in.svg')]
		private static const Symbol_zoom_in:Class;
		
		[Embed(source='../../../../lib/symbols/zoom-out.svg')]
		private static const Symbol_zoom_out:Class;
		
		private var library:Object = {
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
			WWAbout:Symbol_ww_about,
			ZoomIn:Symbol_zoom_in,
			ZoomOut:Symbol_zoom_out
		};
		
		[Embed(source='../../../../lib/fru_med_reg/FRUCM___.TTF', fontName="Frucade Medium", mimeType="application/x-font-truetype")]
		private static const FrucadeMedium:Class;
		
		/*
		[Embed(source='../../../../lib/mplus-TESTFLIGHT-031/mplus-2p-regular.ttf', fontName="M Plus", fontWeight="Regular", mimeType="application/x-font-truetype")]
		private static const MPlusRegular:Class;
		
		[Embed(source='../../../../lib/mplus-TESTFLIGHT-031/mplus-2p-regular.ttf', fontName="M Plus", fontWeight="Bold", mimeType="application/x-font-truetype")]
		private static const MPlusBold:Class;
		*/
		
		private var fonts:Object = {
			//MPlusRegular:MPlusRegular,
			//MPlusBold:MPlusBold,
			pixel:FrucadeMedium
		};
		
		[Embed(source='../../../../lib/web/readme.html', mimeType="application/octet-stream")]
		private static const README:Class;
		
		[Embed(source='../../../../lib/web/about.html', mimeType="application/octet-stream")]
		private static const ABOUT:Class;
		
		[Embed(source='../../../../lib/web/styles.css', mimeType="application/octet-stream")]
		private static const STYLESHEET:Class;
		
		private var files:Object = {
			README:README,
			ABOUT:ABOUT,
			STYLESHEET:STYLESHEET
		};
		
		public var assets:Object = {
			library:library,
			fonts:fonts,
			files:files
		}
		
		public function Assets():void {
			for (var prop:String in fonts) { Font.registerFont(fonts[prop]); }
		}
	}
}