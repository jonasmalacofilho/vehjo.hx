package vehjo.ds;

import haxe.Log;
import haxe.Timer;
import vehjo.ds.RjTree;
import vehjo.MathExtension;
import vehjo.NumberPrinter;
import vehjo.StopWatch;
import vehjo.unit.TestCase;
import vehjo.ds.RjTree;
import vehjo.Vector;
using vehjo.sort.Heapsort;

/**
	RjTree test suite
**/
class RjTreeTestSuite {
	
	public static function add_tests( t : vehjo.unit.TestRunner ) {
		t.add( new RjTreeComprehensiveTest() );
	}
	
	static function main() {
		var t = new vehjo.unit.TestRunner();
		//t.customTrace = Log.trace;
		add_tests( t );
		t.run();
	}
	
}

class RjTreeComprehensiveTest extends TestCase {
	
	static var pointVectors = {
		var v = [];
		for ( i in 0...100000 )
			v.push( new Vector( Math.random(), Math.random() ) );
		v;
	};
	static var searchVectors = {
		var v = [];
		for ( i in 0...4 )
			v.push( new Vector( Math.random() * .5, Math.random() * .5 ) );
		for ( i in 4...100 )
			v.push( new Vector( Math.random() * .9, Math.random() * .9 ) );
		for ( i in 100...10000 )
			v.push( new Vector( Math.random() * .99, Math.random() * .99 ) );
		v;
	};
	
	var configBucketSize : Int;
	var configForcedReinsertion : Bool;
	var tree : RjTree<Int>;
	
	public function new() {
		super();
		_config_default = '(00, false)';
		set_configuration( '(00, false)', { configBucketSize : 2, configForcedReinsertion : false } );
		set_configuration( '(02, true )', { configBucketSize : 2, configForcedReinsertion : true } );
		set_configuration( '(02, false)', { configBucketSize : 2, configForcedReinsertion : false } );
		set_configuration( '(04, true )', { configBucketSize : 4, configForcedReinsertion : true } );
		set_configuration( '(04, false)', { configBucketSize : 4, configForcedReinsertion : false } );
		set_configuration( '(08, true )', { configBucketSize : 8, configForcedReinsertion : true } );
		set_configuration( '(08, false)', { configBucketSize : 8, configForcedReinsertion : false } );
		set_configuration( '(16, true )', { configBucketSize : 16, configForcedReinsertion : true } );
		set_configuration( '(16, false)', { configBucketSize : 16, configForcedReinsertion : false } );
		set_configuration( '(32, true )', { configBucketSize : 32, configForcedReinsertion : true } );
		set_configuration( '(32, false)', { configBucketSize : 32, configForcedReinsertion : false } );
	}
	
	override public function setup() : Void {
		super.setup();
		tree = new RjTree( configBucketSize, configForcedReinsertion );
	}
	
	override public function tearDown() : Void {
		tree = null;
	}
	
	static inline function list<A>( i : Void -> Iterator<A> ) : List<A> { return Lambda.list( { iterator : i } ); }
	static inline function array<A>( i : Void -> Iterator<A> ) : Array<A> { return Lambda.array( { iterator : i } ); }
	static function sortedArray<A>( i : Void -> Iterator<A> ) : Array<A> { var a = array( i ); return a.heapsort( function( x, y ) { return Reflect.compare( x, y ) > 0; } ); }
	
	@description( 'basic insertion test with up to 2 points' )
	public function testInsert1() {
		assertEquals( 0, tree.length, pos_infos( 'tree.length' ) );
		tree.insertPoint( 0., 0., 1 );
		assertEquals( 1, tree.length, pos_infos( 'tree.length' ) );
		tree.insertPoint( 1., -1., 2 );
		assertEquals( 2, tree.length, pos_infos( 'tree.length' ) );
	}
	
	@description( 'test insertion with 2 * configBucketSize points+rectangles tree' )
	public function testInsert2() {
		for ( i in 0...configBucketSize ) {
			tree.insertPoint( Math.random(), Math.random(), i );
			tree.insertRectangle( .5 - Math.random(), .5 - Math.random(), Math.random(), Math.random(), configBucketSize * 2 + i );
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
	
	@description( 'test iterator with 2 * configBucketSize points+rectangles tree' )
	public function testIterator2() {
		var is = [];
		for ( i in 0...configBucketSize ) {
			is.push( i );
			tree.insertPoint( Math.random(), Math.random(), is[is.length - 1] );
			is.push( configBucketSize * 2 + i );
			tree.insertRectangle( .5 - Math.random(), .5 - Math.random(), Math.random(), Math.random(), is[is.length - 1] );
		}
		is.sort( Reflect.compare );
		assertEquals( is.toString(), sortedArray( tree.iterator ).toString() );
	}
	
	@description( 'basic search test with up to 2 points' )
	public function testSearch1() {
		assertEquals( [].toString(), sortedArray( tree.search.bind( -2., -2., 4., 4. ) ).toString() );
		tree.insertPoint( 0., 0., 0 );
		assertEquals( [0].toString(), sortedArray( tree.search.bind( -2., -2., 4., 4. ) ).toString() );
		assertEquals( [0].toString(), sortedArray( tree.search.bind( 0., -2., 2., 4. ) ).toString() );
		assertEquals( [0].toString(), sortedArray( tree.search.bind( -2., 0., 4., 2. ) ).toString() );
		assertEquals( [0].toString(), sortedArray( tree.search.bind( -2., -2., 2., 4. ) ).toString() );
		assertEquals( [0].toString(), sortedArray( tree.search.bind( -2., -2., 4., 2. ) ).toString() );
		assertEquals( [0].toString(), sortedArray( tree.search.bind( 0., 0., 0., 0. ) ).toString() );
		tree.insertPoint( 1., -1., 1 );
		assertEquals( [0, 1].toString(), sortedArray( tree.search.bind( -2., -2., 4., 4. ) ).toString() );
		assertEquals( [0, 1].toString(), sortedArray( tree.search.bind( 0., -1., 1., 1. ) ).toString() );
		assertEquals( [0].toString(), sortedArray( tree.search.bind( 0., 0., 1., 0. ) ).toString() );
		assertEquals( [1].toString(), sortedArray( tree.search.bind( .5, -2., 1., 1.5 ) ).toString() );
	}
	
	@description( 'basic search test with up to 3 rectangles' )
	public function testSearch2() {
		tree.insertRectangle( 0, 0, 10, 10, 0 );
		tree.insertRectangle( 20, 20, 10, 10, 1 );
		tree.insertRectangle( -10, -10, 50, 50, 2 );
		assertEquals( [0, 1, 2].toString(), sortedArray( tree.search.bind( -10, -10, 50, 50 ) ).toString(), pos_infos( 'everything' ) );
		assertEquals( [2].toString(), sortedArray( tree.search.bind( 10.1, 10.1, 9.8, 9.8 ) ).toString(), pos_infos( 'internal' ) );
		assertEquals( [0, 2].toString(), sortedArray( tree.search.bind( -5, -5, 10, 10 ) ).toString(), pos_infos( 'partial' ) );
	}
	
	@description( 'test if width and height are being consistently passed around' )
	public function testSearch3() {
		tree.insertRectangle( -10, -5, 50, 35, 1 ); // ( -10, -5 ), ( 40, 30 )
		assertEquals( [1].toString(), sortedArray( tree.search.bind( -10, -5, 50, 35 ) ).toString(), pos_infos( 'exact' ) );
		assertEquals( [1].toString(), sortedArray( tree.search.bind( -10, -5, 0, 35 ) ).toString(), pos_infos( 'close on lower x' ) );
		assertEquals( [1].toString(), sortedArray( tree.search.bind( -10, -5, 50, 0 ) ).toString(), pos_infos( 'close on lower y' ) );
		assertEquals( [1].toString(), sortedArray( tree.search.bind( 40, -5, 0, 35 ) ).toString(), pos_infos( 'close on upper x' ) );
		assertEquals( [1].toString(), sortedArray( tree.search.bind( -10, 30, 50, 0 ) ).toString(), pos_infos( 'close on upper y' ) );
		assertEquals( [].toString(), sortedArray( tree.search.bind( -20, -5, 9.99, 45 ) ).toString(), pos_infos( 'under x' ) );
		assertEquals( [].toString(), sortedArray( tree.search.bind( -10, -15, 50, 9.99 ) ).toString(), pos_infos( 'under y' ) );
		assertEquals( [].toString(), sortedArray( tree.search.bind( 40.01, -5, 50, 45 ) ).toString(), pos_infos( 'over x' ) );
		assertEquals( [].toString(), sortedArray( tree.search.bind( -10, 30.01, 50, 45 ) ).toString(), pos_infos( 'over y' ) );
	}
	
	@description( 'basic removal test with up to 4 objects' )
	public function testRemove1() {
		assertEquals( 0, tree.removePoint( 0., 0. ), pos_infos( 'removed elements' ) );
		assertEquals( 0, tree.length, pos_infos( 'tree.length' ) );
		tree.insertPoint( 0., 0., 1 );
		assertEquals( 1, tree.length, pos_infos( 'tree.length' ) );
		assertEquals( 1, tree.removePoint( 0., 0. ), pos_infos( 'removed elements' ) );
		assertEquals( 0, tree.length, pos_infos( 'tree.length' ) );
		tree.insertPoint( 1., -1., 2 );
		tree.insertRectangle( 1., -1., 10., 10., 2 );
		tree.insertPoint( 1., -1., -10 );
		assertEquals( 3, tree.length, pos_infos( 'tree.length' ) );
		assertEquals( 2, tree.removeObject( 2 ), pos_infos( 'removed elements (by object)' ) );
		assertEquals( 1, tree.length, pos_infos( 'tree.length' ) );
		tree.insertPoint( 1., -1., 2 );
		tree.insertPoint( 1., -1., 2 );
		tree.insertPoint( 1., -10., 2 );
		assertEquals( 4, tree.length, pos_infos( 'tree.length' ) );
		assertEquals( 2, tree.removePoint( 1., -1., 2 ), pos_infos( 'removed elements' ) );
		assertEquals( 2, tree.length, pos_infos( 'tree.length' ) );
		assertEquals( 1, tree.removePoint( 1., -1. ), pos_infos( 'removed elements' ) );
		assertEquals( 1, tree.length, pos_infos( 'tree.length' ) );
		assertEquals( 0, tree.removePoint( 0., 0. ), pos_infos( 'removed elements' ) );
	}
	
	@description( 'small random model' )
	public function testSmallRandom() {
		var times = runTestRandom( 100 );
		if ( _config_current != _config_default )
			trace(
				_config_current + ':' + NumberPrinter.printInteger( 100, 7 ) + ': ' +
				NumberPrinter.printDecimal( times.get( 'insertion' ), 6, 4 ) + ' ' +
				NumberPrinter.printDecimal( times.get( 'iteration' ), 6, 4 ) + ' ' +
				NumberPrinter.printDecimal( times.get( 'searching(1%)' ), 6, 4 ) + ' ' +
				NumberPrinter.printDecimal( times.get( 'searching(10%)' ), 6, 4 ) + ' ' +
				NumberPrinter.printDecimal( times.get( 'searching(50%)' ), 6, 4 )
			);
	}
	
	@description( 'medium random model' )
	public function testMediumRandom() {
		var times = runTestRandom( 1000 );
		if ( _config_current != _config_default )
			trace(
				_config_current + ':' + NumberPrinter.printInteger( 1000, 7 ) + ': ' +
				NumberPrinter.printDecimal( times.get( 'insertion' ), 6, 4 ) + ' ' +
				NumberPrinter.printDecimal( times.get( 'iteration' ), 6, 4 ) + ' ' +
				NumberPrinter.printDecimal( times.get( 'searching(1%)' ), 6, 4 ) + ' ' +
				NumberPrinter.printDecimal( times.get( 'searching(10%)' ), 6, 4 ) + ' ' +
				NumberPrinter.printDecimal( times.get( 'searching(50%)' ), 6, 4 )
			);
	}
	
	@description( 'large random model' )
	public function testLargeRandom() {
		var times = runTestRandom( 10000 );
		if ( _config_current != _config_default )
			trace(
				_config_current + ':' + NumberPrinter.printInteger( 10000, 7 ) + ': ' +
				NumberPrinter.printDecimal( times.get( 'insertion' ), 6, 4 ) + ' ' +
				NumberPrinter.printDecimal( times.get( 'iteration' ), 6, 4 ) + ' ' +
				NumberPrinter.printDecimal( times.get( 'searching(1%)' ), 6, 4 ) + ' ' +
				NumberPrinter.printDecimal( times.get( 'searching(10%)' ), 6, 4 ) + ' ' +
				NumberPrinter.printDecimal( times.get( 'searching(50%)' ), 6, 4 )
			);
	}
	
	function runTestRandom( size : Int ) {
		var times = new Map();
		var sw = new StopWatch();
		
		// insertion
		{
			sw.reset();
			for ( i in 0...size ) {
				var v = pointVectors[i];
				tree.insertPoint( v.x, v.y, i );
			}
			times.set( 'insertion', sw.partial() );
			assertEquals( tree.length, size, pos_infos( 'tree.length after insertion' ) );
		}
		
		// iteration
		{
			// timed
			sw.reset();
			for ( x in tree )
				x;
			times.set( 'iteration', sw.partial() );
			// verification
			var exp = [];
			for ( i in 0...size )
				exp.push( i );
			var rec = [];
			for ( x in tree )
				rec.push( x );
			rec = rec.heapsort( function( a, b ) { return b < a; } );
			assertEquals( exp.toString(), rec.toString() );
		}
		
		// searching
		{
			// small (1%)
			{
				// timed
				sw.reset();
				for ( i in 0...10000 ) {
					var v = searchVectors[i];
					for ( x in tree.search( v.x, v.y, .01, .01 ) )
						x;
				}
				times.set( 'searching(1%)', sw.partial() );
				// verification
				for ( i in 0...100 ) {
					var v = searchVectors[i];
					var res = [];
					for ( x in tree.search( v.x, v.y, .01, .01 ) )
						res.push( x );
					res = res.heapsort( function( a, b ) { return b < a; } );
					var exp = [];
					for ( j in 0...size ) {
						var u = pointVectors[j];
						if ( u.x >= v.x && u.x <= ( v.x + .01 ) && u.y >= v.y && u.y <= ( v.y + .01 ) )
							exp.push( j );
					}
					assertEquals( exp.toString(), res.toString() );
				}
			}
			// medium (10%)
			{
				// timed
				sw.reset();
				for ( i in 0...100 ) {
					var v = searchVectors[i];
					for ( x in tree.search( v.x, v.y, .1, .1 ) )
						x;
				}
				times.set( 'searching(10%)', sw.partial() );
			}
			// large (50%)
			{
				// timed
				sw.reset();
				for ( i in 0...4 ) {
					var v = searchVectors[i];
					for ( x in tree.search( v.x, v.y, .5, .5 ) )
						x;
				}
				times.set( 'searching(50%)', sw.partial() );
			}
		}
		
		return times;
	}
	
}
