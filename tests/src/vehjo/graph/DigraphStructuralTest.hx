package vehjo.graph;

import vehjo.unit.TestCase;

/**
	Test case that aims towards 100% branch coverage testing of the digraph structure
	
	Since part of the strucure is public (and not that well documented), a proper test suite
	is necessary to ensure that no invalid states are reached and that the main querying methods
	are correct
	
	This may be used as a standard for future implementations
**/
@about( 'Test case that aims towards 100% branch coverage testing of the digraph structure' )
class DigraphStructuralTest<D : Digraph<V, A>, V : Vertex, A : Arc> extends TestCase {
	
	var d : D;
	
	function digraph( ?params : Array<Dynamic>) : D {
		return cast new Digraph<V, A>();
	}
	
	function vertex( ?params : Array<Dynamic> ) : V {
		return cast new Vertex();
	}
	
	function arc( ?params : Array<Dynamic> ) : A {
		return cast new Arc();
	}
	
	override public function setup() : Void {
		d = digraph();
		super.setup();
	}
	
	public function test_new_digraph() : Void {
		assertFalse( null == untyped d.vs );
		assertEquals( 0, d.nV );
		assertEquals( 0, d.nA );
	}
	
	public function test_new_vertex() : Void {
		var v = vertex();
		assertEquals( null, v.vi );
		assertEquals( null, v.adj );
	}
	
	public function test_new_arc() : Void {
		var w = vertex();
		d.add_vertex( w );
		var p = arc();
		assertEquals( null, p.w );
		assertEquals( null, p._next );
	}
	
	public function test_valid_false_bad_v() : Void {
		var v = d.add_vertex( vertex() );
		v.vi = -1;
		assertFalse( d.valid() );
	}
	
	public function test_valid_false_bad_p_w() : Void {
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		var a = d.add_arc( v, w, arc() );
		w.vi = -1;
		assertFalse( d.valid() );
	}
	
	public function test_valid_false_bad_nV() : Void {
		untyped d.nV = 1;
		assertFalse( d.valid() );
	}
	
	public function test_valid_false_bad_nA() : Void {
		untyped d.nA = 1;
		assertFalse( d.valid() );
	}
	
	public function test_valid_parallel() : Void {
		d.allow_parallel = true;
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		var a = d.add_arc( v, w, arc() );
		var b = d.add_arc( v, w, arc() );
		assertTrue( d.valid() );
		d.allow_parallel = false;
		assertFalse( d.valid() );
	}
	
	public function test_add_vertex_null_v() : Void {
		assertFalse( try { d.add_vertex( null ); true; } catch ( e : Dynamic ) { false; } );
		assertEquals( 0, d.nV );
		assertEquals( 0, d.nA );
	}
	
	public function test_add_vertex_not_null_vi() : Void {
		var v = vertex();
		v.vi = 0;
		assertFalse( try { d.add_vertex( null ); true; } catch ( e : Dynamic ) { false; } );
		assertEquals( 0, d.nV );
		assertEquals( 0, d.nA );
	}
	
	public function test_add_vertex_success() : Void {
		var v = vertex();
		var w = null;
		try { w = d.add_vertex( v ); } catch ( e : Dynamic ) { }
		assertEquals( v, w );
		assertEquals( 1, d.nV );
		assertEquals( 0, d.nA );
		assertEquals( 0, v.vi );
		assertEquals( null, v.adj );
	}
	
	public function test_get_vertex_null() : Void {
		// on static targets, passing a null to an Int results in 0, which may be a valid vertex
		#if ( neko || js || java )
		// for the dynamic targets, that know the diference between null and 0
		assertFalse( try { d.get_vertex( null ); true; } catch ( e : Dynamic ) { false; } );
		#end
	}
	
	public function test_get_vertex_out_of_lower_bound() : Void {
		var w = null;
		assertTrue( try { w = d.get_vertex( -1 ); true; } catch ( e : Dynamic ) { false; } );
		assertEquals( null, w );
	}
	
	public function test_get_vertex_out_of_upper_bound() : Void {
		var w = null;
		assertTrue( try { w = d.get_vertex( 0 ); true; } catch ( e : Dynamic ) { false; } );
		assertEquals( null, w );
	}
	
	public function test_get_vertex_success() : Void {
		var v = vertex();
		assertTrue( try { d.add_vertex( v ); true; } catch ( e : Dynamic ) { false; } );
		var w = d.get_vertex( v.vi );
		assertEquals( v, w );
	}
	
	public function test_check_has_vertex_null_v() : Void {
		assertFalse( try { untyped d.check_has_vertex( null ); true; } catch ( e : Dynamic ) { false; } );
	}
	
	public function test_check_has_vertex_null_vi() : Void {
		assertFalse( try { untyped d.check_has_vertex( vertex() ); true; } catch ( e : Dynamic ) { false; } );
	}
	
	public function test_check_has_vertex_not_on_digraph() : Void {
		var d2 = digraph();
		var v = d2.add_vertex( vertex() );
		d.add_vertex( vertex() );
		assertFalse( try { untyped d.check_has_vertex( v ); true; } catch ( e : Dynamic ) { false; } );
	}
	
	public function test_check_has_vertex_success() : Void {
		var v = d.add_vertex( vertex() );
		assertTrue( try { untyped d.check_has_vertex( v ); true; } catch ( e : Dynamic ) { false; } );
	}
	
	public function test_add_arc_null_v() : Void {
		var w = d.add_vertex( vertex() );
		assertFalse( try { d.add_arc( null, w, arc() ); true; } catch ( e : Dynamic ) { false; } );
		assertEquals( 0, d.nA );
	}
	
	public function test_add_arc_null_w() : Void {
		var v = d.add_vertex( vertex() );
		assertFalse( try { d.add_arc( v, null, arc() ); true; } catch ( e : Dynamic ) { false; } );
		assertEquals( 0, d.nA );
	}
	
	public function test_add_arc_null_v_vi() : Void {
		var v = vertex();
		var w = d.add_vertex( vertex() );
		assertFalse( try { d.add_arc( v, w, arc() ); true; } catch ( e : Dynamic ) { false; } );
		assertEquals( 0, d.nA );
	}
	
	public function test_add_arc_null_w_vi() : Void {
		var v = d.add_vertex( vertex() );
		var w = vertex();
		assertFalse( try { d.add_arc( v, w, arc() ); true; } catch ( e : Dynamic ) { false; } );
		assertEquals( 0, d.nA );
	}
	
	public function test_add_arc_null_a() : Void {
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		assertFalse( try { d.add_arc( v, w, null ); true; } catch ( e : Dynamic ) { false; } );
		assertEquals( 0, d.nA );
	}
	
	public function test_add_arc_not_null_a_next() : Void {
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		var a = arc();
		a._next = a;
		assertFalse( try { d.add_arc( v, w, a ); true; } catch ( e : Dynamic ) { false; } );
		assertEquals( 0, d.nA );
	}
	
	public function test_add_arc_not_null_a_w() : Void {
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		var a = arc();
		a.w = w;
		assertFalse( try { d.add_arc( v, w, a ); true; } catch ( e : Dynamic ) { false; } );
		assertEquals( 0, d.nA );
	}
	
	public function test_add_arc_vv() : Void {
		var v = d.add_vertex( vertex() );
		assertFalse( try { d.add_arc( v, v, arc() ); true; } catch ( e : Dynamic ) { false; } );
		assertEquals( 0, d.nA );
	}
	
	public function test_add_arc_not_parallel() : Void {
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		var a = d.add_arc( v, w, arc() );
		var b = d.add_arc( v, w, arc() );
		assertEquals( 1, d.nA );
	}
	
	public function test_add_arc_parallel() : Void {
		d.allow_parallel = true;
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		var a = d.add_arc( v, w, arc() );
		var b = d.add_arc( v, w, arc(), true );
		assertEquals( 2, d.nA );
	}
	
	public function test_add_arc_slow() : Void {
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		var z = d.add_vertex( vertex() );
		var a = d.add_arc( v, w, arc() );
		var b = d.add_arc( v, z, arc() );
		assertEquals( b, cast a._next );
		assertEquals( a, cast v.adj );
		assertEquals( null, b._next );
		assertEquals( 2, d.nA );
		assertEquals( w, cast a.w );
		assertEquals( z, cast b.w );
	}
	
	public function test_add_arc_fast() : Void {
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		var z = d.add_vertex( vertex() );
		var a = d.add_arc( v, w, arc(), false, true );
		var b = d.add_arc( v, z, arc(), false, true );
		assertEquals( b, cast v.adj );
		assertEquals( a, cast b._next );
		assertEquals( null, a._next );
		assertEquals( 2, d.nA );
		assertEquals( w, cast a.w );
		assertEquals( z, cast b.w );
	}
	
	public function test_get_arc_null_v() : Void {
		var w = d.add_vertex( vertex() );
		assertFalse( try { d.get_arc( null, w ); true; } catch ( e : Dynamic ) { false; } );
	}
	
	public function test_get_arc_null_w() : Void {
		var v = d.add_vertex( vertex() );
		assertFalse( try { d.get_arc( v, null ); true; } catch ( e : Dynamic ) { false; } );
	}
	
	public function test_get_arc_failure() : Void {
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		var a = d.add_arc( w, v, arc() );
		assertEquals( null, d.get_arc( v, w ) );
	}
	
	public function test_get_arc_success() : Void {
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		var a = d.add_arc( v, w, arc() );
		assertEquals( a, d.get_arc( v, w ) );
	}
	
	public function test_remove_arc_fail_empty() : Void {
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		assertFalse( d.remove_arc( v, w ) );
	}
	
	public function test_remove_arc_fail_not_empty() : Void {
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		var a = d.add_arc( w, v, arc() );
		assertFalse( d.remove_arc( v, w ) );
		assertEquals( a, cast w.adj );
		assertEquals( null, a._next );
		assertEquals( 1, d.nA );
	}
	
	public function test_remove_arc_success_head() : Void {
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		var z = d.add_vertex( vertex() );
		var a = d.add_arc( v, w, arc() );
		var b = d.add_arc( v, z, arc() );
		assertTrue( d.remove_arc( v, w ) );
		assertEquals( b, cast v.adj );
		assertEquals( null, b._next );
		assertEquals( 1, d.nA );
		assertEquals( null, a.w );
		assertEquals( null, a._next );
	}
	
	public function test_remove_arc_success_tail_end() : Void {
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		var z = d.add_vertex( vertex() );
		var a = d.add_arc( v, w, arc() );
		var b = d.add_arc( v, z, arc() );
		assertTrue( d.remove_arc( v, z ) );
		assertEquals( a, cast v.adj );
		assertEquals( null, a._next );
		assertEquals( 1, d.nA );
		assertEquals( null, b.w );
		assertEquals( null, b._next );
	}
	
	public function test_remove_arc_success_tail() : Void {
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		var z = d.add_vertex( vertex() );
		var k = d.add_vertex( vertex() );
		var a = d.add_arc( v, w, arc() );
		var b = d.add_arc( v, z, arc() );
		var c = d.add_arc( v, k, arc() );
		assertTrue( d.remove_arc( v, z ) );
		assertEquals( a, cast v.adj );
		assertEquals( c, cast a._next );
		assertEquals( null, c._next );
		assertEquals( 2, d.nA );
		assertEquals( null, b.w );
		assertEquals( null, b._next );
	}
	
	public function test_remove_arc_success_parallel() : Void {
		d.allow_parallel = true;
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		var z = d.add_vertex( vertex() );
		var a = d.add_arc( v, w, arc() );
		var b = d.add_arc( v, z, arc() );
		var c = d.add_arc( v, z, arc() );
		assertTrue( d.remove_arc( v, z ) );
		assertEquals( a, cast v.adj );
		assertEquals( c, cast a._next );
		assertEquals( null, c._next );
		assertEquals( 2, d.nA );
		assertEquals( null, b.w );
		assertEquals( null, b._next );
	}
	
	public function test_order_arcs() : Void {
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		var z = d.add_vertex( vertex() );
		var k = d.add_vertex( vertex() );
		var a = d.add_arc( v, z, arc() );
		var b = d.add_arc( v, k, arc() );
		var c = d.add_arc( v, w, arc() );
		d.order_arcs( function( x, y ) { return x.w.vi > y.w.vi; } );
		assertEquals( c, cast v.adj );
		assertEquals( a, cast c._next );
		assertEquals( b, cast a._next );
		assertEquals( null, b._next );
		assertEquals( 3, d.nA );
	}
	
	public function test_vertices_empty() : Void {
		var vs = Lambda.map( { iterator : d.vertices }, function( v ) { return v.vi; } );
		assertEquals( new List().toString(), vs.toString() );
	}
	
	public function test_vertices_single() : Void {
		var ref = [0];
		d.add_vertex( vertex() );
		var vs = Lambda.map( { iterator : d.vertices }, function( v ) { return v.vi; } );
		assertEquals( Lambda.list( ref ).toString(), vs.toString() );
	}
	
	public function test_vertices_large() : Void {
		var ref = [];
		for ( i in 0...1000 ) {
			ref.push( i );
			d.add_vertex( vertex() );
		}
		var vs = Lambda.map( { iterator : d.vertices }, function( v ) { return v.vi; } );
		assertEquals( Lambda.list( ref ).toString(), vs.toString() );
	}
	
	public function test_arcs_from_null_v() : Void {
		assertFalse( try { d.arcs_from( null ); true; } catch ( e : Dynamic ) { false; } );
	}
	
	public function test_arcs_from_empty() : Void {
		var v = d.add_vertex( vertex() );
		var as = Lambda.map( { iterator: d.arcs_from.bind( v ) }, function( a ) return a.w.vi );
		assertEquals( new List().toString(), as.toString() );
	}
	
	public function test_arcs_from_single() : Void {
		var v = d.add_vertex( vertex() );
		var ref = [ d.add_arc( v, d.add_vertex( vertex() ), arc() ) ];
		var as = Lambda.map( { iterator: d.arcs_from.bind( v ) }, function( a ) return a.w.vi );
		assertEquals( Lambda.map( ref, function( a ) { return a.w.vi; } ).toString(), as.toString() );
	}
	
	public function test_arcs_from_large() : Void {
		var v = d.add_vertex( vertex() );
		var ref = [];
		for ( i in 0...1000 )
			ref.push( d.add_arc( v, d.add_vertex( vertex() ), arc() ) );
		var as = Lambda.map( { iterator: d.arcs_from.bind( v ) }, function( a ) return a.w.vi );
		assertEquals( Lambda.map( ref, function( a ) { return a.w.vi; } ).toString(), as.toString() );
	}
	
	public function test_arcs_from_random_null_v() : Void {
		assertFalse( try { d.arcs_from_random( null ); true; } catch ( e : Dynamic ) { false; } );
	}
	
	public function test_arcs_from_random_empty() : Void {
		var v = d.add_vertex( vertex() );
		var as = Lambda.array( Lambda.map( { iterator: d.arcs_from_random.bind( v ) }, function ( a ) return a.w.vi ) );
		assertEquals( [].toString(), as.toString() );
	}
	
	public function test_arcs_from_random_single() : Void {
		var v = d.add_vertex( vertex() );
		var ref = [ d.add_arc( v, d.add_vertex( vertex() ), arc() ).w.vi ];
		var as = Lambda.array( Lambda.map( { iterator: d.arcs_from_random.bind( v ) }, function ( a ) return a.w.vi ) );
		as.sort( Reflect.compare );
		assertEquals( ref.toString(), as.toString() );
	}
	
	public function test_arcs_from_random_large() : Void {
		var v = d.add_vertex( vertex() );
		var ref = [];
		for ( i in 0...1000 )
			ref.push( d.add_arc( v, d.add_vertex( vertex() ), arc() ).w.vi );
		var as = Lambda.array( Lambda.map( { iterator: d.arcs_from_random.bind( v ) }, function ( a ) return a.w.vi ) );
		var bs = as.copy();
		as.sort( Reflect.compare );
		assertEquals( ref.toString(), as.toString() );
		assertFalse( as.toString() == bs.toString() ); // may eventually fail, but p(fail) = 1 / n! (assuming random number generator, since it's pseudo-random it should be even smaller)
	}
	
	public function test_arcs_no_vertices() : Void {
		var as = Lambda.map( { iterator : d.arcs }, function( a ) { return a.w.vi; } );
		assertEquals( new List().toString(), as.toString() );
	}
	
	public function test_arcs_no_arcs() : Void {
		for ( i in 0...20 )
			d.add_vertex( vertex() );
		var as = Lambda.map( { iterator : d.arcs }, function( a ) { return a.w.vi; } );
		assertEquals( new List().toString(), as.toString() );
	}
	
	public function test_arcs_some() : Void {
		for ( i in 0...20 )
			d.add_vertex( vertex() );
		var ref = new List();
		for ( i in 1...19 ) {
			var wi;
			do { wi = Std.random( 20 ); } while ( wi == i );
			d.add_arc( d.get_vertex( i ), d.get_vertex( wi ), arc() );
			ref.add( wi );
		}
		var as = Lambda.map( { iterator : d.arcs }, function( a ) { return a.w.vi; } );
		assertEquals( ref.toString(), as.toString() );
	}
	
	public function test_is_symmetric_fail() : Void {
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		d.add_arc( v, w, arc() );
		assertFalse( d.is_symmetric() );
	}
	
	public function test_is_symmetric_success_no_vertices() : Void {
		assertTrue( d.is_symmetric() );
	}
	
	public function test_is_symmetric_success_no_arcs() : Void {
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		assertTrue( d.is_symmetric() );
	}
	
	public function test_is_symmetric_success() : Void {
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		d.add_arc( v, w, arc() );
		d.add_arc( w, v, arc() );
		assertTrue( d.is_symmetric(), pos_infos( 'symmetric' ) );
	}
	
}