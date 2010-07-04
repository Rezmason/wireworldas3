package net.rezmason.wireworld.brains {
	
	internal final class TreeCalcScope {
		internal var node:TreeNode, state:int, type:int;
		internal var mult:Number = 0;
		internal var table:Vector.<TreeNode> = new Vector.<TreeNode>(13, true);
		public function TreeCalcScope():void {}
	}
}