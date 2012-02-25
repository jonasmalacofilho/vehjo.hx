package jonas.graph;

import jonas.graph.Digraph;

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
 
class ColoringDigraphVertex extends Vertex {
	public var color : Int;
}

class ColoringDigraph<V : ColoringDigraphVertex, A : Arc> extends Digraph<V, A> {
	
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
	
	#if debug
	override public function test_example() : Void {
		// http://en.wikipedia.org/wiki/Greedy_coloring
		
		// construction
		var arc_constructor = function( v, w ) { return new Arc( w ); };
		// order A
		var d = new ColoringDigraph();
		for ( i in 0...9 )
			d.add_vertex( new ColoringDigraphVertex() );
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
		var e = new ColoringDigraph();
		for ( i in 0...9 )
			e.add_vertex( new ColoringDigraphVertex() );
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
		
	}
	public function test_Petersen() : Void {
		// http://en.wikipedia.org/wiki/Petersen_graph
		
		// construction
		var arc_constructor = function( v, w ) { return new Arc( w ); };
		var d = new ColoringDigraph();
		for ( i in 0...10 )
			d.add_vertex( new ColoringDigraphVertex() );
		d.add_edge( d.get_vertex( 0 ), d.get_vertex( 1 ), arc_constructor );
		d.add_edge( d.get_vertex( 0 ), d.get_vertex( 4 ), arc_constructor );
		d.add_edge( d.get_vertex( 0 ), d.get_vertex( 5 ), arc_constructor );
		d.add_edge( d.get_vertex( 1 ), d.get_vertex( 0 ), arc_constructor );
		d.add_edge( d.get_vertex( 1 ), d.get_vertex( 2 ), arc_constructor );
		d.add_edge( d.get_vertex( 1 ), d.get_vertex( 6 ), arc_constructor );
		d.add_edge( d.get_vertex( 2 ), d.get_vertex( 1 ), arc_constructor );
		d.add_edge( d.get_vertex( 2 ), d.get_vertex( 3 ), arc_constructor );
		d.add_edge( d.get_vertex( 2 ), d.get_vertex( 7 ), arc_constructor );
		d.add_edge( d.get_vertex( 3 ), d.get_vertex( 2 ), arc_constructor );
		d.add_edge( d.get_vertex( 3 ), d.get_vertex( 4 ), arc_constructor );
		d.add_edge( d.get_vertex( 3 ), d.get_vertex( 8 ), arc_constructor );
		d.add_edge( d.get_vertex( 4 ), d.get_vertex( 0 ), arc_constructor );
		d.add_edge( d.get_vertex( 4 ), d.get_vertex( 3 ), arc_constructor );
		d.add_edge( d.get_vertex( 4 ), d.get_vertex( 9 ), arc_constructor );
		d.add_edge( d.get_vertex( 5 ), d.get_vertex( 0 ), arc_constructor );
		d.add_edge( d.get_vertex( 5 ), d.get_vertex( 7 ), arc_constructor );
		d.add_edge( d.get_vertex( 5 ), d.get_vertex( 8 ), arc_constructor );
		d.add_edge( d.get_vertex( 6 ), d.get_vertex( 1 ), arc_constructor );
		d.add_edge( d.get_vertex( 6 ), d.get_vertex( 8 ), arc_constructor );
		d.add_edge( d.get_vertex( 6 ), d.get_vertex( 9 ), arc_constructor );
		d.add_edge( d.get_vertex( 7 ), d.get_vertex( 2 ), arc_constructor );
		d.add_edge( d.get_vertex( 7 ), d.get_vertex( 5 ), arc_constructor );
		d.add_edge( d.get_vertex( 7 ), d.get_vertex( 9 ), arc_constructor );
		d.add_edge( d.get_vertex( 8 ), d.get_vertex( 3 ), arc_constructor );
		d.add_edge( d.get_vertex( 8 ), d.get_vertex( 5 ), arc_constructor );
		d.add_edge( d.get_vertex( 8 ), d.get_vertex( 6 ), arc_constructor );
		d.add_edge( d.get_vertex( 9 ), d.get_vertex( 4 ), arc_constructor );
		d.add_edge( d.get_vertex( 9 ), d.get_vertex( 6 ), arc_constructor );
		d.add_edge( d.get_vertex( 9 ), d.get_vertex( 7 ), arc_constructor );
		assertEquals( 10, d.nV );
		assertEquals( 30, d.nA );
		
		// checking
		assertEquals( 3, d.color() );
		
	}
	#end
}