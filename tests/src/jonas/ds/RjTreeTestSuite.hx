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

class RjTreeTestSuite {
	
	public static function add_tests( t : jonas.unit.TestRunner ) {
		t.add( new RjTreeTest() );
	}
	
	static function main() {
		var t = new jonas.unit.TestRunner();
		//t.customTrace = Log.trace;
		add_tests( t );
		t.run();
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
		Timer.measure( _test_in_and_query_lazy );
	}
	
	public function test_in_and_query_lazy() : Void {
		trace( { coordinates : ncoordinates, insertions : ninsertions } );
		Timer.measure( _test_in_and_query_lazy );
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
			rt.insert( r, x[r], y[r] );
			//trace( { i : i + 1, x : x[r], y : y[r] } );
			cs[r]++;
		}
		
		//trace( rt );
		
		//for ( r in 0...ncoordinates ) {
			//trace( 'for r=' + r + ' x=' + x[r] + ' y=' + y[r] + ' ' + rt.search_rectangle( x[r], y[r], x[r], y[r] ) + rt.search_rectangle( x[r] - .0001, y[r] - .0001, x[r] + .0001, y[r] + .0001 ));
		//}
		
		trace( 'Basic DS checking' );
		assertEquals( ninsertions, rt.size, pos_infos( 'tree.size' ) );
		assertTrue( rt.verify() );
		
		trace( 'Searching on and checking the DS' );
		
		for ( r in 0...ncoordinates ) {
			var s = rt.search_rectangle( x[r], y[r], x[r], y[r] );
			assertEquals( cs[r], s.length, pos_infos( 'length' ) );
			//trace( s );
			for ( e in s )
				assertEquals( r, e, pos_infos( 'coordinates' ) ); 
		}
		
	}
	
	function _test_in_and_query_lazy() : Void {
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
			rt.insert( r, x[r], y[r] );
			//trace( { i : i + 1, x : x[r], y : y[r] } );
			cs[r]++;
		}
		
		//trace( rt );
		
		//for ( r in 0...ncoordinates ) {
			//trace( 'for r=' + r + ' x=' + x[r] + ' y=' + y[r] + ' ' + rt.search_rectangle( x[r], y[r], x[r], y[r] ) + rt.search_rectangle( x[r] - .0001, y[r] - .0001, x[r] + .0001, y[r] + .0001 ));
		//}
		
		trace( 'Basic DS checking' );
		assertEquals( ninsertions, rt.size, pos_infos( 'tree.size' ) );
		assertTrue( rt.verify() );
		
		trace( 'Searching on and checking the DS' );
		
		for ( r in 0...ncoordinates ) {
			var s = Lambda.list( { iterator : callback( rt.lazy_search, x[r], y[r], x[r], y[r] ) } );
			assertEquals( cs[r], s.length, pos_infos( 'length' ) );
			//trace( s );
			for ( e in s )
				assertEquals( r, e, pos_infos( 'coordinates' ) ); 
		}
		
	}
	
}