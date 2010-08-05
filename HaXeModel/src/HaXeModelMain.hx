import net.rezmason.wireworld.HaXeModel;
import net.rezmason.wireworld.IModel;

class HaXeModelMain {
	var model:IModel;
	
	public function new() {
		model = new HaXeModel();
	}
	
	public static function main():Void { var m:HaXeModelMain = new HaXeModelMain(); }
}