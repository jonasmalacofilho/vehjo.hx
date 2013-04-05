package jonas.graph;

class SPVertex extends PathExistanceVertex {
	public var cost : Float;
	override public function toString()
		return '$vi(parent=${( null != parent ? parent.vi : null )}, cost=$cost})';
}