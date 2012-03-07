package jonas.graph;

import jonas.graph.Digraph;

/*
 * Path existance (performing a DFS)
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

class PathExistanceVertex extends Vertex {
	public var parent : PathExistanceVertex;
	override public function toString() : String { return super.toString() + '(parent=' + ( null != parent ? parent.vi : null ) + ')'; }
}

class PathExistanceDigraph<V : PathExistanceVertex, A : Arc> extends Digraph<V, A> {
	
	function compute_dfs_path_rec( v : V ) : Void {
		var p : A = cast v.adj;
		while ( null != p ) {
			var w : V = cast p.w;
			if ( null == w.parent ) {
				w.parent = v;
				compute_dfs_path_rec( w );
			}
			p = cast p._next;
		}
	}
	
	// computes a path between s and t (performing a DFS)
	public function compute_dfs_path( s : V, t : V ) : Bool {
		check_has_vertex( s );
		check_has_vertex( t );
		
		for ( v in vs )
			v.parent = null;
		s.parent = s;
		compute_dfs_path_rec( s );
		
		if ( null != t.parent )
			return true;
		return false;
	}
	
	// path reconstruction
	public function get_path( t : V ) : List<V> {
		check_has_vertex( t );
		
		var p = new List();
		
		if ( null == t.parent )
			return p;
		
		var w = t;
		while ( w != w.parent ) {
			p.push( w );
			w = cast w.parent;
		}
		p.push( w );
		
		return p;
	}
	
	// st-cuts
	public function is_st_cut( s : V, t : V ) : Bool {
		check_has_vertex( s );
		check_has_vertex( t );
		
		// unvisited s or visited t => dfs not run, or st is not a st-cut
		if ( null == s.parent || null != t.parent )
			return false;
		
		for ( v in vs ) {
			var p : A = cast v.adj;
			while ( null != p ) {
				var w : V = cast p.w;
				// visited v and unvisited w => bad dfs
				if ( null != v.parent && null == w.parent )
					return false;
				p = cast p._next;
			}
		}
		
		return true;
	}

	// check if the stored arborescence is valid for the pair (s, t)
	// if t.parent == null, st must be a st-cut
	// if t.parent != null, the origin of the path from s to t must be valid
	public function check_path( s : V, t : V ) : Bool {
		check_has_vertex( s );
		check_has_vertex( t );
		
		if ( null != t.parent ) {
			var w = t;
			while ( w != w.parent ) {
				if ( null == get_arc( cast w.parent, w ) )
					return false;
				w = cast w.parent;
			}
			return true;
		}
		else {
			return is_st_cut( s, t );
		}
		
	}
	
}