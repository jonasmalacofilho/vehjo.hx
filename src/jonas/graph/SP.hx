package jonas.graph;

import jonas.graph.Digraph;

/*
 * Generic shortest path algorithm
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

class SPVertex extends Vertex {
	public var cost : Float;
	public var parent : SPVertex;
}

class SPArc extends Arc {
	public var cost : Float;
	public function new( w, cost ) {
		this.cost;
		super( w );
	}
}

class SP<V : SPVertex, A : SPArc> extends Digraph<V, A> {
	
	public function get_path( t : V ) : List<V> {
		var p = new List();
		var w = t;
		while ( w != w.parent ) {
			p.push( w );
			w = cast w.parent;
		}
		p.push( w );
		return p;
	}
	
}