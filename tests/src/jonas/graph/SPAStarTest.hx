package jonas.graph;

import jonas.graph.DigraphGenerator;
import jonas.graph.SP;
import jonas.graph.SPAStar;
import jonas.graph.SPDijkstra;

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

private class Point extends SPAStarVertex {
	public var x : Float;
	public var y : Float;
	public function new( x : Float, y : Float ) {
		this.x = x;
		this.y = y;
		super();
	}
}

class SPAStarTest extends SPDijkstraTest {

	override public function test_basic() : Void {
		
		// point distance -> used as heuristic
		var dist = function( a : Point, b : Point ) { return Math.sqrt( ( a.x - b.x ) * ( a.x - b.x ) + ( a.y - b.y ) * ( a.y - b.y ) ); };
		
		// building the reference digraph
		var nV = 100;
		var nA = 500;
		var d = new RandomDigraph(
			new SPDijkstraDigraph<Point, SPArc>(),
			function() { return new Point( Math.random() * 100, Math.random() * 100 ); },
			function( v, w ) { return new SPArc( w, dist( v, w ) * ( 1 + Math.random() ) ); },
			nV,
			nA
		).dg;
		assertTrue( d.valid() );
		
		// building the test digraph
		var e = new SPAStarDigraph( dist );
		for ( v in d.vertices() )
			e.add_vertex( new Point( v.x, v.y ) );
		for ( v in d.vertices() ) {
			var p : SPArc = cast v.adj;
			while ( null != p ) {
				e.add_arc( e.get_vertex( v.vi ), new SPArc( e.get_vertex( p.w.vi ), p.cost ) );
				p = cast p._next;
			}
		}
		assertTrue( e.valid() );
		
		// path validation (does not check if it is an optimal one)
		for ( v in e.vertices() )
			for ( w in e.vertices() ) {
				e.compute_shortest_path( v, w );
				assertTrue( e.check_path( v, w ) );
			}
		
		// comparing Dijkstra and A*
		var dijkstra_visited = 0;
		var astar_visited = 0;
		for ( v in d.vertices() ) {
			for ( w in d.vertices() ) {
				d.compute_shortest_path( v, w );
				e.compute_shortest_path( e.get_vertex( v.vi ), e.get_vertex( w.vi ) );
				
				for ( z in d.vertices() ) {
					if ( null != z.parent )
						dijkstra_visited++;
					if ( null != e.get_vertex( z.vi ).parent )
						astar_visited++;
				}
				
				var dijkstra_cst = w.cost;
				var astar_cst = e.get_vertex( w.vi ).cost;
				if ( Math.isNaN( dijkstra_cst ) )
					assertTrue( Math.isNaN( astar_cst ) );
				else
					assertTrue( !Math.isNaN( astar_cst ) && dijkstra_cst == astar_cst );
			}
		}
		trace( 'A* visited ' + Math.round( ( dijkstra_visited - astar_visited ) * 100 / dijkstra_visited ) + '% less vertices than Dijkstra\'s algorithm' );
		assertTrue( dijkstra_visited > astar_visited );
		
	}
	
	override public function test_bad_input() : Void {
		super.test_bad_input();
		
		// point distance -> used as heuristic
		var dist = function( a : Point, b : Point ) { return Math.sqrt( ( a.x - b.x ) * ( a.x - b.x ) + ( a.y - b.y ) * ( a.y - b.y ) ); };
		
		// building the reference digraph
		var nV = 50;
		var nA = 150;
		var d = new RandomDigraph(
			new SPAStarDigraph<Point, SPArc>( dist ),
			function() { return new Point( Math.random() * 100, Math.random() * 100 ); },
			function( v, w ) { return new SPArc( w, dist( v, w ) * ( 1 + Math.random() ) ); },
			nV,
			nA
		).dg;
		
		assertTrue( d.valid() );
		
		var n = Std.random( nA );
		var cnt = 0;
		for ( v in d.vertices() ) {
			var p : SPArc = cast v.adj;
			while ( null != p ) {
				if ( n == cnt++ )
					p.cost = Math.random() * dist( v, cast p.w ) * .5;
				p = cast p._next;
			}
		}
		
		assertFalse( d.valid() );
	}
	
}