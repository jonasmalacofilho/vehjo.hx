package jonas.graph;

import jonas.graph.DFSColoring;
import jonas.graph.Digraph;
import jonas.graph.DigraphGenerator;

/*
 * This is part of jonas.graph test cases
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

class DFSColoringTest extends DigraphTest {
	
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
	
	override public function test_basic() : Void {
		
		// construction
		// http://en.wikipedia.org/wiki/Greedy_coloring
		var arc_constructor = function( v, w ) { return new Arc( w ); };
		// order A
		var d = new DFSColoringGraph();
		for ( i in 0...9 )
			d.add_vertex( new DFSColoringVertex() );
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
		var e = new DFSColoringGraph();
		for ( i in 0...9 )
			e.add_vertex( new DFSColoringVertex() );
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
		
		// testing
		assertEquals( 2, d.color_v1() );
		assertEquals( 2, e.color_v1() );
		check_arc_colors( d );
		check_arc_colors( e );
		trace( 'Example digraph, order A: ' + d );
		trace( 'Example digraph, order B: ' + e );
		
		// testing v2
		assertEquals( 2, d.color_v2() );
		assertEquals( 2, e.color_v2() );
		check_arc_colors( d );
		check_arc_colors( e );
		trace( 'Example digraph, order A, v2: ' + d );
		trace( 'Example digraph, order B, v2: ' + e );
		
	}
	
}

class DFSColoringTestPetersen extends DFSColoringTest {
	
	override public function test_basic() : Void {
		
		// construction
		var vertex_constructor = function() { return new DFSColoringVertex(); };
		var arc_constructor = function( v, w ) { return new Arc( w ); };
		var d = new PetersenGraph( new DFSColoringGraph<DFSColoringVertex, Arc>(), vertex_constructor, arc_constructor ).dg;
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
	
}

class DFSColoringTestRandom extends DFSColoringTest {

	override public function test_basic() : Void {
		
		// construction
		var nV = 10000;
		var nE = 100000;
		var vertex_constructor = function() { return new DFSColoringVertex(); };
		var arc_constructor = function( v, w ) { return new Arc( w ); };
		var d = new RandomGraph( new DFSColoringGraph<DFSColoringVertex, Arc>(), vertex_constructor, arc_constructor, nV, nE ).dg;
		assertEquals( nV, d.nV );
		assertEquals( nE, 2 * d.nA );
		
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
	
}

class DFSColoringTestCrown extends DFSColoringTest {

	override public function test_basic() : Void {
		
		// construction
		var vertex_constructor = function() { return new DFSColoringVertex(); };
		var arc_constructor = function( v, w ) { return new Arc( w ); };
		var n = 100;
		var d = new CrownGraph( new DFSColoringGraph<DFSColoringVertex, Arc>(), vertex_constructor, arc_constructor, n, 0 ).dg;
		var e = new CrownGraph( new DFSColoringGraph<DFSColoringVertex, Arc>(), vertex_constructor, arc_constructor, n, 1 ).dg;
		assertEquals( 2 * n, d.nV );
		assertEquals( 2 * n * ( n - 1 ), d.nA );
		
		// test
		assertEquals( 2, d.color_v1() );
		assertEquals( 2, e.color_v1() );
		check_arc_colors( d );
		check_arc_colors( e );
		trace( 'Crown graph, order A: {number of vertices = ' + d.nV + ', number of arcs = ' + d.nA + ', ncolors = ' + d.ncolors + '}' );
		trace( 'Crown graph, order B: {number of vertices = ' + e.nV + ', number of arcs = ' + e.nA + ', ncolors = ' + e.ncolors + '}' );
		
		// test v2
		assertEquals( 2, d.color_v2() );
		assertEquals( 2, e.color_v2() );
		check_arc_colors( d );
		check_arc_colors( e );
		trace( 'Crown graph, order A, v2: {number of vertices = ' + d.nV + ', number of arcs = ' + d.nA + ', ncolors = ' + d.ncolors + '}' );
		trace( 'Crown graph, order B, v2: {number of vertices = ' + e.nV + ', number of arcs = ' + e.nA + ', ncolors = ' + e.ncolors + '}' );
		
	}
	
}