package vehjo.ds.queue;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import vehjo.ds.queue.PriorityQueue;
import vehjo.StopWatch;

/*
 * Priority queue test suite
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
 * Priority queue: test suite
 * @author Jonas Malaco Filho
 */

class PriorityQueueTestSuite {
	
	var t : TestRunner;
	
	public function new() {
		t = new TestRunner();
		add_tests( t );
		report( 'All tests took ' + StopWatch.time( function() { t.run(); } ) + ' seconds to run' );
	}
	
	public static function add_tests( t : TestRunner ) {
		t.add( new MaxQueueTests() );
		t.add( new MinQueueTests() );
	}
	
	static function main() {
		report( 'Copyright (c) 2011 Jonas Malaco Filho\n' );
		report( 'haXe/nekovm says: "Hello!"' );
		new PriorityQueueTestSuite();
	}
	
	public static function report( s : String ) : Void {
		trace( s );
	}
}

class MaxQueueTests extends TestCase {
	
	var h : PriorityQueue<Int>;
	var vs : Array<Int>;
	var arity : Int;
	
	function init( size=0 ) : Void {
		h = new PriorityQueue( size );
		h.predicate = predicate;
	}
	
	function init2( size = 0 ) : Void {
		h = new PriorityQueue( size );
		h.predicate = predicate2;
	}
	
	function predicate( a : Int, b : Int ) : Bool {
		return a >= b;
	}
	
	function predicate2( a : Int, b : Int ) : Bool {
		return vs[a] >= vs[b];
	}
	
	function insert_from_array( a : Array<Int> ) : Void {
		for ( x in a )
			h.put( x );
	}
	
	function random( min : Int, max : Int ) : Int {
		var s = max - min;
		return Std.random( s + 1 ) + min;
	}
	
	function random_values( n : Int, min : Int, max : Int ) : Array<Int> {
		var a = new Array();
		for ( i in 0...n )
			a.push( random( min, max ) );
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
	
	function sort_by_predicate2( a : Array<Int> ) : Array<Int> {
		var b = a.copy();
		var p = predicate2;
		//trace( a );
		b.sort( function( x : Int, y : Int ) { return p( y, x ) ? 1 : -1; } );
		//trace( b );
		return b;
	}
	
	function compare_results( a : Array<Int> ) : Void {
		for ( i in 0...a.length )
			assertEquals( a[i], h.get() );
	}
	
	function compare_results2( a : Array<Int>, b : Array<Int> ) : Void {
		for ( i in 0...a.length )
			assertEquals( a[i], b[h.get()] );
	}
	
	public function test_basic() : Void {
		PriorityQueueTestSuite.report( 'test_basic took ' + StopWatch.time( tbasic ) + ' seconds' );
	}
	
	function tbasic() : Void {
		var s = 1000;
		init( s );
		vs = random_values( s, -150, 250 );
		insert_from_array( vs );
		//trace( h );
		compare_results( sort_by_predicate( vs ) );
		vs = random_values( s, -232023, 1008302 );
		insert_from_array( vs );
		//trace( sort_by_predicate( vs ) );
		//trace( h );
		compare_results( sort_by_predicate( vs ) );
	}
	
	public function test_complementary() : Void {
		PriorityQueueTestSuite.report( 'test_complementary took ' + StopWatch.time( tcomplementary ) + ' seconds' );
	}
	
	function sequential_values( s : Int ) : Array<Int> {
		var a = new Array();
		for ( i in 0...s )
			a.push( i );
		return a;
	}
	
	function tcomplementary() : Void {
		var s = 1000;
		init2( s );
		var es = sequential_values( s );
		var is = es.copy();
		vs = random_values( s, -150, 250 );
		h.update_index = function( e : Int, i : Int ) {
			is[e] = i;
		};
		insert_from_array( es );
		for ( i in 0...s ) {
			var r = random( -231254, 23142 );
			vs[i] = r;
			h.update( is[i] );
		}
		//trace( h );
		//trace( 'vs: ' + vs );
		//trace( 'expected: ' + sort_by_predicate2( es ) );
		compare_results2( sort_by_predicate( vs ), vs );
	}
	
	public function test_string() : Void {
		PriorityQueueTestSuite.report( 'test_string took ' + StopWatch.time( tstring ) + ' seconds' );
	}
	
	function tstring() : Void {
		var s = 1000;
		init( s );
		vs = random_values( s, -1500, 1500 );
		insert_from_array( vs );
		assertEquals( 'PriorityQueue { ' + sort_by_predicate( vs ).join( ', ' ) + ' }', h.toString() );
	}
	
}

class MinQueueTests extends MaxQueueTests {

	override function predicate( a : Int, b : Int ) : Bool {
		return a <= b;
	}
	
	override function predicate2( a : Int, b : Int ) : Bool {
		return vs[a] <= vs[b];
	}
	
}