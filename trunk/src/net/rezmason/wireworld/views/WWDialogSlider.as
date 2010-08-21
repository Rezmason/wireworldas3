/**
* Wireworld Player by Jeremy Sachs. August 21, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/

package net.rezmason.wireworld.views {
	internal final class WWDialogSlider extends WWSlider {
		public function WWDialogSlider(__label:String, __width:Number = 100, __height:Number = 10, __thumbRatio:Number = 0):void {
			super(__label, __width, __height, __thumbRatio);
			backing.transform.colorTransform = WWGUIPalette.DIALOG_BACK_CT;
		}
	}
}