package jonas.graph;

import jonas.graph.DigraphGenerator;
import jonas.graph.SP;
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


class SPDijkstraTest extends DigraphTest {
	
	override public function test_basic() : Void {
		// building the test digraph
		var nV = 100;
		var nA = 500;
		var d = new RandomDigraph(
			new SPDijkstraDigraph<SPDijkstraVertex, SPArc>(),
			function() { return new SPDijkstraVertex(); },
			function( v, w ) { return new SPArc( w, Math.random() * 20000 ); },
			nV,
			nA
		).dg;
		assertTrue( d.valid() );
		
		// path validation (does not check if it is an optimal one)
		for ( v in d.vertices() ) {
			d.compute_spt( v );
			for ( w in d.vertices() )
				assertTrue( d.check_path( v, w ) );
		}
		
		// dijkstra cost <= dfs cost, no NaN costs
		// or
		// both costs are NaN
		for ( v in d.vertices() ) {
			for ( w in d.vertices() ) {
				d.compute_shortest_path( v, w );
				var dijkstra_cst = w.cost;
				d.compute_dfs_path( v, w );
				var dfs_cst = w.cost;
				if ( Math.isNaN( dfs_cst ) )
					assertTrue( Math.isNaN( dijkstra_cst ) );
				else
					assertTrue( !Math.isNaN( dijkstra_cst ) && dijkstra_cst <= dfs_cst );
			}
		}
		
		// TODO optimal cost
		// ?!?!
	}
	
	override public function test_bad_input() : Void {
		super.test_bad_input();
		
		// building the reference digraph
		var nV = 50;
		var nA = 150;
		var d = new RandomDigraph(
			new SPDijkstraDigraph<SPDijkstraVertex, SPArc>(),
			function() { return new SPDijkstraVertex(); },
			function( v, w ) { return new SPArc( w, Math.random() * 20000 ); },
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
					p.cost = - 1000 * Math.random();
				p = cast p._next;
			}
		}
		
		assertFalse( d.valid() );
	}
	
}