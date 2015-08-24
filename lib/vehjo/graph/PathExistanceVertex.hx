package vehjo.graph;

class PathExistanceVertex extends Vertex {
	public var parent : PathExistanceVertex;
	override public function toString()
		return '$vi(parent=${( null != parent ? parent.vi : null )})';
}