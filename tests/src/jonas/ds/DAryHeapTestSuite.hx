package jonas.ds;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import jonas.ds.DAryHeap;
import jonas.StopWatch;

/*
 * D-arity heaps test suite
 * Copyright (c) 2012 Jonas Malaco Filho
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:�
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

class DAryHeapTestSuite {
	
	var t : TestRunner;
	
	public function new() {
		t = new TestRunner();
		add_tests( t );
		report( 'All tests took ' + StopWatch.time( function() { t.run(); } ) + ' seconds to run' );
	}
	
	public static function add_tests( t : TestRunner ) {
		for ( a in 2...33 )
			test_arity( t, a );
	}
	
	static function test_arity( t : TestRunner, arity : Int ) {
		t.add( new MaxHeapTests( arity ) );
		t.add( new MinHeapTests( arity ) );
	}
	
	static function main() {
		report( 'Copyright (c) 2011 Jonas Malaco Filho\n' );
		report( 'haXe/nekovm says: "Hello!"' );
		new DAryHeapTestSuite();
	}
	
	public static function report( s : String ) : Void {
#if neko
		neko.Lib.println( s );
#elseif cpp
		cpp.Lib.println( s );
#else
		trace( s );
#end
	}
}

class MaxHeapTests extends TestCase {
	
	var h : DAryHeap<Int>;
	var arity : Int;
	
	public function new( arity : Int ) {
		super();
		this.arity = arity;
	}
	
	function init( size=0 ) : Void {
		h = new DAryHeap( arity, size );
		h.predicate = predicate;
	}
	
	function predicate( a : Int, b : Int ) : Bool {
		return a >= b;
	}
	
	function insert_from_array( a : Array<Int> ) : Void {
		for ( x in a )
			h.put( x );
	}
	
	function random_values( n : Int, min : Int, max : Int ) : Array<Int> {
		var a = new Array();
		var s = max - min;
		for ( i in 0...n )
			a.push( Std.random( s + 1 ) + min );
		return a;
	}
	
	function sort_by_predicate( a : Array<Int> ) : Array<Int> {
		var b = a.copy();
		var p = predicate;
		//trace( a );
		b.sort( function( x : Int, y : Int ) { return p( y, x ) ? 1 : -1; } );
		//trace( b );
		return b;
	}
	
	function compare_results( a : Array<Int> ) : Void {
		for ( i in 0...a.length )
			assertEquals( a[i], h.get() );
	}
	
	public function test_basic() : Void {
		DAryHeapTestSuite.report( 'test_basic with arity=' + arity + ' took ' + StopWatch.time( tbasic ) + ' seconds' );
	}
	
	function tbasic() : Void {
		var s = 1000;
		init( s );
		var vs = random_values( s, -1500, 1500 );
		insert_from_array( vs );
		//trace( h );
		compare_results( sort_by_predicate( vs ) );
		vs = random_values( s, -232023, 1008302 );
		insert_from_array( vs );
		compare_results( sort_by_predicate( vs ) );
	}
	
}

class MinHeapTests extends MaxHeapTests {

	override function predicate( a : Int, b : Int ) : Bool {
		return a <= b;
	}
	
}