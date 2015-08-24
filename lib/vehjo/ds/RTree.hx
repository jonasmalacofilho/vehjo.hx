package vehjo.ds;

interface RTree<T> {
	
	public var length( default, null ): Int;

	public function search( xMin : Float, yMin : Float, width : Float, height : Float ) : Iterator<T>;
	public function iterator() : Iterator<T>;
	
	public function insertPoint( x : Float, y : Float, object : T ) : Void;
	public function insertRectangle( x : Float, y : Float, width : Float, height : Float, object : T ) : Void;
	public function removePoint( x : Float, y : Float, ?object : Null<T> ) : Int;
	public function removeRectangle( x : Float, y : Float, width : Float, height : Float, ?object : T ) : Int;
	public function removeObject( object : T ) : Int;

}
