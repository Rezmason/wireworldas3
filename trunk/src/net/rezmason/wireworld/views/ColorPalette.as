﻿/*** Wireworld Player by Jeremy Sachs. June 22, 2010** Feel free to distribute the source, just try not to hand it off to some douchebag.* Keep this header here.** Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.*/package net.rezmason.wireworld.views {		// ColorPalettes store colors. Do I have to explain everything to you?		public final class ColorPalette {				public var dead:int, wire:int, head:int, tail:int;				//---------------------------------------		// PRIVATE VARIABLES		//---------------------------------------		private static const DEFAULT_PALETTE:ColorPalette = new ColorPalette(0x000000, 0x505050, 0xFFEE00, 0xFF8800);		private static const CLASSIC_PALETTE:ColorPalette = new ColorPalette(0x000000, 0xFF8800, 0xFFFFFF, 0x2C82F6);		private static const MINTY_PALETTE:ColorPalette = new ColorPalette(0x000000, 0x505050, 0x80FF80, 0x00C000);		private static const BUBBLE_GUM_PALETTE:ColorPalette = new ColorPalette(0x000000, 0x4C4C4C, 0xFF4CFF, 0xFF4C4C);		private static const BRASS_PALETTE:ColorPalette = new ColorPalette(0x101000, 0x404020, 0xFFFF20, 0x808020);		private static const FREON_PALETTE:ColorPalette = new ColorPalette(0x000000, 0x4C4C4C, 0x4CFFFF, 0x4C4CFF);		private static const GPU_PALETTE:ColorPalette = new ColorPalette(0x000000, 0xFF0000, 0x00FF00, 0x0000FF);		private static const CURRANT_PALETTE:ColorPalette = new ColorPalette(0x000000, 0x300050, 0xFFFF00, 0x8000A0);		private static const NIGHT_PALETTE:ColorPalette = new ColorPalette(0x000040, 0x4040A0, 0xFFFFDD, 0x8080DD);		private static const GLEAM_PALETTE:ColorPalette = new ColorPalette(0x000000, 0xFFFF00, 0xFFFFFF, 0xFFFFF80); 				public function ColorPalette(__dead:int = 0, __wire:int = 0, __head:int = 0, __tail:int = 0):void {			dead = __dead, wire = __wire, head = __head, tail = __tail;		}				private function clone():ColorPalette {			return new ColorPalette(dead, wire, head, tail);		}				public static function get appropriatePalette():ColorPalette {			var _colorPalette:ColorPalette;			switch (true) {				case BRAIN::CONVOLUTION_FILTER: _colorPalette = BUBBLE_GUM_PALETTE.clone(); break;				case BRAIN::PIXEL_BENDER: _colorPalette = BRASS_PALETTE.clone(); break;				case BRAIN::VECTOR: _colorPalette = DEFAULT_PALETTE.clone(); break;				case BRAIN::LINKED_LIST: _colorPalette = CLASSIC_PALETTE.clone(); break;				case BRAIN::TDSI: _colorPalette = FREON_PALETTE.clone(); break;				case BRAIN::STUPID: _colorPalette = CURRANT_PALETTE.clone(); break;				case BRAIN::STANDARD: default: _colorPalette = MINTY_PALETTE.clone(); break;				case BRAIN::BYTES: _colorPalette = NIGHT_PALETTE.clone(); break;			}						return _colorPalette || DEFAULT_PALETTE.clone();		}	}	}