package jonas.ds;

import haxe.Timer;
import jonas.RevIntIterator;

// imports for testing
import haxe.Log;
import jonas.unit.TestCase;
import jonas.unit.TestRunner;

/*
 * Open addressing hash table
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */

class IntDict<T> {
/*
 * Some notes on IntDict:
 * 
 * This is obviously NOT threadsafe (because of caches). Also, during any iteration, the only safe
 * updating operation is remove (since it won't shrink the table). Set can trigger growth or shrinkage
 * and completely change the whole table. Even set on existing keys can still trigger shrinkage. 
 * 
 * The collsion resolving is done though open addressing.
 * 
 * An Integer is its own hash value.
 * 
 * State, key and value are stored in separe arrays. This is more economical (less memory consumption
 * or calls to new) but has bad cache locality.
 * 
 * An entry [i] in the table may be in one of the following states:
 *   - FILLED: the entry exists
 *   - FREE: the entry does not exist and no further probing is necessary
 *   - DUMMY: there was something here, should keep probing
 * 
 * The cache can be in one of the following states:
 *   - FILLED: the key exists; safe for set/remove
 *   - FREE: the key does not exists, AND the cache index points to the first lookup index;
 *           safe for set/remove
 *   - DUMMY: the key does not exists, but nothing else is sure; UNSAFE for set/remove
 * 
 * There also is another state (BAD) used by probeCount(debug only) and cache.
 * Both cache and probeCoun should be ignored if on state==BAD.
 * 
 * Probing sequence was adapted from Python 3.2.3. It has been simplified (code wise) and
 * does not depend on unsigned (logical) right shifts.
 *     // initial, use j as lookup index:
 *     j = hash mod size
 *     perturb = hash > 0 ? hash : - ( hash + 1 )
 *     // collision resolving:
 *     j = ( ( j << 2 ) + j + 1 + perturb ) mod size
 *     perturb >> 5
 * 
 * TODO:
 *   - remove
 *   - more test cases (including performance test cases)
 */
	
	// definitions
	static inline var FILLED = 0;
	static inline var FREE = -1;
	static inline var DUMMY = 1;
	static inline var BAD = -10;
	static inline var START_SIZE = 8;
	static inline var PROBE_A = 5; // from Python 3.2.3 (doc/dictobject.c::93)
	static inline var PROBE_B = 2; // from Python 3.2.3 (doc/dictobject.c::357)
	static inline var PERTURB_SHIFT = 5; // from Python
	static inline var GROWTH_SHIFT = 1; // 2**GROWTH_SHIFT = 2
	static inline var GROWTH_SHIFT_SMALL = 2; // 2**GROWTH_SHIFT = 4
	static inline var GROWTH_SMALL = 8192;
	static inline var SHRINKAGE_SMALL = GROWTH_SMALL << ( GROWTH_SHIFT_SMALL - GROWTH_SHIFT );
	static inline var MAX_LOAD_FACTOR = .7; // 2/3, as in Python, but rounded up
	static inline var MIN_LOAD_FACTOR = MAX_LOAD_FACTOR / ( 1 << GROWTH_SHIFT );
	static inline var MIN_LOAD_FACTOR_SMALL = MAX_LOAD_FACTOR / ( 1 << GROWTH_SHIFT_SMALL ) - .05;

	// structural fields & state
	var s : Array<Int>; // state table
	var k : Array<Int>; // key table
	var v : Array<T>; // value table
	var size : Int; // table size; while resizing, this is set to BAD to avoid shrinkage
	var mask : Int; // size - 1, or mask for optimizing x mod size = x & ( size - 1 )
	public var length( default, null ) : Int;
	
	// probing shared info
	var j : Int; // current index, in range [0,size-1]
	var perturb : Int; // hash based perturbation, always positive
	
	// cache (regarding current j value)
	var cachedKey : Int;
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

	public inline function loadFactor() : Float {
		return length / size;
	}
	
	public function iterator() : Iterator<T> {
		var i = 0;
		return {
			hasNext : function() {
				for ( j in i...size )
					if ( s[j] == FILLED ) {
						i = j;
						return true;
					}
				return false;
			},
			next : function() {
				return v[i++];
			}
		};
	}
	
	public function keys() : Iterator<Int> {
		var i = 0;
		return {
			hasNext : function() {
				for ( j in i...size )
					if ( s[j] == FILLED ) {
						i = j;
						return true;
					}
				return false;
			},
			next : function() {
				return k[i++];
			}
		};
	}
	
	public function toString() : String {
		var b = new StringBuf();
		b.add( '{ ' );
		var f = true;
		for ( k in keys() ) {
			if ( f )
				f = false;
			else
				b.add( ', ' );
			b.add( k );
			b.add( ' => ' );
			b.add( get( k ) );
		}
		b.add( ' }' );
		#if debug
		b.add( ' : loadFactor=' );
		b.add( loadFactor() );
		b.add( ', length=' );
		b.add( length );
		b.add( ', size=' );
		b.add( size );
		b.add( ', cachedState=' );
		b.add( switch ( cachedState ) {
			case FILLED : 'filled';
			case FREE : 'free';
			case DUMMY : 'dummy';
			case BAD : 'bad';
		} );
		b.add( ', cachedIndex=' );
		b.add( j );
		b.add( ', cachedKey=' );
		b.add( cachedKey );
		b.add( ', lastProbeCount=' );
		b.add( probeCount );
		#end
		return b.toString();
	}
	
	// check if key exists in the dictionary
	public function exists( key : Int ) : Bool {
		
		// attempt to fetch the answer from the cache
		// if the cache is not BAD and the cache key matches the input,
		// than the cache state will be one of the folling, depending if the key:
		//   - exists: FILLED
		//   - does not exist and is safe to use the cached index: FREE
		//   - just does not exists: DUMMY (unsafe)
		// therefore, the key exists in the dictionary if cachedState==FILLED
		if ( cachedState != BAD && cachedKey == key ) {
			#if debug
			probeCount = -1;
			#end
			return cachedState == FILLED;
		}
		
		#if debug
		probeCount = 0;
		#end
		
		// start to lookup the table
		// start on index = hash mod size
		j = mod( key ); // Int hashes to itself
		// if that slot contains a valid key-value pair, test the key
		// if the key matches the input, update the cache and return true (found)
		if ( s[j] == FILLED && k[j] == key ) {
			cachedKey = key;
			cachedState = FILLED;
			return true;
		}
		
		// if the slot is marked as free, can stop, update the cache and return false (not found)
		if ( s[j] == FREE ) {
			cachedKey = key;
			cachedState = FREE;
			return false;
		}
		
		// did not find the key in the initial index
		// will execute the probing sequence
		// but first, prepare the perturbation
		perturbInit( key );
		
		// begin probing
		// get the first new index
		probe();
		var sj = s[j]; // s[j] cache
		// go over the probing sequence returned indices
		// if a slot is free, return false
		// else
		//     if the key-value pair exists, check the key and if, it matches, return true
		//     (updating the cache)
		//     else, get the next index
		while ( sj != FREE ) {
			if ( sj == FILLED && k[j] == key ) {
				cachedKey = key;
				cachedState = FILLED;
				return true;
			}
			probe();
			sj = s[j];
		}
		
		// did not find anything
		cachedKey = key;
		cachedState = DUMMY;
		return false;
	}
	
	// get value for key
	// if the key does not exists, returns cast null
	// should always use exists( k ) before get( k ) if there is no garantee that
	// the k exists in the dictionary; using so will NOT result in two lookups
	public function get( key : Int ) : T {
		
		// attempt to fetch the answer from the cache
		// if the cache is not BAD and the cache key matches the input,
		// than the cache state will be one of the folling, depending if the key:
		//   - exists: FILLED
		//   - does not exist and is safe to use the cached index: FREE
		//   - just does not exists: DUMMY (unsafe)
		// therefore, the key exists in the dictionary if cachedState==FILLED
		if ( cachedState != BAD && cachedKey == key ) {
			#if debug
			probeCount = -1;
			#end
			if ( cachedState == FILLED )
				return v[j];
			else
				#if neko
				return null;
				#else
				return cast null;
				#end
		}
		
		#if debug
		probeCount = 0;
		#end
		
		// start to lookup the table
		// start on index = hash mod size
		j = mod( key ); // Int hashes to itself
		// if that slot contains a valid key-value pair, test the key
		// if the key matches the input, update the cache and return the value (found)
		if ( s[j] == FILLED && k[j] == key ) {
			cachedKey = key;
			cachedState = FILLED;
			return v[j];
		}
		
		// if the slot is marked as free, can stop, update the cache and return null (not found)
		if ( s[j] == FREE ) {
			cachedKey = key;
			cachedState = FREE;
			#if neko
			return null;
			#else
			return cast null;
			#end
		}
		
		// did not find the key in the initial index
		// will execute the probing sequence
		// but first, prepare the perturbation
		perturbInit( key );
		
		// begin probing
		// get the first new index
		probe();
		var sj = s[j]; // s[j] cache
		// go over the probing sequence returned indices
		// if a slot is free, return false
		// else
		//     if the key-value pair exists, check the key and if, it matches, return true
		//     (updating the cache)
		//     else, get the next index
		while ( sj != FREE ) {
			if ( sj == FILLED && k[j] == key ) {
				cachedKey = key;
				cachedState = FILLED;
				return v[j];
			}
			probe();
			sj = s[j];
		}
		
		// did not find anything
		cachedKey = key;
		cachedState = DUMMY;
		#if neko
		return null;
		#else
		return cast null;
		#end
	}
	
	// set value corresponding to key
	// if the key already exists, it's value is replaced
	// returns the same value
	public function set( key : Int, value : T ) : T {
		
		// check if the cache has usefull information
		// if the cache is not BAD and the cache key matches the input,
		// than the cache state will be one of the folling, depending if the key:
		//   - exists: FILLED
		//   - does not exist and is safe to use the cached index: FREE
		//   - just does not exists: DUMMY (unsafe)
		if ( ( cachedState == FILLED || cachedState == FREE ) && cachedKey == key ) {
			#if debug
			probeCount = -1;
			#end
			// if the key is not being replaced, increment length
			if ( cachedState != FILLED )
				length++;
			s[j] = FILLED;
			k[j] = key;
			v[j] = value;
			cachedState = FILLED;
			return value;
		}
		
		#if debug
		probeCount = 0;
		#end
		
		// not on cache, start doing table lookups
		// first index
		j = mod( key );
		// initial perturbation
		perturbInit( key );
		// probe until a FREE, DUMMY or equal key is found
		while ( s[j] == FILLED && k[j] != key )
			probe();
		// if the key is not being replaced, increment length
		if ( s[j] != FILLED )
			length++;
		s[j] = FILLED;
		k[j] = key;
		v[j] = value;
		cachedKey = key;
		cachedState = FILLED;
		resizeIfNeeded();
		return value;
	}
	
	// remove key from the dictionary
	// it consists in setting the slot to DUMMY
	// will not shrink the table (that is only possible on set)
	public function remove( key : Int ) : Bool {
		
		// attempt to use the cache
		// if the cache is not BAD and the cache key matches the input,
		// than the cache state will be one of the folling, depending if the key:
		//   - exists: FILLED
		//   - does not exist and is safe to use the cached index: FREE
		//   - just does not exists: DUMMY (unsafe)
		// therefore, the key exists in the dictionary if cachedState==FILLED
		if ( cachedState != BAD && cachedKey == key ) {
			#if debug
			probeCount = -1;
			#end
			if ( cachedState == FILLED ) {
				s[j] = DUMMY;
				cachedState = DUMMY;
				length--;
				return true;
			}
			else
				return false;
		}
		
		#if debug
		probeCount = 0;
		#end
		
		// start to lookup the table
		// start on index = hash mod size
		j = mod( key ); // Int hashes to itself
		// if that slot contains a valid key-value pair, test the key
		// if the key matches the input, remove it
		if ( s[j] == FILLED && k[j] == key ) {
			s[j] = DUMMY;
			cachedKey = key;
			cachedState = DUMMY;
			length--;
			return true;
		}
		
		// if the slot is marked as free, can stop, update the cache and return false (not removed)
		if ( s[j] == FREE ) {
			cachedKey = key;
			cachedState = FREE;
			return false;
		}
		
		// did not find the key in the initial index
		// will execute the probing sequence
		// but first, prepare the perturbation
		perturbInit( key );
		
		// begin probing
		// get the first new index
		probe();
		var sj = s[j]; // s[j] cache
		// go over the probing sequence returned indices
		// if a slot is free, return false
		// else
		//     if the key-value pair exists, check the key and if, it matches, remove it
		//     else, get the next index
		while ( sj != FREE ) {
			if ( sj == FILLED && k[j] == key ) {
				s[j] = DUMMY;
				cachedKey = key;
				cachedState = DUMMY;
				length--;
				return true;
			}
			probe();
			sj = s[j];
		}
		
		// did not find anything
		cachedKey = key;
		cachedState = DUMMY;
		return false;
	}
	
// ---- Helper API

	inline function mod( x : Int ) : Int {
		return x & mask;
	}

	inline function alloc( m : Int ) {
		s = [];
		k = [];
		v = [];
		for ( i in new RevIntIterator( m, 0 ) )
			s[i] = FREE;
		k[m - 1] = 0;
		#if neko
		v[m - 1] = null;
		#else
		v[m - 1] = cast null;
		#end
		mask = m - 1;
		size = m;
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
		#if js
		// may fail if PROBE_A * j + perturb becames too large
		// solution is to enclose everything before mod (and possibly <<) in Std.int()
		// adapted from Python 3.2.3 (doc/dictobject.c::93)
		//j = mod( PROBE_A * j + 1 + perturb );
		// adapted from Python 3.2.3 (code/dictobject.c::357)
		j = mod( ( j << PROBE_B ) + j + 1 + perturb );
		#else
		// adapted from Python 3.2.3 (doc/dictobject.c::93)
		//j = mod( PROBE_A * j + 1 + perturb );
		// adapted from Python 3.2.3 (code/dictobject.c::357)
		j = mod( ( j << PROBE_B ) + j + 1 + perturb ); 
		#end
		perturb >>= PERTURB_SHIFT;
	}
	
	inline function clearCache() {
		cachedState = BAD;
	}
	
	inline function resizeIfNeeded() {
		var alpha = loadFactor();
		//trace( [ length, size, Std.int( alpha * 100 ) ] );
		if ( alpha > MAX_LOAD_FACTOR ) {
			//trace( [ length, size, Std.int( alpha * 100 ) ] );
			doResize( size << ( length <= GROWTH_SMALL ? GROWTH_SHIFT_SMALL : GROWTH_SHIFT ) );
		}
		else if ( size > 8 )
			if ( length <= SHRINKAGE_SMALL && alpha < MIN_LOAD_FACTOR_SMALL ) {
				//trace( [ length, size, Std.int( alpha * 100 ) ] );
				doResize( size >> GROWTH_SHIFT ); // when shrinking, always use the default GROWTH_SHIFT
			}
			else if ( length > SHRINKAGE_SMALL && alpha < MIN_LOAD_FACTOR ) {
				//trace( [ length, size, Std.int( alpha * 100 ) ] );
				doResize( size >> GROWTH_SHIFT );
			}
	}
	
	inline function doResize( m : Int ) {
		// backup the current table
		var bs = s;
		var bk = k;
		var bv = v;
		var bsize = size;
		// alloc the new table
		alloc( m );
		size = BAD; // hack to avoid shrinkage during reinsertion
		// reinsert
		for ( i in 0...bsize )
			if ( bs[i] == FILLED )
				set( bk[i], bv[i] );
		size = m;
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
		trace( t );
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
		var startTime = Timer.stamp();
		var t = new IntDict();
		//trace( t );
		assertFalse( t.exists( 7 ) );
		assertEquals( 0, t.length );
		t.set( 7, 10 );
		assertTrue( t.exists( 7 ) );
		assertEquals( 1, t.length );
		assertEquals( 10, t.get( 7 ) );
		while ( t.length < 64 * 1024 ) {
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
		//trace( t );
		//trace( 'Current implementation took: ' + ( Timer.stamp() - startTime ) );
	}
	
	@description( 'current implementation benchmark' )
	public function testBenchmark1() {
		var startTime = Timer.stamp();
		var t = new IntDict();
		t.set( 7, 10 );
		while ( t.length < 64 * 1024 ) {
			var len = t.length;
			var k = ( -1212 + 2723 * len ) | 7;
			t.set( k, len );
		}
		trace( 'Current implementation took: ' + ( Timer.stamp() - startTime ) );
	}
	
	@description( 'reference benchmark' )
	public function testRefBenchmark1() {
		var startTime = Timer.stamp();
		var t = new IntHash();
		var length = 0;
		t.set( 7, 10 );
		length++;
		while ( length < 64 * 1024 ) {
			var len = length;
			var k = ( -1212 + 2723 * len ) | 7;
			t.set( k, len );
			length++;
		}
		trace( 'Std version took: ' + ( Timer.stamp() - startTime ) );
	}
	
	@description( 'unset keys because of cache' )
	public function test2Keys2() {
		var t = new IntDict();
		trace( t );
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
	
	@description( 'set two different values to the same key, with and without cache' )
	public function testOverwrite1() {
		var t = new IntDict();
		t.set( 0, 1 );
		assertEquals( 1, t.get( 0 ) );
		t.set( 1, 2 );
		assertEquals( 1, t.get( 0 ) );
		assertEquals( 2, t.get( 1 ) );
		t.set( 0, -1 );
		assertEquals( -1, t.get( 0 ) );
		assertEquals( 2, t.get( 1 ) );
		trace( t );
	}
	
	@description( 'insert and then remove some keys (with collisions)' )
	public function testRemove1() {
		var t = new IntDict();
		var k = 7;
		while ( t.length < .6 * 8 ) {
			t.set( k, t.length );
			//trace( t );
			assertEquals( t.length - 1, t.get( k ) );
			k = ( k * 123 * t.length ) | 7;
		}
		trace( t );
		var len = t.length;
		k = 7;
		for ( i in 0...t.length ) {
			t.remove( k );
			assertEquals( --len, t.length, pos_infos( 'length after removal' ) );
			var k2 = 7;
			for ( j in 0...t.length ) {
				if ( j > i ) {
					//trace( k2 );
					//trace( t );
					assertTrue( t.exists( k2 ), pos_infos( 'untouched key still exists' ) );
					//trace( t );
					assertEquals( j, t.get( k2 ), pos_infos( 'untouched key still maps to correct value' ) );
					assertFalse( t.exists( k ), pos_infos( 'deleted key does no exist/cleans cache' ) );
					assertEquals( j, t.get( k2 ), pos_infos( 'untouched key still maps to correct value/with clean cache' ) );
				}
				k2 = ( k2 * 123 * ( j + 1 ) ) | 7;
			}
			k = ( k * 123 * ( i + 1 ) ) | 7;
		}
		trace( t );
	}
	
	@description( 'set/remove/set/reset/remove' )
	public function testRemove2() {
		var t = new IntDict();
		t.set( 0, 10 );
		assertEquals( 1, t.length );
		assertEquals( 10, t.get( 0 ) );
		t.remove( 0 );
		assertEquals( 0, t.length );
		assertFalse( t.exists( 0 ) );
		t.set( 10, 100 );
		assertEquals( 1, t.length );
		assertEquals( 100, t.get( 10 ) );
		t.set( 0, 10 );
		assertEquals( 2, t.length );
		assertEquals( 10, t.get( 0 ) );
		t.remove( 10 );
		assertEquals( 1, t.length );
		assertFalse( t.exists( 10 ) );
		t.remove( 0 );
		assertEquals( 0, t.length );
		assertFalse( t.exists( 0 ) );
		t.set( 0, 10 );
		assertEquals( 1, t.length );
		assertEquals( 10, t.get( 0 ) );
		t.remove( 0 );
		assertEquals( 0, t.length );
		assertFalse( t.exists( 0 ) );
	}
	
}
