package net.rezmason.wireworld.brains {
	public final class TreeNode {
		internal var cold:Boolean = false, address:uint = 0;
		internal var nw:TreeNode, ne:TreeNode, sw:TreeNode, se:TreeNode;
		
		internal var hopNW:uint, hopNE:uint, hopSE:uint, hopSW:uint;
		internal var skipNW:uint, skipNE:uint, skipSE:uint, skipSW:uint;
		
		internal var lev:int = 0, hopLev:int;
		public function TreeNode():void {}
	}
}