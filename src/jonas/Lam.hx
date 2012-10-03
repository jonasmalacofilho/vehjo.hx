package jonas;

/* Lambda (outputing Array) + enhancements
   Copyright 2012 Jonas Malaco Filho
   Licensed under the MIT license. Check LICENSE.txt for more information. */
class Lam {

	public static inline function map<A,B>( it: Iterable<A>, f: A -> B ): Array<B> {
		var y = [];
		for ( x in it )
			y.push( f( x ) );
		return y;
	}

	public static inline function mapi<A,B>( it: Iterable<A>, f: Int -> A -> B ): Array<B> {
		var y = [];
		var i = 0;
		for ( x in it )
			y.push( f( i++, x ) );
		return y;
	}

	public static inline function filter<A>( it: Iterable<A>, f: A -> Bool ): Array<A> {
		var y = [];
		for ( x in it )
			if ( f( x ) )
				y.push( x );
		return y;
	}

	public static inline function fold<A,B>( it: Iterable<A>, f: A -> B -> B, first: B ): B {
		for ( x in it )
			first = f( x, first );
		return first;
	}

	// one use only iterable
	public static inline function it<A>( itr: Iterator<A> ): Iterable<A> {
		return { iterator: function () return itr };
	}

	public static inline function array<A>( it: Iterable<A> ): Array<A> {
		var y = [];
		for ( x in it )
			y.push( x );
		return y;
	}

	public static inline function count<A>( it: Iterable<A> ): Int {
		return Lam.fold( it, function ( x, f ) return f+1, 0 );
	}

}