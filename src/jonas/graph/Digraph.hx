package jonas.graph;
import jonas.sort.Heapsort;

/*
 * Digraph: basic directed graph
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

class Vertex {
	
	public var vi : Null<Int>;
	public var adj : Arc;
	public function new() { vi = null;  adj = null; }
	
	public function outbound_degree() : Int {
		var cnt = 0;
		var p = adj;
		while ( null != p ) {
			cnt++;
			p = p._next;
		}
		return cnt;
	}
	
	public function toString() : String {
		return Std.string( vi );
	}
	
}

class Arc {
	
	public var w : Vertex;
	public var _next : Arc;
	
	public function new( w ) { this.w = w; _next = null; }
	
	public function toString() : String {
		return Std.string( w.vi );
	}
	
}

class Digraph<V : Vertex, A : Arc> {
	
	var vs : Array<V>;
	public var nV( default, null ) : Int;
	public var nA( default, null ) : Int;
	
	public function new() {
		vs = [];
		nV = 0;
		nA = 0;
	}
	
	public function valid() : Bool {
		for ( v in vs ) {
			var p : A = cast v.adj;
			while ( null != p ) {
				var w : V = cast p.w;
				try {
					check_has_vertex( w );
				}
				catch ( e : Dynamic ) {
					trace( e );
					return false;
				}
				p = cast p._next;
			}
		}
		return true;
	}
	
	public function add_vertex( v : V ) : V {
		if ( null == v )
			throw 'vertex cannot be null';
		if ( null != v.vi )
			throw 'v.vi must be null';
		
		v.vi = vs.length;
		vs.push( v );
		nV++;
		return v;
	}
	
	public function get_vertex( vi : Int ) : Null<V> {
		return vs[vi];
	}
	
	public function add_arc( v : V, a : A, ?unsafe : Bool = false, ?fast : Bool = false ) : A {
		check_has_vertex( v );
		check_has_vertex( cast a.w );
		if ( v == a.w )
			throw 'Arc v-v not allowed';
		if ( null != a._next )
			throw 'a._next must be null';
		
		if ( !unsafe )
			remove_arc( v, cast a.w );
		
		if ( fast ) { // a becames head of v.adj
			a._next = v.adj;
			v.adj = a;
		}
		else { // a goes to the tail end of v.adj
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
		}
		
		nA++;
		return a;
	}
	
	public function get_arc( v : V, w : V ) : Null<A> {
		check_has_vertex( v );
		check_has_vertex( w );
		
		var p = v.adj;
		while ( null != p ) {
			if ( w == p.w )
				return cast p;
			p = p._next;
		}
		return null;
	}
	
	public function remove_arc( v : V, w : V ) : Bool {
		check_has_vertex( v );
		check_has_vertex( w );
		
		var p = v.adj;
		var q = null;
		while ( null != p ) {
			if ( w == p.w ) {
				if ( null == q )
					v.adj = p._next;
				else
					q._next = p._next;
				nA--;
				return true;
			}
			q = p;
			p = p._next;
		}
		return false;
	}
	
	public function order_arcs( exchange : A -> A -> Bool ) : Void {
		for ( v in vs ) {
			var adjs = [];
			var p : A = cast v.adj;
			while ( null != p ) {
				adjs.push( p );
				p = cast p._next;
			}
			adjs = Heapsort.heapsort( adjs, exchange );
			v.adj = null;
			for ( i in 0...adjs.length ) {
				var j = adjs.length - i - 1;
				adjs[j]._next = v.adj;
				v.adj = adjs[j];
			}
		}
	}
	
	public function add_edge( v : V, w : V, arc_constructor : V -> V -> A ) : Array<A> {
		check_has_vertex( v );
		check_has_vertex( w );
		
		var a1 = add_arc( v, arc_constructor( v, w ), false, false );
		var a2 = add_arc( w, arc_constructor( w, v ), false, false );
		return [ a1, a2 ];
	}
	
	public function is_symmetric() : Bool {
		var arcs = new Hash();
		for ( v in vs ) {
			var p = v.adj;
			while ( null != p ) {
				arcs.set( v.vi + '-' + p.w.vi, { v : v, p : p } );
				p = p._next;
			}
		}
		for ( a in arcs )
			if ( !arcs.exists( a.p.w.vi + '-' + a.v.vi ) )
				return false;
		return true;
	}
	
	public function vertices() : Iterator<V> {
		var i = 0;
		return {
			hasNext : function() {
				return i < vs.length;
			},
			next : function() {
				return cast vs[i++];
			}
		};
	}
	
	public function toString() : String {
		var b = new StringBuf();
		b.add( '{ nV = ' );
		b.add( nV );
		b.add( ' , nA = ' );
		b.add( nA );
		b.add( ', adjacencies:\n' );
		b.add( show_adjacencies() );
		b.add( '}' );
		return b.toString();
	}
	
	
	/** HELPER **/
	
	function show_adjacencies() : String {
		var b = new StringBuf();
		for ( v in vs ) {
			b.add( v );
			b.add( ' :' );
			var p : A = cast v.adj;
			while ( null != p ) {
				b.add( ' ' );
				b.add( p );
				p = cast p._next;
			}
			b.add( '\n' );
		}
		return b.toString();
	}
	
	function check_has_vertex( v : V ) : Void {
		if ( null == v || null == v.vi || vs[v.vi] != v )
			throw 'Node ' + v + ' does not belong to this digraph';
	}
	
}