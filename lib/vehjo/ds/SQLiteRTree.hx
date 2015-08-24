package vehjo.ds;

using vehjo.LazyLambda;

// compilter was getting lost with empty: Void -> Bool and empty: vehjo.Maybe<A>
private enum Maybe<T> {
	Empty;
	Just( v: T );
}

class SQLiteRTree<T> implements RTree<T> {
	
	public var length( default, null ): Int;
	
	var cnx: sys.db.Connection;
	var objs: Array<Maybe<T>>;

	public function new() {
		cnx = sys.db.Sqlite.open( ':memory:' );
		cnx.request( 'CREATE VIRTUAL TABLE tree USING rtree ( id, minX, maxX, minY, maxY )' );
		cnx.request( 'PRAGMA journal_mode=OFF' );
		cnx.request( 'PRAGMA synchronous=OFF' );
		objs = [];
		length = 0;
	}

	public function search( xMin: Float, yMin: Float, width: Float, height: Float ): Iterator<T> {
		var res = cnx.request( Std.format( 'SELECT id FROM tree WHERE minX<=${width+xMin} AND minY<=${height+yMin} AND maxX>=${xMin} AND maxY>=${yMin}' ) ).lazy();
		return res.map( switch ( objs[$x.id] ) { case Just( x ): x; default: throw $x.id; } ).iterator();
	}

	public function iterator(): Iterator<T> {
		return objs.map( switch ( $x ) { case Just( x ): x; default: throw $x; } ).iterator();
	}

	public function insertPoint( x: Float, y: Float, object: T ): Void {
		var curId = objs.length;
		objs[curId] = Just( object );
		cnx.request( Std.format( 'INSERT INTO tree ( id, minX, maxX, minY, maxY ) VALUES ( $curId, $x, $x, $y, $y )' ) );
		length++;
		vehjo.macro.Error.throwIf( cnx.request( 'SELECT count( 1 ) cnt FROM tree' ).next().cnt != length );
	}

	public function insertRectangle( x: Float, y: Float, width: Float, height: Float, object: T ) : Void {
		var curId = objs.length;
		objs[curId] = Just( object );
		cnx.request( Std.format( 'INSERT INTO tree ( id, minX, maxX, minY, maxY ) VALUES ( $curId, $x, ${width+x}, ${y}, ${height+y} )' ) );
		length++;
		vehjo.macro.Error.throwIf( cnx.request( 'SELECT count( 1 ) cnt FROM tree' ).next().cnt != length );
	}

	public function removePoint( x: Float, y: Float, ?object: Null<T> ): Int {
		var res = cnx.request( Std.format( 'SELECT id FROM tree WHERE minX<=${x} AND minY<=${y} AND maxX>=${x} AND maxY>=${y}' ) ).lazy();
		var cnt = 0;
		for ( id in res.map( $x.id ) )
			if ( object == null || Type.enumEq( objs[id], Just( object ) ) ) {
				objs[id] = Empty;
				cnx.request( Std.format( 'DELETE FROM tree WHERE id=$id' ) );
				length--;
				cnt++;
			}
		return cnt;
	}

	public function removeRectangle( x: Float, y: Float, width: Float, height: Float, ?object: T ): Int {
		var res = cnx.request( Std.format( 'SELECT id FROM tree WHERE minX<=${width+x} AND minY<=${height+y} AND maxX>=${x} AND maxY>=${y}' ) ).lazy();
		var cnt = 0;
		for ( id in res.map( $x.id ) )
			if ( object == null || Type.enumEq( objs[id], Just( object ) ) ) {
				objs[id] = Empty;
				cnx.request( Std.format( 'DELETE FROM tree WHERE id=$id' ) );
				length--;
				cnt++;
			}
		return cnt;
	}

	public function removeObject( object: T ): Int {
		var cnt = 0;
		for ( id in 0...objs.length )
			if ( Type.enumEq( objs[id], Just( object ) ) ) {
				objs[id] = Empty;
				cnx.request( Std.format( 'DELETE FROM tree WHERE id=$id' ) );
				length--;
				cnt++;
			}
		return cnt;
	}

}
