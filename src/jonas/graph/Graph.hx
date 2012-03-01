package jonas.graph;

import jonas.graph.Digraph;

/*
 * Graph: basic graph (simetric digraph)
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

class GraphVertex extends Vertex {
	
	public inline function inbound_degree() : Int {
		return outbound_degree();
	}
	
	public inline function degree() : Int {
		return outbound_degree();
	}
	
}
 
class Graph<V : Vertex, A : Arc> extends Digraph<V, A> {

	override public function valid() : Bool {
		return is_symmetric();
	}
	
	function components_rec( v : Vertex, c : Int, cs : Array<Int> ) : Void {
		cs[v.vi] = c;
		var p : A = cast v.adj; while ( null != p ) {
			if ( -1 == cs[p.w.vi] )
				components_rec( cast p.w, c, cs );
			p = cast p._next;
		}
	}
	
	public function components() : Array<Array<V>> {
		
		var cs = [];
		for ( i in 0...nV )
			cs.push( -1 );
		
		var c = 0;
		for ( i in 0...nV )
			if ( -1 == cs[i] )
				components_rec( cast vs[i], c++, cs );
		
		var components = [];
		for ( i in 0...c )
			components.push( [] );
		
		for ( i in 0...nV )
			components[cs[i]].push( cast vs[i] );
		
		return components;
	}
	
}