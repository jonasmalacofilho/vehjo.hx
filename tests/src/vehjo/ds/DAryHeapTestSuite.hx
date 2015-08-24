package vehjo.ds;

import vehjo.unit.TestCase;
import vehjo.ds.DAryHeap;
import vehjo.StopWatch;

/**
	D-arity heaps test suite
**/
class DAryHeapTestSuite {
	
	public static function add_tests( t : haxe.unit.TestRunner ) {
		t.add( new MaxHeapTests() );
		t.add( new MinHeapTests() );
	}
	
	static function main() {
		var t = new vehjo.unit.TestRunner();
		add_tests( t );
		trace( 'All tests took ' + StopWatch.time( function() { t.run(); } ) + ' seconds to run' );
	}
	
}

class MaxHeapTests extends TestCase {
	
	var h : DAryHeap<Int>;
	public var arity : Int;
	
	public function new() {
		super();
		for ( a in 2...33 ) {
			var name = 'arity = ' + StringTools.lpad( Std.string( a ), '0', 2 );
			set_configuration( name, a );
		}
	}
	
	override function configure( name : String ) : Void {
		var c = _configs.get( name );
		if ( null == c || !Std.is( c, Int ) )
			arity = 5
		else
			arity = c;
	}
	
	function init( size=0 ) : Void {
		h = new DAryHeap( arity, size );
		h.predicate = predicate;
	}
	
	function predicate( a : Int, b : Int ) : Bool {
		return a >= b;
	}
	
	function insert_from_array( a : Array<Int> ) : Void {
		//for ( x in a )
			//h.put( x );
		h.build( a );
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
		trace( 'test_basic with arity=' + arity + ' took ' + tbasic() + ' seconds' );
	}
	
	function tbasic() : Float {
		var s = 1000;
		init( s );
		var vs = random_values( s, -1500, 1500 );
		insert_from_array( vs );
		//trace( h );
		var ref = sort_by_predicate( vs );
		var t1 = StopWatch.time( function () compare_results( ref ) );
		vs = random_values( s, -232023, 1008302 );
		insert_from_array( vs );
		ref = sort_by_predicate( vs );
		var t2 = StopWatch.time( function () compare_results( ref ) );
		return .5 * ( t1 + t2 );
	}
	
}

class MinHeapTests extends MaxHeapTests {

	override function predicate( a : Int, b : Int ) : Bool {
		return a <= b;
	}
	
}