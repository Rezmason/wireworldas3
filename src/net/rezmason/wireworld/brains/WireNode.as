﻿/*** Wireworld Player by Jeremy Sachs. August 21, 2010** Feel free to distribute the source, just try not to hand it off to some douchebag.* Keep this header here.** Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.*/package net.rezmason.wireworld.brains {		// WireNodes represent individual cells in the LinkedListModel.	// They're lightweight, stupid, and left wide open.		internal final class WireNode {				//---------------------------------------		// INTERNAL VARIABLES		//---------------------------------------				internal var isWire:Boolean = false;		internal var x:int, y:int, firstState:int;		internal var next:WireNode;		internal var neighbors:Vector.<WireNode> = new Vector.<WireNode>(8, false);		internal var timesLit:int = 0;		internal var taps:int = 0;				//---------------------------------------		// CONSTRUCTOR		//---------------------------------------		public function WireNode(__x:int = 0, __y:int = 0, __firstState:int = 0):void {			x = __x;			y = __y;			firstState = __firstState;		}	}}