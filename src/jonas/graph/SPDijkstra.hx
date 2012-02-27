package jonas.graph;

import jonas.ds.queue.PriorityQueue;
import jonas.graph.SP;

/*
 * Dijkstra algorithm for shortest paths
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

class SPDijkstraVertex extends SPVertex {
	public var _queue_index : Int;
}

class SPDijkstra<V : SPDijkstraVertex, A : SPArc> extends SP<V, A> {
	
	// Dijkstra
	function dijkstra( s : V, ? t : V ) : Void {
		// init
		for ( i in 0...nV ) {
			var v : V = cast vs[i];
			v.cost = Math.NaN;
			v.parent = null;
		}
		s.cost = 0.;
		s.parent = s;
		var q = new PriorityQueue( nV );
		q.predicate = function( a : V, b : V ) { return a.cost <= b.cost; };
		q.update_index = function( a : V, i : Int ) { a._queue_index = i; };
		q.put( s );
		
		// bfs
		while ( q.not_empty() ) {
			var v = q.get();
			if ( null != t && t == v )
				break;
			var p : A = cast v.adj; while ( null != p ) {
				var w : V = cast p.w;
				if ( Math.isNaN( w.cost ) ) {
					w.cost = v.cost + p.cost;
					w.parent = v;
					q.put( w );
				}
				else if ( w.cost > v.cost + p.cost ) {
					w.cost = v.cost + p.cost;
					w.parent = v;
					q.update( w._queue_index );
				}
				p = cast p._next;
			}
		}
	}
	
	// shortest path tree
	public function compute_tree( s : V ) : Void {
		dijkstra( s );
	}
	
	// shortest path
	public function compute_path( s : V, t : V ) : Void {
		dijkstra( s, t );
	}
	
}