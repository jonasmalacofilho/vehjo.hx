package jonas.ds;

import haxe.Log;
import jonas.unit.TestCase;
import jonas.unit.TestRunner;

//import haxe.lang.Iterator;
import jonas.RevIntIterator;

/*
 * Open addressing hash table
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */

class IntDict<T> {
/*
 * Some notes on IntDict
 * 
 * An Integer is its own hash value
 * 
 * An entry [i] in the table may be in one of the following states:
 *   - filled, state[i] = FILLED; //
 *   - free, state[i] = FREE;
 *   - dummy, state[i] = DUMMY;
 * 
 * There also is another state (BAD) used by probeCount(debug only) and cache.
 * Both cache and probeCoun should be ignored if on state==BAD.
 */
	
	// definitions
	static inline var FILLED = 0;
	static inline var FREE = -1;
	static inline var DUMMY = 1;
	static inline var BAD = -10;
	static inline var START_SIZE = 8;
	static inline var PROBE_A = 5; // from Python
	static inline var PERTURB_SHIFT = 5; // from Python

	// structural fields
	var s : Array<Int>; // state table
	var k : Array<Int>; // key table
	var v : Array<T>; // value table
	var m_ : Int; // m - 1, for using in x mod m = x & ( m - 1 )
	public var length( default, null ) : Int;
	
	// probing shared info
	var j : Int; // current index, after mod
	var perturb : Int; // hash based perturbation, always positive
	
	// cache
	var cachedKey : Int;
	var cachedIndex : Int;
	var cachedState : Int;
	
	// debug information
	#if debug
	public var probeCount( default, null ) : Int;
	#end

	public function new() {
		alloc( START_SIZE );
		#if debug
		probeCount = BAD;
		#end
	}
	
// ---- Public API
	
	public function iterator() : Iterator<T> {
		return null;
	}
	
	public function keys() : Iterator<Int> {
		return null;
	}
	
	public function exists( key : Int ) : Bool {
		if ( cachedState != BAD && cachedKey == key ) {
			#if debug
			probeCount = -1;
			#end
			return cachedState == FILLED;
		}
		cachedKey = key;
		j = mod( key );
		perturbInit( key );
		#if debug
		probeCount = 0;
		#end
		var sj = s[j];
		while ( sj != FREE ) {
			//trace( [ perturb, j, probeCount ] );
			if ( sj == FILLED && k[j] == key ) {
				cachedIndex = j;
				cachedState = FILLED;
				return true;
			}
			probe();
			sj = s[j];
		}
		cachedIndex = j;
		cachedState = FREE;
		return false;
	}
	
	public function get( key : Int ) : T {
		if ( cachedState != BAD && cachedKey == key ) {
			#if debug
			probeCount = -1;
			#end
			if ( cachedState == FILLED )
				return v[cachedIndex];
			else
				#if neko
				return null;
				#else
				return cast null;
				#end
		}
		cachedKey = key;
		j = mod( key );
		perturbInit( key );
		#if debug
		probeCount = 0;
		#end
		var sj = s[j];
		while ( sj != FREE ) {
			if ( sj == FILLED && k[j] == key ) {
				cachedIndex = j;
				cachedState = FILLED;
				return v[j];
			}
			probe();
			sj = s[j];
		}
		cachedIndex = j;
		cachedState = FREE;
		#if neko
		return null;
		#else
		return cast null;
		#end
	}
	
	public function set( key : Int, value : T ) : T {
		if ( cachedState != BAD && cachedKey == key ) {
			if ( cachedState != FILLED )
				length++;
			k[cachedIndex] = key;
			v[cachedIndex] = value;
			s[cachedIndex] = FILLED;
			cachedState = FILLED;
			#if debug
			probeCount = -1;
			#end
			return value;
		}
		j = mod( key );
		perturbInit( key );
		#if debug
		probeCount = 0;
		#end
		while ( s[j] == FILLED && k[j] != key )
			probe();
		if ( s[j] != FILLED )
			length++;
		k[j] = key;
		v[j] = value;
		s[j] = FILLED;
		cachedKey = key;
		cachedIndex = j;
		cachedState = FILLED;
		return value;
	}
	
	public function remove( key : Int ) : Bool {
		return null;
	}
	
// ---- Helper API

	inline function mod( x : Int ) : Int {
		return x & m_;
	}

	inline function size() : Int {
		return m_ + 1;
	}

	inline function alloc( m : Int ) {
		s = [];
		k = [];
		v = [];
		for ( i in new RevIntIterator( m, 0 ) )
			s[i] = FREE;
		k[m-1] = 0;
		v[m - 1] = cast null;
		m_ = m - 1;
		length = 0;
		clearCache();
	}
	
	inline function perturbInit( hash : Int ) {
		perturb = hash > 0 ? hash : - ( hash + 1 );
	}
	
	inline function probe() {
		#if debug
		probeCount++;
		#end
		// from Python
		#if js
		// may fail if PROBE_A * j + perturb becames too large
		// solution is j = mod( Std.int( PROBE_A * j + 1 + perturb ) )
		j = mod( PROBE_A * j + 1 + perturb );
		#else
		j = mod( PROBE_A * j + 1 + perturb );
		#end
		perturb >>= PERTURB_SHIFT;
	}
	
	inline function clearCache() {
		cachedState = BAD;
	}
	
// ---- Temporary

	static function main() {
		var testRunner = new TestRunner();
		testRunner.customTrace = Log.trace;
		testRunner.add( new IntDictTests() );
		testRunner.run();
	}
	
}

class IntDictTests extends TestCase {
	
	@description( '2 keys' )
	public function test2Keys1() {
		var t = new IntDict();
		assertFalse( t.exists( 0 ) );
		assertEquals( 0, t.length );
		t.set( 0, 10 );
		assertTrue( t.exists( 0 ) );
		assertEquals( 1, t.length );
		assertEquals( 10, t.get( 0 ) );
		assertFalse( t.exists( 7 ) );
		t.set( 7, 10 );
		assertTrue( t.exists( 7 ) );
		assertEquals( 2, t.length );
		assertEquals( 10, t.get( 0 ) );
		assertEquals( 10, t.get( 7 ) );
		trace( t );
	}
	
	@description( 'forced collisions' )
	public function testForcedCollisions1() {
		var t = new IntDict();
		assertFalse( t.exists( 7 ) );
		assertEquals( 0, t.length );
		t.set( 7, 10 );
		assertTrue( t.exists( 7 ) );
		assertEquals( 1, t.length );
		assertEquals( 10, t.get( 7 ) );
		while ( t.length < 8 ) {
			var len = t.length;
			//trace( len );
			var k = ( -1212 + 2723 * len ) | 7;
			//trace( k );
			assertFalse( t.exists( k ) );
			//trace( t );
			t.set( k, len );
			//trace( t );
			assertTrue( t.exists( k ) );
			assertEquals( len + 1, t.length );
			assertEquals( 10, t.get( 7 ) );
			assertEquals( len, t.get( k ) );
			//trace( t );
		}
		trace( t );
	}
	
	@description( 'unset keys because of cache' )
	public function test2Keys2() {
		var t = new IntDict();
		assertFalse( t.exists( 0 ) );
		t.set( 7, 10 );
		assertTrue( t.exists( 7 ) );
		assertFalse( t.exists( 15 ) );
		assertEquals( 10, t.get( 7 ) );
		t.set( 15, 100 );
		assertTrue( t.exists( 15 ) );
		assertEquals( 100, t.get( 15 ) );
		assertTrue( t.exists( 7 ) );
		assertEquals( 10, t.get( 7 ) );
		assertTrue( t.exists( 15 ) );
		assertEquals( 100, t.get( 15 ) );
		trace( t );
	}
}