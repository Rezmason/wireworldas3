/**
* Wireworld Player by Jeremy Sachs. July 25, 2010
*
* Feel free to distribute the source, just try not to hand it off to some douchebag.
* Keep this header here.
*
* Please contact jeremysachs@rezmason.net prior to distributing modified versions of this class.
*/
import net.rezmason.wireworld.brains.HaXeModel;
import net.rezmason.wireworld.brains.FirstHaXeModel;
import net.rezmason.wireworld.brains.LinkedListHaXeModel;
import net.rezmason.wireworld.IModel;

class HaXeModelMain {
	var model:IModel;
	
	public function new() {
		model = new FirstHaXeModel();
		model = new LinkedListHaXeModel();
		model = new HaXeModel();
	}
	
	public static function main():Void { var m:HaXeModelMain = new HaXeModelMain(); }
}