package jonas.graph;

import jonas.graph.Digraph;
import jonas.graph.DigraphGenerator;

/*
 * Graph: vertex coloring algorithm (in development)
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
 
class ColoringGraphVertex extends Vertex {
	public var color : Int;
}

class ColoringGraph<V : ColoringGraphVertex, A : Arc> extends Digraph<V, A> {
	
	public var chromatic_number( default, null ) : Int;
	
	// O( V ) + O( color_rec ) = O( V + A + V * chromatic_number )
	public function color() : Int {
		// setup
		for ( v in vs )
			v.color = -1;
		var max_colors = 0;
		
		// dfs
		for ( v in vs )
			if ( -1 == v.color )
				max_colors = color_rec( max_colors, v );
		
		chromatic_number = max_colors;
		return max_colors;
	}
	
	// O( V * chromatic_number + A )
	function color_rec( max_colors : Int, v : V ) : Int {
		// color v: smallest free color or a new one
		var ncs = [];
		for ( i in 0...max_colors )
			ncs.push( false );
		var p = v.adj; while ( null != p ) {
			var w : V = cast p.w;
			if ( -1 != w.color )
				ncs[w.color] = true;
			p = p._next;
		}
		for ( i in 0...ncs.length )
			if ( !ncs[i] ) {
				v.color = i;
				break;
			}
		if ( -1 == v.color )
			v.color = max_colors++;
		
		// recurse
		var p = v.adj; while ( null != p ) {
			var w : V = cast p.w;
			if ( -1 == w.color )
				max_colors = color_rec( max_colors, w );
			p = p._next;
		}
		
		return max_colors;
	}
	
	override public function show( separator : String ) : String {
		var b = new StringBuf();
		b.add( 'number of vertices = ' );
		b.add( nV );
		b.add( separator );
		b.add( 'number of arcs = ' );
		b.add( nA );
		b.add( separator );
		b.add( 'chromatic number = ' );
		b.add( chromatic_number );
		for ( v in vs ) {
			var p : A = cast v.adj;
			while ( null != p ) {
				var w : V = cast p.w;
				b.add( separator );
				b.add( v.vi );
				b.add( '(Color ' );
				b.add( v.color );
				b.add( ')' );
				b.add( '-' );
				b.add( w.vi );
				b.add( '(Color ' );
				b.add( w.color );
				b.add( ')' );
				p = cast p._next;
			}
		}
		return b.toString();
	}
	
	#if DIGRAPH_TESTS
	public inline function check_property( v : V, a : A ) {
		var w : V = cast a.w;
		assertFalse( v.color == w.color );
	}
	override public function test_example() : Void {
		// http://en.wikipedia.org/wiki/Greedy_coloring
		
		// construction
		var arc_constructor = function( v, w ) { return new Arc( w ); };
		// order A
		var d = new ColoringGraph();
		for ( i in 0...9 )
			d.add_vertex( new ColoringGraphVertex() );
		d.add_edge( d.get_vertex( 1 ), d.get_vertex( 6 ), arc_constructor );
		d.add_edge( d.get_vertex( 1 ), d.get_vertex( 7 ), arc_constructor );
		d.add_edge( d.get_vertex( 1 ), d.get_vertex( 8 ), arc_constructor );
		d.add_edge( d.get_vertex( 2 ), d.get_vertex( 5 ), arc_constructor );
		d.add_edge( d.get_vertex( 2 ), d.get_vertex( 7 ), arc_constructor );
		d.add_edge( d.get_vertex( 2 ), d.get_vertex( 8 ), arc_constructor );
		d.add_edge( d.get_vertex( 3 ), d.get_vertex( 5 ), arc_constructor );
		d.add_edge( d.get_vertex( 3 ), d.get_vertex( 6 ), arc_constructor );
		d.add_edge( d.get_vertex( 3 ), d.get_vertex( 8 ), arc_constructor );
		d.add_edge( d.get_vertex( 4 ), d.get_vertex( 5 ), arc_constructor );
		d.add_edge( d.get_vertex( 4 ), d.get_vertex( 6 ), arc_constructor );
		d.add_edge( d.get_vertex( 4 ), d.get_vertex( 7 ), arc_constructor );
		d.add_edge( d.get_vertex( 5 ), d.get_vertex( 2 ), arc_constructor );
		d.add_edge( d.get_vertex( 5 ), d.get_vertex( 3 ), arc_constructor );
		d.add_edge( d.get_vertex( 5 ), d.get_vertex( 4 ), arc_constructor );
		d.add_edge( d.get_vertex( 6 ), d.get_vertex( 1 ), arc_constructor );
		d.add_edge( d.get_vertex( 6 ), d.get_vertex( 3 ), arc_constructor );
		d.add_edge( d.get_vertex( 6 ), d.get_vertex( 4 ), arc_constructor );
		d.add_edge( d.get_vertex( 7 ), d.get_vertex( 1 ), arc_constructor );
		d.add_edge( d.get_vertex( 7 ), d.get_vertex( 2 ), arc_constructor );
		d.add_edge( d.get_vertex( 7 ), d.get_vertex( 4 ), arc_constructor );
		d.add_edge( d.get_vertex( 8 ), d.get_vertex( 1 ), arc_constructor );
		d.add_edge( d.get_vertex( 8 ), d.get_vertex( 2 ), arc_constructor );
		d.add_edge( d.get_vertex( 8 ), d.get_vertex( 3 ), arc_constructor );
		assertEquals( 9, d.nV );
		assertEquals( 24, d.nA );
		// order B
		var e = new ColoringGraph();
		for ( i in 0...9 )
			e.add_vertex( new ColoringGraphVertex() );
		e.add_edge( e.get_vertex( 1 ), e.get_vertex( 4 ), arc_constructor );
		e.add_edge( e.get_vertex( 1 ), e.get_vertex( 6 ), arc_constructor );
		e.add_edge( e.get_vertex( 1 ), e.get_vertex( 8 ), arc_constructor );
		e.add_edge( e.get_vertex( 2 ), e.get_vertex( 3 ), arc_constructor );
		e.add_edge( e.get_vertex( 2 ), e.get_vertex( 5 ), arc_constructor );
		e.add_edge( e.get_vertex( 2 ), e.get_vertex( 7 ), arc_constructor );
		e.add_edge( e.get_vertex( 3 ), e.get_vertex( 2 ), arc_constructor );
		e.add_edge( e.get_vertex( 3 ), e.get_vertex( 6 ), arc_constructor );
		e.add_edge( e.get_vertex( 3 ), e.get_vertex( 8 ), arc_constructor );
		e.add_edge( e.get_vertex( 4 ), e.get_vertex( 1 ), arc_constructor );
		e.add_edge( e.get_vertex( 4 ), e.get_vertex( 5 ), arc_constructor );
		e.add_edge( e.get_vertex( 4 ), e.get_vertex( 7 ), arc_constructor );
		e.add_edge( e.get_vertex( 5 ), e.get_vertex( 2 ), arc_constructor );
		e.add_edge( e.get_vertex( 5 ), e.get_vertex( 4 ), arc_constructor );
		e.add_edge( e.get_vertex( 5 ), e.get_vertex( 8 ), arc_constructor );
		e.add_edge( e.get_vertex( 6 ), e.get_vertex( 1 ), arc_constructor );
		e.add_edge( e.get_vertex( 6 ), e.get_vertex( 3 ), arc_constructor );
		e.add_edge( e.get_vertex( 6 ), e.get_vertex( 7 ), arc_constructor );
		e.add_edge( e.get_vertex( 7 ), e.get_vertex( 2 ), arc_constructor );
		e.add_edge( e.get_vertex( 7 ), e.get_vertex( 4 ), arc_constructor );
		e.add_edge( e.get_vertex( 7 ), e.get_vertex( 6 ), arc_constructor );
		e.add_edge( e.get_vertex( 8 ), e.get_vertex( 1 ), arc_constructor );
		e.add_edge( e.get_vertex( 8 ), e.get_vertex( 3 ), arc_constructor );
		e.add_edge( e.get_vertex( 8 ), e.get_vertex( 5 ), arc_constructor );
		assertEquals( 9, e.nV );
		assertEquals( 24, e.nA );
		
		// checking
		assertEquals( 2, d.color() );
		assertEquals( 2, e.color() );
		for ( v in d.vs ) {
			var p : A = cast v.adj;
			while ( null != p ) {
				check_property( cast v, p );
				p = cast p._next;
			}
		}
		trace( 'Example digraph, order A: ' + d );
		trace( 'Example digraph, order B: ' + e );
		
	}
	public function test_Petersen() : Void {
		// http://en.wikipedia.org/wiki/Petersen_graph
		
		// construction
		var vertex_constructor = function() { return new ColoringGraphVertex(); };
		var arc_constructor = function( v, w ) { return new Arc( w ); };
		var d = new PetersenGraph( new ColoringGraph<ColoringGraphVertex, Arc>(), vertex_constructor, arc_constructor ).dg;
		assertEquals( 10, d.nV );
		assertEquals( 30, d.nA );
		
		// checking
		assertEquals( 3, d.color() );
		for ( v in d.vs ) {
			var p : A = cast v.adj;
			while ( null != p ) {
				check_property( cast v, p );
				p = cast p._next;
			}
		}
		trace( 'Petersen graph: ' + d );
		
	}
	public function test_Random() : Void {
		
		// construction
		var nV = 10000;
		var nE = 100000;
		var vertex_constructor = function() { return new ColoringGraphVertex(); };
		var arc_constructor = function( v, w ) { return new Arc( w ); };
		var d = new RandomGraph( new ColoringGraph<ColoringGraphVertex, Arc>(), vertex_constructor, arc_constructor, nV, nE ).dg;
		assertEquals( nV, d.nV );
		assertEquals( nE, 2 * d.nA );
		
		// checking
		d.color();
		//trace( 'Random digraph: ' + d );
		for ( v in d.vs ) {
			var p : A = cast v.adj;
			while ( null != p ) {
				check_property( cast v, p );
				p = cast p._next;
			}
		}
		trace( 'Random digraph: {number of vertices = ' + d.nV + ', number of arcs = ' + d.nA + ', chromatic_number = ' + d.chromatic_number + '}' );
		
	}
	public function test_Crown() : Void {
		// http://en.wikipedia.org/wiki/Crown_graph
		
		// construction
		var vertex_constructor = function() { return new ColoringGraphVertex(); };
		var arc_constructor = function( v, w ) { return new Arc( w ); };
		var n = 100;
		var d = new CrownGraph( new ColoringGraph<ColoringGraphVertex, Arc>(), vertex_constructor, arc_constructor, n, 0 ).dg;
		var e = new CrownGraph( new ColoringGraph<ColoringGraphVertex, Arc>(), vertex_constructor, arc_constructor, n, 1 ).dg;
		assertEquals( 2 * n, d.nV );
		assertEquals( 2 * n * ( n - 1 ), d.nA );
		
		// checking
		assertEquals( 2, d.color() );
		assertEquals( 2, e.color() );
		for ( v in d.vs ) {
			var p : A = cast v.adj;
			while ( null != p ) {
				check_property( cast v, p );
				p = cast p._next;
			}
		}
		for ( v in e.vs ) {
			var p : A = cast v.adj;
			while ( null != p ) {
				check_property( cast v, p );
				p = cast p._next;
			}
		}
		trace( 'Crown graph, order A: {number of vertices = ' + d.nV + ', number of arcs = ' + d.nA + ', chromatic_number = ' + d.chromatic_number + '}' );
		trace( 'Crown graph, order B: {number of vertices = ' + e.nV + ', number of arcs = ' + e.nA + ', chromatic_number = ' + e.chromatic_number + '}' );
		
	}
	#end
}