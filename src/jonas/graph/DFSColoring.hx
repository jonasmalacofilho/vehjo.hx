package jonas.graph;

import jonas.graph.Digraph;
import jonas.graph.DigraphGenerator;
import jonas.graph.Graph;
import jonas.MathExtension;
import jonas.sort.Heapsort;

/*
 * Deep-first-search proper graph coloring
 * Suboptimal solution
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
 
class DFSColoringVertex extends GraphVertex {
	public var color : Int;
	override public function toString() : String { return super.toString() + '(color=' + color + ')'; }
}

class DFSColoringGraph<V : DFSColoringVertex, A : Arc> extends Graph<V, A> {
	
	// number of colors used in the coloring >= chromatic number
	public var ncolors( default, null ) : Int;
	
	public function color() : Int {
		return color_v2();
	}
	
	// O( V * ncolors + A )
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
	
	// v1: DFS
	// O( V ) + O( color_rec )
	// => O( V + A + V * ncolors )
	public function color_v1() : Int {
		// setup
		for ( v in vs )
			v.color = -1;
		ncolors = 0;
		
		// dfs
		for ( v in vs )
			if ( -1 == v.color )
				ncolors = color_rec( ncolors, v );
		
		return ncolors;
	}
	
	// v2: order independent DFS
	// heuristic: prefer larger vertex degree
	// color_v1 + heapsort( arcs ) + heapsort( vertices )
	// O( A + V * ( 1 + log( V ) ) ), on average
	// O( A + V * ( 1 + log( V ) + log( A ) ) ), on worst case
	public function color_v2() : Int {
		// setup
		for ( v in vs )
			v.color = -1;
		ncolors = 0;
		
		// sort adjacencies by degree (desc)
		order_arcs( function( a, b ) { return untyped a.w.degree() < b.w.degree(); } );
		
		// sort vertices by degree (desc)
		var ws = Heapsort.heapsort( vs, function( a, b ) { return a.degree() < b.degree(); } );
		
		// dfs
		for ( v in ws )
			if ( -1 == v.color )
				ncolors = color_rec( ncolors, v );
		
		return ncolors;
	}
	
}