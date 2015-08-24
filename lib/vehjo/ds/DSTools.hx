package vehjo.ds;

/**
 * DSTools
 */
class DSTools {

	public static function remove_duplicates_by_hash<A>( it : Iterable<A>, hash : A -> String ) : Hash<A> {
		var table = new Hash();
		for ( x in it ) {
			var h = hash( x );
			if ( !table.exists( h ) )
				table.set( h, x );
		}
		return table;
	}
	
	public static function remove_duplicates_by_int_hash<A>( it : Iterable<A>, hash : A -> Int ) : IntHash<A> {
		var table = new IntHash();
		for ( x in it ) {
			var h = hash( x );
			if ( !table.exists( h ) )
				table.set( h, x );
		}
		return table;
	}
	
	public static function remove_duplicates<A>( it : Iterable<A>, equal : A -> A -> Bool ) : List<A> {
		var li = new List();
		for ( x in it ) {
			if ( !Lambda.exists( li, callback( equal, x ) ) )
				li.add( x );
		}
		return li;
	}
	
}
