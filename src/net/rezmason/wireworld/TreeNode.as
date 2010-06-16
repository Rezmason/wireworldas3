package net.rezmason.wireworld {
	public final class TreeNode {
		public var cold:Boolean = false, address:uint = 0;
		public var nw:TreeNode, ne:TreeNode, sw:TreeNode, se:TreeNode;
		
		public var hopNW:uint, hopNE:uint, hopSE:uint, hopSW:uint;
		public var skipNW:uint, skipNE:uint, skipSE:uint, skipSW:uint;
		
		public var lev:int = 0, hopLev:int;
		public function TreeNode():void {}
	}
}