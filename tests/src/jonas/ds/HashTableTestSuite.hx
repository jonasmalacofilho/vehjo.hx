package jonas.ds;

import haxe.io.Bytes;
import haxe.io.Eof;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import jonas.ds.HashTable;
import neko.io.File;
import neko.Lib;

/*
 * HashTable test suite
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
 

class HashTableTestSuite {
	
	public function new() {
		var tests = new TestRunner();
		add_tests( tests );
		tests.run();
		
	}
	
	public static function add_tests( tests : TestRunner ) {
		tests.add( new IntHashTableTest( 1 << 10 ) );
		tests.add( new IntHashTableTest( 1 << 15 ) );
		//tests.add( new IntHashTableTest( 1 << 20 ) );
		tests.add( new StringHashTableTest( 1 << 10 ) );
		tests.add( new StringHashTableTest( 1 << 15 ) );
		//tests.add( new StringHashTableTest( 1 << 20 ) );
		tests.add( new OtherStringHashTableTest( 1 << 10 ) );
		tests.add( new OtherStringHashTableTest( 1 << 15 ) );
		//tests.add( new OtherStringHashTableTest( 1 << 20 ) );
		tests.add( new LongStringHashTableTest( 1 << 10 ) );
		tests.add( new LongStringHashTableTest( 1 << 15 ) );
		//tests.add( new LongStringHashTableTest( 1 << 20 ) );
		tests.add( new PracticalStringHashTableTest() );
	}

	static function main() {
		Lib.println( 'HashTable' );
		Lib.println( 'Copyright (c) 2012 Jonas Malaco Filho' );
		Lib.println( 'Powered by haXe (haxe.org) and neko (nekovm.org)' );
		new HashTableTestSuite();
	}
	
}

class IntHashTableTest extends TestCase {
	
	var keys : Array<Dynamic>;
	var values : Array<Int>;
	var n : Int;
	
	public function new( n : Int ) {
		super();
		this.n = n;
		//trace( 'Generating keys' );
		generate_keys();
		//trace( 'Generating values' );
		generate_values();
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
		trace( untyped h.stats() );
		assertTrue( true );
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