package net.rezmason.wireworld {
	
	import net.rezmason.wireworld.TreeNode;	
	
	internal final class TreeCalcScope {
		public var node:TreeNode, state:int, type:int;
		public var mult:Number = 0;
		public var table:Vector.<TreeNode> = new Vector.<TreeNode>(13, true);
		public function TreeCalcScope():void {}
	}
}