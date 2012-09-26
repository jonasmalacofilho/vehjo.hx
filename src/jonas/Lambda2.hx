package jonas;

class Lambda2 {

	public static function map<A,B>( it: Iterable<A>, f: A -> B ): Array<B> {
		var y = [];
		for ( x in it )
			y.push( f( x ) );
		return y;
	}

	public static function mapi<A,B>( it: Iterable<A>, f: Int -> A -> B ): Array<B> {
		var y = [];
		var i = 0;
		for ( x in it )
			y.push( f( i++, x ) );
		return y;
	}

	public static function filter<A>( it: Iterable<A>, f: A -> Bool ): Array<A> {
		var y = [];
		for ( x in it )
			if ( f( x ) )
				y.push( x );
		return y;
	}

}