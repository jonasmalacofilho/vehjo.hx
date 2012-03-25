package jonas.graph;

import jonas.graph.Digraph;

/*
 * 
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
/*
class DigraphPlusVertex extends Vertex {
	
	public var iadj : DigraphPlusArc; // ibound adjacency list head
	public function new() { iadj = null; super(); }
	
	public function inbound_degree() : Int {
		var cnt = 0;
		var p = iadj;
		while ( null != p ) {
			cnt++;
			p = p._inext;
		}
		return cnt;
	}
	
	override public function toString() : String {
		return Std.string( vi );
	}
	
}

class DigraphPlusArc extends Arc {
	
	public var v : Vertex; // set by the Digraph on insertion
	public var _inext : DigraphPlusArc; // ibound adjacency list next pointer; set by the Digraph on insertion
	
	public function new( w ) { _inext = null; super( w ); }
	
	override public function toString() : String {
		return v.vi + '-' + w.vi;
	}
	
}

class DigraphPlus<V : DigraphPlusVertex, A : DigraphPlusArc> extends Digraph<V, A> {
	
	override public function add_arc( v : V, a : A, ?unsafe : Bool = false, ?fast : Bool = false ) : A {
		var w : V = cast a.w;
		
		// vertices belong to this digraph?
		check_has_vertex( v );
		check_has_vertex( w );
		
		// malformed add_arc request?
		if ( v == w )
			throw 'Arc v-v not allowed';
		if ( null != a._next )
			throw 'a._next must be null';
		if ( null != a._inext )
			throw 'a._inext must be null';
		if ( null != a.v )
			throw 'a.v must be null';
		
		// remove existing arc v-w? (for most algorithms there can't be 2 arcs v-w)
		if ( !unsafe )
			remove_arc( v, w );
		
		// list insertion constraints
		if ( fast ) { // a becames head of v.adj and w.iadj
			// adj
			a._next = v.adj;
			v.adj = a;
			// iadj
			a._inext = w.iadj;
			w.iadj = a;
		}
		else { // a goes to the tail end of v.adj and w.iadj
			// adj
			var p = v.adj;
			var q = null;
			while ( null != p ) {
				q = p;
				p = p._next;
			}
			if ( null == q )
				v.adj = a;
			else
				q._next = a;
			// iadj
			var p = w.iadj;
			var q = null;
			while ( null != p ) {
				q = p;
				p = p._inext;
			}
			if ( null == q )
				w.iadj = a;
			else
				q._next = a;
		}
		
		a.v = v;
		nA++;
		return a;
	}
	
	override public function remove_arc( v : V, w : V ) : Bool {
		check_has_vertex( v );
		check_has_vertex( w );
		var adj = false;
		var iadj = false;
		
		var p = v.adj;
		var q = null;
		while ( null != p ) {
			if ( w == p.w ) {
				if ( null == q )
					v.adj = p._next;
				else
					q._next = p._next;
				p._next = null;
				adj = true;
			}
			q = p;
			p = p._next;
		}
		var p = w.iadj;
		var q = null;
		while ( null != p ) {
			if ( w == p.w ) {
				if ( null == q )
					w.adj = p._inext;
				else
					q._inext = p._inext;
				p._inext = null;
				iadj = true;
			}
			q = p;
			p = p._inext;
		}
		if ( adj && iadj )
			return true;
		else if ( adj || iadj )
			throw 'Digraph structure state has been compromised: item could not be removed from ' + ( iadj ? 'outbound' : 'inbound' ) + ' adjacency list'; 
		return false;
	}
	
}
*/