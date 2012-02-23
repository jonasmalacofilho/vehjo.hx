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
  * Integer keys hash table based on GenericHashTable<K, D>
  * Randomized hash function
  */
class IntHashTable<D> extends GenericHashTable<Int, D> {
	
	// word size
	static inline var w = #if neko 31 #else 32 #end;
	// odd integer in the range 2^(w-1) < A < 2^w; should not be too close to 2^(w-1) or 2^w
	var A : Int;
	// shift
	var shift : Int;
	// multiplicative hash function
	override inline function hash( k : Int ) : Int {
		return MathExtension.mod2r( ( A * k ) >> shift, r );
	}
	// hash function configuration (randomized)
	override function set_hash_function() : Void {
		A = Math.round( ( Math.random() * .2 + 1. ) * 1.4 * ( 1 << ( w - 1 ) )  ) | 1; // 1.4 * 2^(w-1) < A < 1.6 * 2^(w-1), odd A
		shift = w - r;
	}
	
}

/**
 * String keys hash table based on GenericHashTable<K, D>
 * Randomized hash function
 */
class StringHashTable<D> extends GenericHashTable<String, D> {
	
	// word size
	static inline var w = #if neko 31 #else 32 #end;
	// h( '' )
	var H0 : Int;
	// odd integer in the range 2^(w-1) < A < 2^w; should not be too close to 2^(w-1) or 2^w
	var A : Int;
	// hash function (horner + multiplicative + simplification)
	override inline function hash( k : String ) : Int {
		var h = H0;
		for ( i in 0...k.length )
			h = h * A + k.charCodeAt( i );
		return MathExtension.mod2r( h, r );
	}
	// hash function configuration (randomized)
	override function set_hash_function() : Void {
		H0 = Std.random( m );
		A = Math.round( ( Math.random() * .2 + 1. ) * 1.4 * ( 1 << ( w - 1 ) )  ) | 1; // 1.4 * 2^(w-1) < A < 1.6 * 2^(w-1), odd A
	}
	
}

/**
 * Hash table for keys of type K and values of type D template
 * Open addressing schema with linear probing
 */
class GenericHashTable<K, D> {

	/** STRUCTURE **/
	
	// key storage
	var key : Array<Null<K>>; 
	
	// data storage
	var data : Array<D>;
	
	// table size: m = 2^r
	var m : Int;
	var r : Int;
	
	// hashing
	function hash( k : K ) : Int { throw ''; return null; }
	
	// probing, may mess up with key removal
	function probe( i : Int, p : Int ) : Int { return MathExtension.mod2r( i + 1, r ); }
	
	
	/** BASIC API **/
	
	public var length( default, null ) : Int;
	
	public function new() {
		init( calc_r( INIT_RESERVE ) );
	}
	
	public function resize( size : Int ) : Void {
		resize_r( calc_r( size ) );
	}
	
	public function exists( k : K ) : Bool {
		return null != get( k );
	}
	
	public function get( k : K ) : Null<D> {
		if ( null == k )
			throw 'Key must not be null';
		var i = hash( k );
		var p = 0;
		var ck;
		while ( null != ( ck = key[i] ) )
			if ( ck == k )
				return data[i];
			else
				i = probe( i, ++p );
		return null;
	}
	
	public function set( k : K, d : D ) : Void {
		if ( null == k )
			throw 'Key must not be null';
		var i = hash( k );
		var p = 0;
		var ck;
		while ( null != ( ck = key[i] ) )
			if ( ck == k ) {
				length--;
				break;
			}
			else {
				i = probe( i, ++p );
				//trace( i );
			}
		data[i] = d;
		key[i] = k;
		length++;
		if ( MAX_LOAD_FACTOR < load_factor() )
			grow();
	}
	
	public function remove( k : K ) : Bool {
		if ( null == k )
			throw 'Key must not be null';
		var h = hash( k );
		var i = h;
		var p = 0;
		var ck;
		while ( null != ( ck = key[i] ) )
			if ( ck == k ) {
				length--;
				key[i] = null;
				data[i] = cast null;
				while ( null != ( ck = key[i = probe( i, ++p ) ] ) )
					if ( hash( ck ) != i ) {
						var d = data[i];
						length--;
						key[i] = null;
						data[i] = cast null;
						set( ck, d );
					}
				if ( MIN_LOAD_FACTOR > load_factor() )
					shrink();
				return true;
			}
			else
				i = probe( i, ++p );
		return false;
	}
	
	public function iterator() : Iterator<D> {
		var i = 0;
		return {
			hasNext : function() {
				for ( j in i...m )
					if ( null != key[j] ) {
						i = j;
						return true;
					}
				return false;
			},
			next : function() {
				return data[i++];
			}
		};
	}
	
	public function keys() : Iterator<K> {
		var i = 0;
		return {
			hasNext : function() {
				for ( j in i...m )
					if ( null != key[j] ) {
						i = j;
						return true;
					}
				return false;
			},
			next : function() {
				return key[i++];
			}
		};
	}
	
	
	/** STATS API **/
	
	/**
	 * Load factor
	 */
	public inline function load_factor() : Float { return length / m ; }
	
	/**
	 * Expected number of probes on hits (linear probing, Sedgewick)
	 */
	public function expected_probes_hits() : Float { return .5 * ( 1. + 1. / ( 1. - load_factor() ) ); }
	
	/**
	 * Expected number of probes on misses (linear probing, Sedgewick)
	 */
	public function expected_probes_misses() : Float { return .5 * ( 1. + 1. / Math.pow( 1. - load_factor(), 2. ) ); }
	
	/**
	 * On hits probe stats
	 */
	public function probes_hits() : { avg : Float, max : Int } {
		var total_probes = 0.;
		var max_probes = 0;
		for ( i in 0...m )
			if ( null != key[i] ) {
				var j = hash( key[i] );
				var p = 0;
				var ck;
				while ( null != ( ck = key[j] ) )
					if ( ck == key[i] )
						break;
					else
						j = probe( j, ++p );
				total_probes += p + 1;
				if ( p > max_probes )
					max_probes = p;
			}
		return { avg : total_probes / length, max : max_probes };
	}
	
	/**
	 * On misses probe stats
	 */
	public function probes_misses() : { avg : Float, max : Int } {
		var total_probes = 0.;
		var max_probes = 0;
		for ( i in 0...m ) {
			var j = i;
			var p = 0;
			while ( null != key[j] )
				j = probe( j, ++p );
			total_probes += p + 1;
			if ( p > max_probes )
				max_probes = p;
		}
		return { avg : total_probes / m, max : max_probes };
	}
	
	/**
	 * All stats
	 */
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
	
	
	/** HELPER API **/
	
	function init( r : Int ) {
		alloc( r );
		set_hash_function();
	}
	
	function alloc( r : Int ) {
		this.r = r;
		m = MathExtension.pow2( r ); // 2^r
		length = 0;
		key = [];
		key[m - 1] = null;
		data = [];
		data[m - 1] = null;
	}
	
	function set_hash_function() : Void { }
	
	function grow() : Void {
		resize_r( r + 1 );
	}
	
	function shrink() : Void {
		resize_r( r - 1 );
	}
	
	function resize_r( nr : Int ) : Void {
		if ( 0 > nr )
			return;
		var key = key;
		var data = data;
		var m = m;
		
		init( nr );
		
		// reinsertion
		for ( i in 0...m )
			if ( null != key[i] )
				set( key[i], data[i] );
	}
	
	static function calc_r( ds : Int ) : Int {
		if ( 0 > ds )
			throw 'Desired size must be positive integer';
		var r = Math.floor( MathExtension.logb( ds / MAX_LOAD_FACTOR, 2. ) ); // m = 2^r, m = 2 * ds
		if ( ds > MathExtension.pow2( r - 1 ) ) // ds > (m=2^r)/2
			r++;
		return r;
	}
	
	static inline var MAX_LOAD_FACTOR = 1 / 2;
	static inline var MIN_LOAD_FACTOR = 1 / 8;
	static inline var INIT_RESERVE = 4;
}