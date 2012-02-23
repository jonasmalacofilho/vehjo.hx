package jonas.ds;

import haxe.Timer;
import jonas.ds.RjTree;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;
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
	
	var t : TestRunner;
	
	public function new() {
		t = new TestRunner();
		add_tests( t );
		t.run();
	}
	
	public static function add_tests( t : TestRunner ) {
		t.add( new RjTreeTest( 5, 10 ) );
		t.add( new RjTreeTest( 10, 1000 ) );
		t.add( new RjTreeTest( 1, 1000 ) );
		t.add( new RjTreeTest( 1000, 1000 ) );
		t.add( new RjTreeTest( 50000, 100000 ) );
		t.add( new RjTreeTest( 100000, 100000 ) );
	}
	
	static function main() {
		Lib.println( 'Copyright (c) 2011 Jonas Malaco Filho\n' );
		//Lib.println( 'haXe/nekovm says: "Hello!"' );
		new RjTreeTestSuite();
	}
	
}

private class RjTreeTest extends TestCase {
	
	var ncoordinates : Int;
	var ninsertions : Int;
	var rt : RjTree<Int>;
	
	public function new( cs : Int, is : Int ) {
		super();
		ncoordinates = cs;
		ninsertions = is;
	}
	
	function reset() : Void {
		rt = new RjTree();
	}
	
	function prepare() : Void {
		if ( null == rt )
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
			rt.insert( r, x[r], y[r] );
			//trace( { i : i + 1, x : x[r], y : y[r] } );
			cs[r]++;
		}
		
		//trace( rt );
		
		//for ( r in 0...ncoordinates ) {
			//trace( 'for r=' + r + ' x=' + x[r] + ' y=' + y[r] + ' ' + rt.search_rectangle( x[r], y[r], x[r], y[r] ) + rt.search_rectangle( x[r] - .0001, y[r] - .0001, x[r] + .0001, y[r] + .0001 ));
		//}
		
		trace( 'Basic DS checking' );
		assertEquals( ninsertions, rt.size );
		assertTrue( rt.verify() );
		
		trace( 'Searching on and checking the DS' );
		
		for ( r in 0...ncoordinates ) {
			var s = rt.search_rectangle( x[r], y[r], x[r], y[r] );
			assertEquals( cs[r], s.length );
			//trace( s );
			for ( e in s )
				assertEquals( r, e ); 
		}
		
	}
	
}