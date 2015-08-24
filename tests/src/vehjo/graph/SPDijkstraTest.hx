package vehjo.graph;

import vehjo.graph.DigraphGenerator;

/*
 * This is part of vehjo.graph test cases
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

private typedef V = SPDijkstraVertex;
private typedef A = SPArc;
private typedef D = SPDijkstraDigraph<V, A>;

class SPDijkstraTest extends DigraphStructuralTest<D, V, A> {
	
	override function digraph( ?params : Array<Dynamic> ) : D {
		return cast new D();
	}
	
	override function vertex( ?params : Array<Dynamic> ) : V {
		return cast new V();
	}
	
	override function arc( ?params : Array<Dynamic> ) : A {
		if ( null == params || params.length < 1 )
			params = [ 3.14 ];
		return cast new A( params[0] );
	}
	
	public function test_random() : Void {
		// building the test digraph
		var nV = 100;
		var nA = 500;
		d = new RandomDigraph(
			d,
			function() { return vertex(); },
			function( v, w ) { return arc( [ Math.random() * 2000 ] ); },
			nV,
			nA
		).dg;
		
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
	
	public function test_valid_fail_cost() : Void {
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		var a = d.add_arc( v, w, arc( [ -.2 ] ) );
		assertFalse( d.valid() );
	}
	
}