package jonas.ds;

import haxe.Log;
import haxe.Timer;
import jonas.ds.RjTree;
import jonas.unit.TestCase;
import jonas.ds.RjTree;
import neko.Lib;

/*
 * RjTree test suite
 * Please fell free to add more comprehensive tests
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */

class RjTreeTestSuite {
	
	public static function add_tests( t : jonas.unit.TestRunner ) {
		t.add( new RjTreeComprehensiveTest() );
		t.add( new RjTreeTest() );
	}
	
	static function main() {
		var t = new jonas.unit.TestRunner();
		//t.customTrace = Log.trace;
		add_tests( t );
		t.run();
	}
	
}

class RjTreeComprehensiveTest extends TestCase {
	
	var bucketSize : Int;
	var forcedReinsertion : Bool;
	var tree : RjTree<Int>;
	
	override public function setup() : Void {
		bucketSize = 7;
		forcedReinsertion = true;
		tree = new RjTree( bucketSize, forcedReinsertion );
	}
	
	override public function tearDown() : Void {
		tree = null;
	}
	
	static inline function list<A>( i : Void -> Iterator<A> ) : List<A> { return Lambda.list( { iterator : i } ); }
	static inline function array<A>( i : Void -> Iterator<A> ) : Array<A> { return Lambda.array( { iterator : i } ); }
	static inline function sortedArray<A>( i : Void -> Iterator<A> ) : Array<A> { var a = array( i ); a.sort( Reflect.compare ); return a; }
	
	@description( 'basic insertion test with up to 2 points' )
	public function testInsert1() {
		assertEquals( 0, tree.length, pos_infos( 'tree.length' ) );
		tree.insertPoint( 0., 0., 1 );
		assertEquals( 1, tree.length, pos_infos( 'tree.length' ) );
		tree.insertPoint( 1., -1., 2 );
		assertEquals( 2, tree.length, pos_infos( 'tree.length' ) );
	}
	
	@description( 'test insertion with 2 * bucketSize points+rectangles tree' )
	public function testInsert2() {
		for ( i in 0...bucketSize ) {
			tree.insertPoint( Math.random(), Math.random(), i );
			tree.insertRectangle( .5 - Math.random(), .5 - Math.random(), Math.random(), Math.random(), bucketSize * 2 + i );
			assertEquals( ( i + 1 ) * 2, tree.length, pos_infos( 'tree.length' ) );
		}
	}
	
	@description( 'basic iterator test with up to 2 points' )
	public function testIterator1() {
		assertEquals( [].toString(), sortedArray( tree.iterator ).toString() );
		tree.insertPoint( 0., 0., 0 );
		assertEquals( [0].toString(), sortedArray( tree.iterator ).toString() );
		tree.insertPoint( 1., -1., 1 );
		assertEquals( [0, 1].toString(), sortedArray( tree.iterator ).toString() );
	}
	
	@description( 'test iterator with 2 * bucketSize points+rectangles tree' )
	public function testIterator2() {
		var is = [];
		for ( i in 0...bucketSize ) {
			is.push( i );
			tree.insertPoint( Math.random(), Math.random(), is[is.length - 1] );
			is.push( bucketSize * 2 + i );
			tree.insertRectangle( .5 - Math.random(), .5 - Math.random(), Math.random(), Math.random(), is[is.length - 1] );
		}
		is.sort( Reflect.compare );
		assertEquals( is.toString(), sortedArray( tree.iterator ).toString() );
	}
	
	@description( 'basic search test with up to 2 points' )
	public function testSearch1() {
		assertEquals( [].toString(), sortedArray( callback( tree.search, -2., -2., 2., 2. ) ).toString() );
		tree.insertPoint( 0., 0., 0 );
		assertEquals( [0].toString(), sortedArray( callback( tree.search, -2., -2., 2., 2. ) ).toString() );
		assertEquals( [0].toString(), sortedArray( callback( tree.search, 0., -2., 2., 2. ) ).toString() );
		assertEquals( [0].toString(), sortedArray( callback( tree.search, -2., 0., 2., 2. ) ).toString() );
		assertEquals( [0].toString(), sortedArray( callback( tree.search, -2., -2., 0., 2. ) ).toString() );
		assertEquals( [0].toString(), sortedArray( callback( tree.search, -2., -2., 2., 0. ) ).toString() );
		assertEquals( [0].toString(), sortedArray( callback( tree.search, 0., 0., 0., 0. ) ).toString() );
		tree.insertPoint( 1., -1., 1 );
		assertEquals( [0, 1].toString(), sortedArray( callback( tree.search, -2., -2., 2., 2. ) ).toString() );
		assertEquals( [0, 1].toString(), sortedArray( callback( tree.search, 0., -1., 1., 0. ) ).toString() );
		assertEquals( [0].toString(), sortedArray( callback( tree.search, 0., 0., 1., 0. ) ).toString() );
		assertEquals( [1].toString(), sortedArray( callback( tree.search, .5, -2., 1.5, -.5 ) ).toString() );
	}
	
	@description( 'basic search test with up to 3 rectangles' )
	public function testSearch2() {
		
	}
	
}

private class RjTreeTest extends TestCase {
	
	var ncoordinates : Int;
	var ninsertions : Int;
	var rt : RjTree<Int>;
	
	public function new() {
		super();
		var params = [
			{ c : 5, i : 10 },
			{ c : 10, i : 1000 },
			{ c : 1, i : 1000 },
			{ c : 1000, i : 1000 },
			{ c : 50000, i : 100000 },
			{ c : 100000, i : 100000 }
		];
		for ( p in params )
			set_configuration( Std.string( p ), p );
	}
	
	override public function tearDown() : Void {
		rt = null;
	}
	
	override function configure( name : String ) : Void {
		var c = _configs.get( name );
		if ( null == c ) {
			ncoordinates = 20;
			ninsertions = 200;
		}
		else {
			ncoordinates = c.c;
			ninsertions = c.i;
		}
	}
	
	function reset() : Void {
		rt = new RjTree();
	}
	
	function prepare() : Void {
		reset();
	}
	
	public function test_in_and_query() : Void {
		trace( { coordinates : ncoordinates, insertions : ninsertions } );
		Timer.measure( _test_in_and_query );
	}
	
	function _test_in_and_query() : Void {
		prepare();
		
		trace( 'Creating coordinates' );
		
		var x = new Array();
		var y = new Array();
		var cs = new Array(); // count
		for ( r in 0...ncoordinates ) {
			x.push( Math.random() );
			y.push( Math.random() );
			cs.push( 0 );
		}
		
		trace( 'Inserting on DS' );
		
		for ( i in 0...ninsertions ) {
			var r = Std.random( ncoordinates );
			rt.insertPoint( x[r], y[r], r );
			//trace( { i : i + 1, x : x[r], y : y[r] } );
			cs[r]++;
		}
		
		//trace( rt );
		
		//for ( r in 0...ncoordinates ) {
			//trace( 'for r=' + r + ' x=' + x[r] + ' y=' + y[r] + ' ' + rt.search_rectangle( x[r], y[r], x[r], y[r] ) + rt.search_rectangle( x[r] - .0001, y[r] - .0001, x[r] + .0001, y[r] + .0001 ));
		//}
		
		trace( 'Basic DS checking' );
		assertEquals( ninsertions, rt.length, pos_infos( 'tree.size' ) );
		//assertTrue( rt.verify() );
		
		trace( 'Searching on and checking the DS' );
		
		for ( r in 0...ncoordinates ) {
			var s = Lambda.list( { iterator : callback( rt.search, x[r], y[r], x[r], y[r] ) } );
			assertEquals( cs[r], s.length, pos_infos( 'length' ) );
			//trace( s );
			for ( e in s )
				assertEquals( r, e, pos_infos( 'coordinates' ) ); 
		}
		
	}
	
}