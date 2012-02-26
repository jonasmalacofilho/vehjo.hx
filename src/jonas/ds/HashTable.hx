package jonas.ds;

import jonas.MathExtension;

/*
 * Open addressing hash table
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
 * HashTable typedef (so that implementations became interchangeable
 */
typedef HashTable<K, D> = {
	public function exists( k : K ) : Bool;
	public function get( k : K ) : Null<D>;
	public function set( k : K, d : D ) : Void;
	public function remove( k : K ) : Bool;
	public function iterator() : Iterator<D>;
	public function keys() : Iterator<K>;
}

/**
 * String keys hash table item
 */
private class StringHashObject<D> {
	public var k : String;
	public var d : D;
	public var h : Int;
	public inline function new( k, d, h ) {
		this.k = k;
		this.d = d;
		this.h = h;
	}
}

/**
 * String keys hash table
 * Open addressing, linear probing, randomized hash function, hash cache
 */
class StringHashTable<D> {
	
	/** INTERNALS **/
	
	// table
	var t : Array<StringHashObject<D>>;
	var r : Int;
	var m : Int; // table size, m = 2^r
	var m_ : Int; // m - 1, x mod m = x & ( m - 1 )
	
	// word size
	static inline var w = #if neko 31 #else 32 #end;
	
	// h( '' );
	var H0 : Int;
	
	// odd integer in the range 2^(w-1) < A < 2^w; should not be too close to 2^(w-1) or 2^w
	var A : Int;
	
	// hash function (horner + multiplicative + simplification)
	inline function hash( k : String ) : Int {
		var h = H0;
		for ( i in 0...k.length )
			h = h * A + k.charCodeAt( i );
		return h;
	}
	
	// hash function configuration (randomized)
	function set_hash_function() : Void {
		// 2^(w-1) < A < 2^w, odd A, not too close to 2^(w-1) or 2^w
		A = 1;
		for ( i in 0...( w - 1 ) )
			A = ( A << 1 ) | Std.random( 2 );
		A |= 1;
		// 0 < H0 < A, odd H0
		H0 = Std.random( A & MathExtension.INT_MAX ) | 1;
	}
	
	// x mod m
	inline function mod( x : Int ) : Int {
		return x & m_;
	}
	
	// pow( 2, x )
	static inline function pow2( x : Int ) : Int {
		return 1 << x;
	}
	
	// probing (linear)
	inline function probe( i : Int ) : Int { 
		return mod( i + 1 );
	}
	
	// table allocation
	function alloc( r : Int ) : Void {
		this.r = r;
		m = pow2( r );
		m_ = m - 1;
		length = 0;
		t = [];
		t[ m_ ] = null;
	}
	
	// max & min load factors
	static inline var MAX_LOAD_FACTOR = 1 / 2;
	static inline var MIN_LOAD_FACTOR = 1 / 8;
	
	// needed table size
	static function needed_r( x : Int ) : Int {
		if ( 0 > x )
			throw 'Desired size must be positive integer';
		var r = Math.floor( MathExtension.logb( x / MAX_LOAD_FACTOR, 2. ) ); // m = 2^r, m = 2 * ds
		if ( x > MathExtension.pow2( r - 1 ) ) // ds > (m=2^r)/2
			r++;
		return r;
	}
	
	// default storage capacity
	inline static var INIT_RESERVE = 4;
	
	// init
	function init( r : Int ) : Void {
		alloc( r );
	}
	
	// auto size: grow
	function auto_grow() : Void {
		if ( MAX_LOAD_FACTOR < load_factor() )
			resize_r( r + 1 );
	}
	
	// auto size: shrink
	function auto_shrink() : Void {
		if ( MIN_LOAD_FACTOR > load_factor() )
			resize_r( r - 1 );
	}
	
	// resize
	function resize_r( r : Int ) : Void {
		if ( 0 > r )
			return;
		var oldt = t;
		var oldm = m;
		init( r );
		
		// reinsertion
		var x;
		for ( i in 0...oldm )
			if ( null != ( x = oldt[i] ) ) {
				var j = mod( x.h );
				while ( null != t[j] )
					j = probe( j );
				t[j] = x;
				oldt[i] = null;
				length++;
			}
				
	}
	
	
	/** HASH TABLE API **/
	
	// table size
	public var length( default, null ) : Int;
	
	// constructor
	public function new( ?reserve : Int = INIT_RESERVE ) {
		set_hash_function();
		init( needed_r( reserve ) );
	}
	
	public function exists( k : String ) : Bool {
		if ( null == k )
			throw 'Key must not be null';
		var i = mod( hash( k ) );
		var x;
		while ( null != ( x = t[i] ) )
			if ( x.k == k )
				return true;
			else
				i = probe( i );
		return false;
	}
	
	public function get( k : String ) : Null<D> {
		if ( null == k )
			throw 'Key must not be null';
		var i = mod( hash( k ) );
		var x;
		while ( null != ( x = t[i] ) )
			if ( x.k == k )
				return x.d;
			else
				i = probe( i );
		return null;
	}
	
	public function set( k : String, d : D ) : Void {
		if ( null == k )
			throw 'Key must not be null';
		var h = hash( k );
		var i = mod( h );
		var x;
		while ( null != ( x = t[i] ) )
			if ( x.k == k ) {
				length--;
				break;
			}
			else
				i = probe( i );
		t[i] = new StringHashObject( k, d, h );
		length++;
		auto_grow();
	}
	
	public function remove( k : String ) : Bool {
		if ( null == k )
			throw 'Key must not be null';
		var i = mod( hash( k ) );
		var x;
		while ( null != ( x = t[i] ) )
			if ( x.k == k ) {
				length--;
				t[i] = null;
				while ( null != ( x = t[i = probe( i ) ] ) ) {
					var j;
					if ( ( j = mod( x.h ) ) != i ) {
						while ( null != t[j] )
							j = probe( j );
						t[j] = x;
						t[i] = null;
					}
				}
				auto_shrink();
				return true;
			}
			else
				i = probe( i );
		return false;
	}
	
	public function iterator() : Iterator<D> {
		var i = 0;
		return {
			hasNext : function() {
				for ( j in i...m )
					if ( null != t[j] ) {
						i = j;
						return true;
					}
				return false;
			},
			next : function() {
				return t[i++].d;
			}
		};
	}
	
	public function keys() : Iterator<String> {
		var i = 0;
		return {
			hasNext : function() {
				for ( j in i...m )
					if ( null != t[j] ) {
						i = j;
						return true;
					}
				return false;
			},
			next : function() {
				return t[i++].k;
			}
		};
	}
	
	
	/** STATS API **/
	
	
	// load factor = a = length / m
	public inline function load_factor() : Float { return length / m; }
	
	// expected number of probes on hits (linear probing, Sedgewick)
	public function expected_probes_hits() : Float { return .5 * ( 1. + 1. / ( 1. - load_factor() ) ); }
	
	// expected number of probes on misses (linear probing, Sedgewick)
	public function expected_probes_misses() : Float { return .5 * ( 1. + 1. / Math.pow( 1. - load_factor(), 2. ) ); }
	
	// on hits probe stats
	public function probes_hits() : { avg : Float, max : Int } {
		var total_probes = 0.;
		var max_probes = 0;
		for ( i in 0...m ) {
			var x = t[i];
			if ( null != x ) {
				var j = mod( x.h );
				var y;
				var p = 0;
				while ( null != ( y = t[j] ) )
					if ( y.k == x.k )
						break;
					else {
						j = probe( j );
						p++;
					}
				total_probes += p + 1;
				if ( p > max_probes )
					max_probes = p;
			}
		}
		return { avg : total_probes / length, max : max_probes };
	}
	
	// on misses probe stats
	public function probes_misses() : { avg : Float, max : Int } {
		var total_probes = 0.;
		var max_probes = 0;
		for ( i in 0...m ) {
			var j = i;
			var p = 0;
			while ( null != t[j] ) {
				j = probe( j );
				p++;
			}
			total_probes += p + 1;
			if ( p > max_probes )
				max_probes = p;
		}
		return { avg : total_probes / m, max : max_probes };
	}
	
	// all stats
	public function stats() {
		var hits = probes_hits();
		var misses = probes_misses();
		return {
			n : length,
			m : m,
			alpha : load_factor(),
			ExpProbesHits : expected_probes_hits(),
			AvgProbesHits : hits.avg,
			MaxProbesHits : hits.max,
			ExpProbesMisses : expected_probes_misses(),
			AvgProbesMisses : misses.avg,
			MaxProbesMisses : misses.max
		};
	}
	
}

/**
 * Integer keys hash table item
 */
private class IntHashObject<D> {
	public var k : Int;
	public var d : D;
	public inline function new( k, d ) {
		this.k = k;
		this.d = d;
	}
}

/**
 * Integer keys hash table
 * Open addressing, linear probing, randomized hash function (redefined at resizing)
 */
class IntHashTable<D> {
	
	/** INTERNALS **/
	
	// table
	var t : Array<IntHashObject<D>>;
	var r : Int;
	var m : Int; // table size, m = 2^r
	var m_ : Int; // m - 1, x mod m = x & ( m - 1 )
	
	// word size
	static inline var w = #if neko 31 #else 32 #end;
	
	// odd integer in the range 2^(w-1) < A < 2^w; should not be too close to 2^(w-1) or 2^w
	var A : Int;
	
	// shift
	var shift : Int;
	
	// hash function (horner + multiplicative + simplification)
	inline function hash( k : Int ) : Int {
		return ( A * k ) >> shift;
	}
	
	// hash function configuration (randomized)
	function set_hash_function() : Void {
		// 2^(w-1) < A < 2^w, odd A, not too close to 2^(w-1) or 2^w
		A = 1;
		for ( i in 0...( w - 1 ) )
			A = ( A << 1 ) | Std.random( 2 );
		A |= 1;
		shift = w - r;
	}
	
	// x mod m
	inline function mod( x : Int ) : Int {
		return x & m_;
	}
	
	// pow( 2, x )
	static inline function pow2( x : Int ) : Int {
		return 1 << x;
	}
	
	// probing (linear)
	inline function probe( i : Int ) : Int { 
		return mod( i + 1 );
	}
	
	// table allocation
	function alloc( r : Int ) : Void {
		this.r = r;
		m = pow2( r );
		m_ = m - 1;
		length = 0;
		t = [];
		t[ m_ ] = null;
	}
	
	// max & min load factors
	static inline var MAX_LOAD_FACTOR = 1 / 2;
	static inline var MIN_LOAD_FACTOR = 1 / 8;
	
	// needed table size
	static function needed_r( x : Int ) : Int {
		if ( 0 > x )
			throw 'Desired size must be positive integer';
		var r = Math.floor( MathExtension.logb( x / MAX_LOAD_FACTOR, 2. ) ); // m = 2^r, m = 2 * ds
		if ( x > MathExtension.pow2( r - 1 ) ) // ds > (m=2^r)/2
			r++;
		return r;
	}
	
	// default storage capacity
	inline static var INIT_RESERVE = 4;
	
	// init
	function init( r : Int ) : Void {
		alloc( r );
		set_hash_function();
	}
	
	// auto size: grow
	function auto_grow() : Void {
		if ( MAX_LOAD_FACTOR < load_factor() )
			resize_r( r + 1 );
	}
	
	// auto size: shrink
	function auto_shrink() : Void {
		if ( MIN_LOAD_FACTOR > load_factor() )
			resize_r( r - 1 );
	}
	
	// resize
	function resize_r( r : Int ) : Void {
		if ( 0 > r )
			return;
		var oldt = t;
		var oldm = m;
		init( r );
		
		// reinsertion
		var x;
		for ( i in 0...oldm )
			if ( null != ( x = oldt[i] ) ) {
				var j = mod( hash( x.k ) );
				while ( null != t[j] )
					j = probe( j );
				t[j] = x;
				oldt[i] = null;
				length++;
			}
				
	}
	
	
	/** HASH TABLE API **/
	
	// table size
	public var length( default, null ) : Int;
	
	// constructor
	public function new( ?reserve : Int = INIT_RESERVE ) {
		init( needed_r( reserve ) );
	}
	
	public function exists( k : Int ) : Bool {
		if ( null == k )
			throw 'Key must not be null';
		var i = mod( hash( k ) );
		var x;
		while ( null != ( x = t[i] ) )
			if ( x.k == k )
				return true;
			else
				i = probe( i );
		return false;
	}
	
	public function get( k : Int ) : Null<D> {
		if ( null == k )
			throw 'Key must not be null';
		var i = mod( hash( k ) );
		var x;
		while ( null != ( x = t[i] ) )
			if ( x.k == k )
				return x.d;
			else
				i = probe( i );
		return null;
	}
	
	public function set( k : Int, d : D ) : Void {
		if ( null == k )
			throw 'Key must not be null';
		var i = mod( hash( k ) );
		var x;
		while ( null != ( x = t[i] ) )
			if ( x.k == k ) {
				length--;
				break;
			}
			else
				i = probe( i );
		t[i] = new IntHashObject( k, d );
		length++;
		auto_grow();
	}
	
	public function remove( k : Int ) : Bool {
		if ( null == k )
			throw 'Key must not be null';
		var i = mod( hash( k ) );
		var x;
		while ( null != ( x = t[i] ) )
			if ( x.k == k ) {
				length--;
				t[i] = null;
				while ( null != ( x = t[i = probe( i ) ] ) ) {
					var j;
					if ( ( j = mod( hash( x.k ) ) ) != i ) {
						while ( null != t[j] )
							j = probe( j );
						t[j] = x;
						t[i] = null;
					}
				}
				auto_shrink();
				return true;
			}
			else
				i = probe( i );
		return false;
	}
	
	public function iterator() : Iterator<D> {
		var i = 0;
		return {
			hasNext : function() {
				for ( j in i...m )
					if ( null != t[j] ) {
						i = j;
						return true;
					}
				return false;
			},
			next : function() {
				return t[i++].d;
			}
		};
	}
	
	public function keys() : Iterator<Int> {
		var i = 0;
		return {
			hasNext : function() {
				for ( j in i...m )
					if ( null != t[j] ) {
						i = j;
						return true;
					}
				return false;
			},
			next : function() {
				return t[i++].k;
			}
		};
	}
	
	
	/** STATS API **/
	
	
	// load factor = a = length / m
	public inline function load_factor() : Float { return length / m; }
	
	// expected number of probes on hits (linear probing, Sedgewick)
	public function expected_probes_hits() : Float { return .5 * ( 1. + 1. / ( 1. - load_factor() ) ); }
	
	// expected number of probes on misses (linear probing, Sedgewick)
	public function expected_probes_misses() : Float { return .5 * ( 1. + 1. / Math.pow( 1. - load_factor(), 2. ) ); }
	
	// on hits probe stats
	public function probes_hits() : { avg : Float, max : Int } {
		var total_probes = 0.;
		var max_probes = 0;
		for ( i in 0...m ) {
			var x = t[i];
			if ( null != x ) {
				var j = mod( hash( x.k ) );
				var y;
				var p = 0;
				while ( null != ( y = t[j] ) )
					if ( y.k == x.k )
						break;
					else {
						j = probe( j );
						p++;
					}
				total_probes += p + 1;
				if ( p > max_probes )
					max_probes = p;
			}
		}
		return { avg : total_probes / length, max : max_probes };
	}
	
	// on misses probe stats
	public function probes_misses() : { avg : Float, max : Int } {
		var total_probes = 0.;
		var max_probes = 0;
		for ( i in 0...m ) {
			var j = i;
			var p = 0;
			while ( null != t[j] ) {
				j = probe( j );
				p++;
			}
			total_probes += p + 1;
			if ( p > max_probes )
				max_probes = p;
		}
		return { avg : total_probes / m, max : max_probes };
	}
	
	// all stats
	public function stats() {
		var hits = probes_hits();
		var misses = probes_misses();
		return {
			n : length,
			m : m,
			alpha : load_factor(),
			ExpProbesHits : expected_probes_hits(),
			AvgProbesHits : hits.avg,
			MaxProbesHits : hits.max,
			ExpProbesMisses : expected_probes_misses(),
			AvgProbesMisses : misses.avg,
			MaxProbesMisses : misses.max
		};
	}
	
}
