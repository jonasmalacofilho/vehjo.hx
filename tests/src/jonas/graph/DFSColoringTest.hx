package jonas.graph;

import jonas.graph.DigraphGenerator;

/*
 * This is part of jonas.graph test suite
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

private typedef V = DFSColoringVertex;
private typedef A = Arc;
private typedef D = DFSColoringGraph<V, A>;

class DFSColoringTest extends GraphStructuralTest<D, V, A> {
	
	override function digraph( ?params : Array<Dynamic> ) : D {
		return cast new D();
	}
	
	override function vertex( ?params : Array<Dynamic> ) : V {
		return cast new V();
	}
	
	override function arc( ?params : Array<Dynamic> ) : A {
		return cast new A();
	}
	
	function check_arc_colors( d : DFSColoringGraph<DFSColoringVertex, Arc> ) : Void {
		for ( v in d.vertices() ) {
			var p = v.adj;
			while ( null != p ) {
				var w : DFSColoringVertex = cast p.w;
				assertFalse( v.color == w.color );
				p = cast p._next;
			}
		}
	}
	
	public function test_greedy_example_A() : Void {
	// http://en.wikipedia.org/wiki/Greedy_coloring
		
		// construction
		var arc_constructor = function( v, w ) { return arc(); };
		for ( i in 0...9 )
			d.add_vertex( vertex() );
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
		
		// testing
		assertEquals( 2, d.color_v1() );
		check_arc_colors( d );
		trace( 'Example digraph, order A: ' + d );
		
		// testing v2
		assertEquals( 2, d.color_v2() );
		check_arc_colors( d );
		trace( 'Example digraph, order A, v2: ' + d );
	}
	
	public function test_greedy_example_B() : Void {
		// order B
		var arc_constructor = function( v, w ) { return arc(); };
		for ( i in 0...9 )
			d.add_vertex( vertex() );
		d.add_edge( d.get_vertex( 1 ), d.get_vertex( 4 ), arc_constructor );
		d.add_edge( d.get_vertex( 1 ), d.get_vertex( 6 ), arc_constructor );
		d.add_edge( d.get_vertex( 1 ), d.get_vertex( 8 ), arc_constructor );
		d.add_edge( d.get_vertex( 2 ), d.get_vertex( 3 ), arc_constructor );
		d.add_edge( d.get_vertex( 2 ), d.get_vertex( 5 ), arc_constructor );
		d.add_edge( d.get_vertex( 2 ), d.get_vertex( 7 ), arc_constructor );
		d.add_edge( d.get_vertex( 3 ), d.get_vertex( 2 ), arc_constructor );
		d.add_edge( d.get_vertex( 3 ), d.get_vertex( 6 ), arc_constructor );
		d.add_edge( d.get_vertex( 3 ), d.get_vertex( 8 ), arc_constructor );
		d.add_edge( d.get_vertex( 4 ), d.get_vertex( 1 ), arc_constructor );
		d.add_edge( d.get_vertex( 4 ), d.get_vertex( 5 ), arc_constructor );
		d.add_edge( d.get_vertex( 4 ), d.get_vertex( 7 ), arc_constructor );
		d.add_edge( d.get_vertex( 5 ), d.get_vertex( 2 ), arc_constructor );
		d.add_edge( d.get_vertex( 5 ), d.get_vertex( 4 ), arc_constructor );
		d.add_edge( d.get_vertex( 5 ), d.get_vertex( 8 ), arc_constructor );
		d.add_edge( d.get_vertex( 6 ), d.get_vertex( 1 ), arc_constructor );
		d.add_edge( d.get_vertex( 6 ), d.get_vertex( 3 ), arc_constructor );
		d.add_edge( d.get_vertex( 6 ), d.get_vertex( 7 ), arc_constructor );
		d.add_edge( d.get_vertex( 7 ), d.get_vertex( 2 ), arc_constructor );
		d.add_edge( d.get_vertex( 7 ), d.get_vertex( 4 ), arc_constructor );
		d.add_edge( d.get_vertex( 7 ), d.get_vertex( 6 ), arc_constructor );
		d.add_edge( d.get_vertex( 8 ), d.get_vertex( 1 ), arc_constructor );
		d.add_edge( d.get_vertex( 8 ), d.get_vertex( 3 ), arc_constructor );
		d.add_edge( d.get_vertex( 8 ), d.get_vertex( 5 ), arc_constructor );
		assertEquals( 9, d.nV );
		assertEquals( 24, d.nA );
		
		// testing
		assertEquals( 2, d.color_v1() );
		check_arc_colors( d );
		trace( 'Example digraph, order B: ' + d );
		
		// testing v2
		assertEquals( 2, d.color_v2() );
		check_arc_colors( d );
		trace( 'Example digraph, order B, v2: ' + d );
		
	}
	
	public function test_Petersen() : Void {
		
		// construction
		var vertex_constructor = function() { return vertex(); };
		var arc_constructor = function( v, w ) { return arc(); };
		d = new PetersenGraph( d, vertex_constructor, arc_constructor ).dg;
		assertEquals( 10, d.nV );
		assertEquals( 30, d.nA );
		
		// test
		assertEquals( 3, d.color_v1() );
		check_arc_colors( d );
		trace( 'Petersen graph: ' + d );
		
		// test v2
		assertEquals( 3, d.color_v2() );
		check_arc_colors( d );
		trace( 'Petersen graph, v2: ' + d );
		
	}

	public function test_random() : Void {
		
		// construction
		var nV = 1000;
		var nE = 10000;
		var vertex_constructor = function() { return vertex(); };
		var arc_constructor = function( v, w ) { return arc(); };
		d = new RandomGraph( d, vertex_constructor, arc_constructor, nV, nE ).dg;
		assertEquals( nV, d.nV );
		assertEquals( 0, d.nA % 2 );
		assertEquals( nE, Math.floor( d.nA / 2 ) );
		
		// test
		var t = d.color_v1();
		//trace( 'Random digraph: ' + d );
		check_arc_colors( d );
		trace( 'Random graph: {number of vertices = ' + d.nV + ', number of arcs = ' + d.nA + ', ncolors = ' + d.ncolors + '}' );
		
		// test v2
		var t2 = d.color_v2();
		//trace( 'Random digraph: ' + d );
		check_arc_colors( d );
		assertTrue( t2 <= t );
		trace( 'Random graph, v2: {number of vertices = ' + d.nV + ', number of arcs = ' + d.nA + ', ncolors = ' + d.ncolors + '}' );
		
	}
	
	public function test_Crown_A() : Void {
		
		// construction
		var vertex_constructor = function() { return vertex(); };
		var arc_constructor = function( v, w ) { return arc(); };
		var n = 100;
		d = new CrownGraph( d, vertex_constructor, arc_constructor, n, 0 ).dg;
		assertEquals( 2 * n, d.nV );
		assertEquals( 2 * n * ( n - 1 ), d.nA );
		
		// test
		assertEquals( 2, d.color_v1() );
		check_arc_colors( d );
		trace( 'Crown graph, order A: {number of vertices = ' + d.nV + ', number of arcs = ' + d.nA + ', ncolors = ' + d.ncolors + '}' );
		
		// test v2
		assertEquals( 2, d.color_v2() );
		check_arc_colors( d );
		trace( 'Crown graph, order A, v2: {number of vertices = ' + d.nV + ', number of arcs = ' + d.nA + ', ncolors = ' + d.ncolors + '}' );
		
	}
	
	public function test_Crown_B() : Void {
		
		// construction
		var vertex_constructor = function() { return vertex(); };
		var arc_constructor = function( v, w ) { return arc(); };
		var n = 100;
		d = new CrownGraph( d, vertex_constructor, arc_constructor, n, 1 ).dg;
		assertEquals( 2 * n, d.nV );
		assertEquals( 2 * n * ( n - 1 ), d.nA );
		
		// test
		assertEquals( 2, d.color_v1() );
		check_arc_colors( d );
		trace( 'Crown graph, order B: {number of vertices = ' + d.nV + ', number of arcs = ' + d.nA + ', ncolors = ' + d.ncolors + '}' );
		
		// test v2
		assertEquals( 2, d.color_v2() );
		check_arc_colors( d );
		trace( 'Crown graph, order B, v2: {number of vertices = ' + d.nV + ', number of arcs = ' + d.nA + ', ncolors = ' + d.ncolors + '}' );
		
	}
	
}