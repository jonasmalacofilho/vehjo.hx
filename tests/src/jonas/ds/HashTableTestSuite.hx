package jonas.ds;

import haxe.io.Bytes;
import haxe.io.Eof;
import jonas.ds.HashTable;
import jonas.unit.TestCase;
#if ( neko || cpp || php )
import sys.io.File;
#end

/*
 * HashTable test suite
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */

class HashTableTestSuite {
	
	public static function add_tests( t : haxe.unit.TestRunner ) {
		t.add( new IntHashTableTest() );
		t.add( new StringHashTableTest() );
		t.add( new OtherStringHashTableTest() );
		t.add( new LongStringHashTableTest() );
		#if ( neko || cpp || php )
		t.add( new PracticalStringHashTableTest() );
		#end
	}

	static function main() {
		var tests = new jonas.unit.TestRunner();
		add_tests( tests );
		tests.run();
	}
	
}

class IntHashTableTest extends TestCase {
	
	var keys : Array<Dynamic>;
	var values : Array<Int>;
	public var n : Int;
	
	public function new() {
		super();
		set_configuration( Std.string( 1 << 10 ) + ' elements', 1 << 10 );
		set_configuration( Std.string( 1 << 15 ) + ' elements', 1 << 15 );
	}
	
	override function configure( name : String ) : Void {
		var c = _configs.get( name );
		if ( null == c || !Std.is( c, Int ) )
			n = 20;
		else
			n = c;
	}
	
	override public function setup() : Void {
		super.setup();
		generate_keys();
		generate_values();
	}
	
	override public function tearDown() : Void {
		keys = null;
		values = null;
	}
	
	function generate_keys() {
		keys = [];
		for ( i in 0...n )
			keys.push( 0xffffff - Std.random( 0x1ffffff ) );
	}
	
	function generate_values() {
		values = [];
		for ( i in 0...n )
			values.push( i );
	}
	
	function generate_table() : HashTable<Dynamic, Int> {
		return new IntHashTable();
	}
	
	function generate_ref_table() : HashTable<Dynamic, Int> {
		return new IntHash<Int>();
	}
	
	public function test_hash_table() {
		var h = generate_table();
		var r = generate_ref_table();
		
		// insertion
		for ( i in 0...n ) {
			h.set( keys[i], values[i] );
			r.set( keys[i], values[i] );
		}
		for ( i in 0...n )
			assertEquals( r.get( keys[i] ), h.get( keys[i] ) );
		assertEquals( Lambda.count( r ), untyped h.length );
		assertTrue( untyped h.load_factor() <= 1 / 2 || h.load_factor() >= 1/8 );
		
		// large removal
		for ( i in 0...n )
			if ( 9 > Std.random( 10 ) ) {
				h.remove( keys[i] );
				untyped r.remove( keys[i] );
			}
		for ( i in 0...n )
			assertEquals( r.get( keys[i] ), h.get( keys[i] ) );
		assertEquals( Lambda.count( r ), untyped h.length );
		assertTrue( untyped h.load_factor() <= 1 / 2 || h.load_factor() >= 1/8 );
		
		// updating	/ reinsertion
		for ( i in 0...n ) {
			var j = MathExtension.mod( -i, n );
			h.set( keys[i], values[j] );
			r.set( keys[i], values[j] );
		}
		for ( i in 0...n )
			assertEquals( r.get( keys[i] ), h.get( keys[i] ) );
		assertEquals( Lambda.count( r ), untyped h.length );
		assertTrue( untyped h.load_factor() <= 1 / 2 || h.load_factor() >= 1/8 );
		
		//trace( h.stats() );
	}
	
	@fail( 'acknowledged' )
	public function test_performance() {
		var r = generate_ref_table();
		for ( i in 0...n ) {
			keys[i] = keys[i];
			values[i] = values[i];
		}
		var tr = StopWatch.time( function() {
			for ( i in 0...n )
				r.set( keys[i], values[i] );
		} );
		var h = generate_table();
		for ( i in 0...n ) {
			keys[i] = keys[i];
			values[i] = values[i];
		}
		var th = StopWatch.time( function() {
			for ( i in 0...n )
				h.set( keys[i], values[i] );
		} );
		trace( [ th, tr, th / tr ] );
		var x = untyped h.stats();
		trace( Std.format( 'alpha=${x.alpha} ExpProbesHits=${x.ExpProbesHits} AvgProbesHits=${x.AvgProbesHits} MaxProbesHits=${x.MaxProbesHits} ExpProbesMisses=${x.ExpProbesMisses} AvgProbesMisses=${x.AvgProbesMisses} MaxProbesMisses=${x.MaxProbesMisses} WorstKey=${x.WorstKey} WorstHash=${x.WorstHash}' ) );

		assertTrue( th <= tr, pos_infos( 'time<=std' ) );
	}
	
}

class StringHashTableTest extends IntHashTableTest {
	
	override function generate_keys() {
		keys = [];
		for ( i in 0...n ) {
			var b = Bytes.alloc( 6 + Std.random( 3 ) );
			for ( j in 0...b.length )
				b.set( j, Std.random( 64 ) );
			keys.push( b.toString() );
			//trace( Base16.encode16( keys[i] ) );
		}
	}
	
	override function generate_table() : HashTable<Dynamic, Int> {
		return new StringHashTable();
	}
	
	override function generate_ref_table() : HashTable<Dynamic, Int> {
		return new Hash<Int>();
	}
	
}

class LongStringHashTableTest extends StringHashTableTest {
	
	override function generate_keys() {
		keys = [];
		for ( i in 0...n ) {
			var b = Bytes.alloc( 32 + Std.random( 33 ) );
			for ( j in 0...b.length )
				b.set( j, Std.random( 64 ) );
			keys.push( b.toString() );
			//trace( Base16.encode16( keys[i] ) );
		}
	}
	
}

class OtherStringHashTableTest extends StringHashTableTest {
	
	override function generate_keys() {
		keys = [];
		for ( i in 0...n )
			keys.push( Std.string( 0xffffff - Std.random( 0x1ffffff ) ) );
	}
	
}

#if ( neko || cpp || php )
class PracticalStringHashTableTest extends TestCase {
	
	static inline function count( h : Dynamic, k : String ) : Void {
		var cnt = h.get( k );
		h.set( k, ( null != cnt ) ? cnt + 1 : 1 );
	}
	
	function run( file_path : String ) {
		//trace( file_path );
		var r = ~/\w+/;
		
		var h = new StringHashTable();
		var f = File.read( file_path, false );
		var line = '';
		var th = StopWatch.time( function() {
			while ( try { line = f.readLine(); true; } catch ( e : Eof ) { false; } ) {
				while ( r.match( line ) ) {
					var w = r.matched( 0 ).toLowerCase();
					count( h, w );
					line = r.matchedRight();
				}
			}
		} );
		f.close();
			
		var rf = new Hash();
		var f = File.read( file_path, false );
		var line = '';
		var trf = StopWatch.time( function() {
			while ( try { line = f.readLine(); true; } catch ( e : Eof ) { false; } ) {
				while ( r.match( line ) ) {
					var w = r.matched( 0 ).toLowerCase();
					count( rf, w );
					line = r.matchedRight();
				}
			}
		} );
		f.close();
		
		trace( [ th, trf, th / trf ] );
		
		//for ( k in h.keys() )
			//trace( untyped [ k, h.get( k ) ] );
		trace( h.stats() );
		
		assertTrue( true );
	}
	
	public function test_iliad() { return run( '../iliad.mb.txt' ); }
	
	public function test_bible() { return run( '../bible.txt' ); }
	
	public function test_bible_pt() { return run( '../biblia.txt' ); }
	
}
#end