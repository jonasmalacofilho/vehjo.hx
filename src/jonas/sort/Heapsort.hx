package jonas.sort;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import jonas.ds.DAryHeap;
import jonas.StopWatch;

/*
 * Heapsort algorithm
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
 * Heapsort API
 */
class Heapsort {

	public static inline var DEFAULT_ARITY = 4;
	
	/**
	 * Takes an Iterable<A>, an exchange funcion A -> A -> Bool (that returns true if a,b must become b,a in order to sort the array)
	 * and an optional heap arity parameter and returns a new sorted array
	 */
	public static function heapsort<A>( a : Iterable<A>, exchange : A -> A -> Bool, heap_arity = DEFAULT_ARITY ) : Array<A> {
		return new SortingHeap( a, exchange, heap_arity ).sort();
	}
	
}

/**
 * Internals
 */
private class SortingHeap<T> extends DAryHeap<T> {
	
	public function new( a : Iterable<T>, predicate : T -> T -> Bool, arity : Int ) {
		super( arity, 0 );
		this.predicate = predicate;
		build( a );
	}
	
	public function sort() : Array<T> {
		while ( length - 1 > 0 ) {
			exchange( --length, 0 );
			fix_down( 0 );
		}
		return h;
	}
	
}

/**
 * Test case
 */
class HeapsortTest<T> extends TestCase {
	
	var i : Array<T>;
	var arity : Int;
	
	public function new( a : Array<T>, arity : Int ) {
		super();
		i = a;
	}
	
	static function fexchange( a, b ) : Bool { return Reflect.compare( a, b ) > 0; }
	
	static function rev_fexchange( a, b ) : Bool { return Reflect.compare( a, b ) <= 0; }
	
	function simple_test( exchange_function : T -> T -> Bool, check_function : T -> T -> Int ) : Void {
		var o = Heapsort.heapsort( i, exchange_function, arity );
		var c = i.copy();
		c.sort( check_function );
		
		assertEquals( i.length, o.length );
		assertEquals( i.length, c.length );
		
		for ( i in 0...i.length )
			assertEquals( c[i], o[i] );
	}
	
	public function test_up() : Void {
		simple_test( fexchange, function( a, b ) { return Reflect.compare( a, b ); } );
	}
	
	public function test_down() : Void {
		simple_test( rev_fexchange, function( a, b ) { return Reflect.compare( b, a ); } );
	}
	
}

/**
 * Test suite
 */
class HeapsortTestSuite {
	
	public static inline var DEFAULT_RANDOM_ARRAYS = 500;
	public static inline var DEFAULT_TESTING_ARITY = 5;
	
	public static function run( random_arrays = DEFAULT_RANDOM_ARRAYS, arity = DEFAULT_TESTING_ARITY ) : Void {
		var timer = new StopWatch();
		
		var a = new TestRunner();
		a.add( new HeapsortTest( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ], arity ) );
		
		for ( i in 0...random_arrays ) {
			var x = [];
			for ( j in 0...Std.random( 2000 ) )
				x.push( Std.random( 10000 ) - Std.random( 20000 ) );
			a.add( new HeapsortTest( x, arity ) );
		}
		
		for ( i in 0...random_arrays ) {
			var x = [];
			for ( j in 0...Std.random( 2000 ) )
				x.push( Math.random() * 10000. - Math.random() * 20000. );
			a.add( new HeapsortTest( x, arity ) );
		}
		
		a.run();
		
		trace( 'HeapsortTestSuite took ' + timer.partial() + 's, using ' + random_arrays + ' random arrays and heap arity ' + arity );
	}
	
	static function main() : Void { run(); }
	
}
