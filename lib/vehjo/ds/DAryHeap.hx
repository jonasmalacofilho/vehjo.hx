package vehjo.ds;

/**
	D-arity heaps
**/
class DAryHeap<T> {
	
	static inline var DEFAULT_ARITY = 4;
	
	/** Structure **/
	
	public var arity( default, null ) : Int;
	public var length( default, null ) : Int;
	var h : Array<T>; // [ 1, 11, 12, 13, 14, 111, 112, 113, 114, 121, 122, 123, 124, ... ]
	
	/** Rebindble functions **/
	
	// true for position(a) <= position(b), or a >= b in a max-heap
	public dynamic function predicate( a : T, b : T ) : Bool {
		throw 'No predicate function set; expects true for position(a) <= position(b), or a >= b in a max-heap';
		return false;
	}
	
	public dynamic function update_index( e : T, i : Int ) : Void { }

	/** Public API **/
	
	public function new( arity = DEFAULT_ARITY, reserve = 0 ) {
		if ( 2 > arity )
			throw 'Heap arity must be >= 2';
		this.arity = arity;
		h = new Array();
		length = 0;
		this.reserve( reserve );
	}
	
	public function build( a : Iterable<T> ) : Void {
		if ( 0 != length )
			throw 'Heap is not empty, cannot build from iterable';
		h = Lambda.array( a );
		length = h.length;
		heapify();
	}
	
	public static function from_array<A>( a : Array<A>, predicate : A -> A -> Bool, ?update_index : A -> Int -> Void, arity = DEFAULT_ARITY ) : DAryHeap<A> {
		var h = new DAryHeap( arity, 0 );
		h.predicate = predicate;
		if ( null != update_index ) h.update_index = update_index;
		h.build( a );
		return h;
	}
	
	public function reserve( s : Int ) : Void {
		if ( 0 < s && length < s )
			h[s - 1] = null;
	}
	
	public inline function empty() : Bool {
		return 0 == length;
	}
	
	public inline function not_empty() : Bool {
		return 0 < length;
	}
	
	public inline function put( e : T ) : Void {
		insert( length, e );
		fix_up( length++ );
	}
	
	public inline function get() : Null<T> {
		if ( not_empty() ) {
			exchange( 0, --length );
			fix_down( 0 );
			return h[length];
		}
		else
			return null;
	}
	
	public inline function update( i : Int ) : Void {
		fix_up( i );
		fix_down( i );
	}
	
	public function toString() : String {
		return '{ ' + h.slice(0, length).join( ', ' ) + ' }';
	}
	
	public function iterator() : Iterator<T> {
		return h.slice(0, length).iterator();
	}
	
	public function copy() : DAryHeap<T> {
		var g = new DAryHeap( arity, length );
		g.h = h.copy();
		g.length = length;
		g.predicate = predicate;
		g.update_index = update_index;
		return g;
	}
	
	public function join( sep : String ) {
		var buf = new StringBuf();
		var first = true;
		for ( e in iterator() ) {
			if ( first )
				first = false;
			else
				buf.add( sep );
			buf.add( e );
		}
		return buf.toString();
	}
	
	/** Helper API **/
	
	inline function insert( i : Int, e : T ) : Void {
		h[i] = e;
		update_index( e, i );
	}
	
	// 1 <= n <= arity
	inline function child( i : Int, n : Int ) : Int {
		return arity * i + n;
	}
	
	inline function parent( i : Int ) : Int {
		return Math.floor( ( i - 1 ) / arity );
	}
	
	inline function exchange( i : Int, j : Int ) : Void {
		var t = h[i];
		insert( i, h[j] );
		insert( j, t );
	}
	
	inline function fix_up( i : Int ) : Void {
		var j;
		while ( 0 < i && !predicate( h[ j = parent( i ) ], h[i] ) ) {
			exchange( i, j );
			i = j;
		}
	}
	
	inline function fix_down( i : Int ) : Void {
		var j;
		while ( length > ( j = child( i, 1 ) ) ) {
			var a = 2;
			var k;
			while ( arity >= a && length > ( k = child( i, a ) ) ) {
				if ( predicate( h[k], h[j] ) )
					j = k;
				a++;
			}
			if ( predicate( h[i], h[j] ) )
				break;
			exchange( i, j );
			i = j;
		}
	}
	
	function heapify() : Void {
		var s = Math.floor( parent( length - 1 ) );
		for ( i in 0...length )
			update_index( h[i], i );
		while ( 0 <= s )
			fix_down( s-- );
	}
	
}

class BinaryHeap<T> extends DAryHeap<T> {
	
	public function new( reserve=0 ) {
		super( 2, reserve );
	}
	
}
