package jonas.ds;

/*
 * Data structure tools
 * Copyright (c) 2012 Jonas Malaco Filho
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

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
