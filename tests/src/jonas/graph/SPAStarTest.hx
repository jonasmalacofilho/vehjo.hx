package jonas.graph;

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

private class Point extends SPAStarVertex {
	public var x : Float;
	public var y : Float;
	public function new( x : Float, y : Float ) {
		this.x = x;
		this.y = y;
		super();
	}
}

private typedef V = Point;
private typedef A = SPArc;
private typedef D = SPAStarDigraph<V, A>;

class SPAStarTest extends DigraphStructuralTest<D, V, A> {
	
	override function digraph( ?params : Array<Dynamic> ) : D {
		return cast new D( dist );
	}
	
	override function vertex( ?params : Array<Dynamic> ) : V {
		if ( null == params || params.length < 2 )
			params = [ 2, 3 ];
		return cast new V( params[0], params[1] );
	}
	
	override function arc( ?params : Array<Dynamic> ) : A {
		if ( null == params || params.length < 1 )
			params = [ 100 ];
		return cast new A( params[0] );
	}
	
	// point distance -> used as heuristic
	function dist( a : V, b : V ) {
		return Math.sqrt( ( a.x - b.x ) * ( a.x - b.x ) + ( a.y - b.y ) * ( a.y - b.y ) );
	}

	public function test_random() : Void {
		
		// building the test digraph
		var nV = 100;
		var nA = 500;
		d = new RandomDigraph(
			d,
			function() { return new V( Math.random() * 100, Math.random() * 100 ); },
			function( v, w ) { return new A( dist( v, w ) * ( 1 + Math.random() ) ); },
			nV,
			nA
		).dg;
		d.use_heuristic = true;
		
		// path validation (does not check if it is an optimal one)
		for ( v in d.vertices() )
			for ( w in d.vertices() ) {
				d.compute_shortest_path( v, w );
				assertTrue( d.check_path( v, w ) );
			}
		
		// comparing Dijkstra and A*
		var dijkstra_visited = 0;
		var astar_visited = 0;
		for ( v in d.vertices() ) {
			for ( w in d.vertices() ) {
				d.use_heuristic = false;
				d.compute_shortest_path( v, w );
				for ( z in d.vertices() ) {
					if ( null != z.parent )
						dijkstra_visited++;
				}
				var dijkstra_cst = w.cost;
				
				d.use_heuristic = true;
				d.compute_shortest_path( v, w );
				for ( z in d.vertices() ) {
					if ( null != z.parent )
						astar_visited++;
				}
				var astar_cst = d.get_vertex( w.vi ).cost;
				
				if ( Math.isNaN( dijkstra_cst ) )
					assertTrue( Math.isNaN( astar_cst ) );
				else
					assertTrue( !Math.isNaN( astar_cst ) && dijkstra_cst == astar_cst );
			}
		}
		trace( 'A* visited ' + Math.round( ( dijkstra_visited - astar_visited ) * 100 / dijkstra_visited ) + '% less vertices than Dijkstra\'s algorithm' );
		assertTrue( dijkstra_visited > astar_visited );
		
	}
	
	public function test_valid_fail_cost() : Void {
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		var a = d.add_arc( v, w, arc( [ -.2 ] ) );
		assertFalse( d.valid() );
	}
	
	public function test_valid_fail_heuristic() : Void {
		var v = d.add_vertex( vertex( [ 10, 20 ] ) );
		var w = d.add_vertex( vertex( [ 20, 10 ] ) );
		var a = d.add_arc( v, w, arc( [ .99 * dist( v, w ) ] ) );
		assertFalse( d.valid() );
	}
	
}