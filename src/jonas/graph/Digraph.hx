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

class Digraph<V : Vertex, A : Arc> {
	
	var vs : Array<V>;
	public var nV( default, null ) : Int;
	public var nA( default, null ) : Int;
	public var allow_parallel : Bool;
	
	public function new() {
		vs = [];
		nV = 0;
		nA = 0;
		allow_parallel = false;
	}
	
	public function valid() : Bool {
		var arcs = 0;
		if ( vs.length != nV ) {
			trace( 'Wrong nV' );
			return false;
		}
		for ( i in 0...nV ) {
			var v = vs[i];
			if ( i != v.vi ) {
				trace( 'Vertex id does not match its position' );
				return false;
			}
			var h = new IntHash();
			for ( p in arcs_from( v ) ) {
				arcs++;
				var w : V = cast p.w;
				
				// has vertex
				try { check_has_vertex( w ); }
				catch ( e : Dynamic ) { trace( e ); return false; }
				
				// parallel arcs
				if ( !allow_parallel && h.exists( w.vi ) ) {
					trace( 'Found parallel arcs ' + v.vi + '-' + w.vi );
					return false;
				}
				else
					h.set( w.vi, true );
				
			}
		}
		if ( arcs != nA ) {
			trace( 'Wrong nA' );
			return false;
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
	
	public function add_arc( v : V, w : V, a : A, ?unsafe : Bool = false, ?fast : Bool = false ) : A {
		check_has_vertex( v );
		check_has_vertex( w );
		if ( v == w )
			throw 'Arc v-v not allowed';
		if ( null != a.w )
			throw 'a.w must be null';
		if ( null != a._next )
			throw 'a._next must be null';
		
		a.w = w;
		
		if ( !allow_parallel && !unsafe )
			remove_arc( v, w );
		
		if ( fast ) { // a becames head of v.adj
			a._next = v.adj;
			v.adj = a;
		}
		else { // a goes to the tail end of v.adj
			var q = null;
			for ( p in arcs_from( v ) )
				q = p;
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
		
		for ( p in arcs_from( v ) )
			if ( w == p.w )
				return cast p;
		
		return null;
	}
	
	public function remove_arc( v : V, w : V ) : Bool {
		check_has_vertex( v );
		check_has_vertex( w );
		
		var q = null;
		for ( p in arcs_from( v ) ) {
			if ( w == p.w ) {
				if ( null == q )
					v.adj = p._next;
				else
					q._next = p._next;
				nA--;
				p._next = null;
				p.w = null;
				return true; // if allow_parallel is set, only the first matched arc will be removed
			}
			q = p;
		}
		return false;
	}
	
	public function order_arcs( exchange : A -> A -> Bool ) : Void {
		for ( v in vs ) {
			var adjs = Lambda.array( { iterator : callback( arcs_from, v ) } );
			adjs = Heapsort.heapsort( adjs, exchange );
			v.adj = null;
			for ( i in 0...adjs.length ) {
				var j = adjs.length - i - 1;
				adjs[j]._next = v.adj;
				v.adj = adjs[j];
			}
		}
	}
	
	public function is_symmetric() : Bool {
		var arcs = new Hash();
		for ( v in vs )
			for ( p in arcs_from( v ) )
				arcs.set( v.vi + '-' + p.w.vi, { v : v, p : p } );
		for ( a in arcs ) {
			var ap = arcs.get( a.p.w.vi + '-' + a.v.vi );
			if ( null == ap || !equal_arc_properties( a.p, ap.p ) )
				return false;
		}
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
	
	public function arcs_from( v : V ) : Iterator<A> {
		check_has_vertex( v );
		
		var p : A = cast v.adj;
		return {
			hasNext : function() { return null != p; },
			next : function() { var q = p; p = cast p._next; return q; }
		}
	}
	
	public function arcs_from_random( v : V ) : Iterator<A> {
		var arcs = Lambda.array( { iterator : callback( arcs_from, v ) } );
		var exch = function( i, j ) { var t = arcs[i]; arcs[i] = arcs[j]; arcs[j] = t; };
		var i = 0;
		return {
			hasNext : function() { return i < arcs.length; },
			next : function() { exch( i, i + Std.random( arcs.length - i ) ); return cast arcs[i++]; }
		}
	}
	
	public function arcs() : Iterator<A> {
		var i = 0;
		var p : A = cast ( i < nV ? vs[i].adj : null );
		return {
			hasNext : function() { return null != p; },
			next : function() {
				var q = p;
				p = cast p._next;
				if ( null == p && ++i < nV )
					p = cast vs[i].adj;
				return q;
			}
		}
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
	
	public function vertex_outbound_degree( v : V ) : Int {
		return Lambda.count( { iterator : callback( arcs_from, v ) } );
	}
	
	
	/** HELPER **/
	
	function show_adjacencies() : String {
		var b = new StringBuf();
		for ( v in vs ) {
			b.add( v );
			b.add( ' :' );
			for ( p in arcs_from( v ) ) {
				b.add( ' ' );
				b.add( p );
			}
			b.add( '\n' );
		}
		return b.toString();
	}
	
	function check_has_vertex( v : V ) : Void {
		if ( null == v || null == v.vi || vs[v.vi] != v )
			throw 'Node ' + v + ' does not belong to this digraph';
	}
	
	function equal_vertex_properties( a : V, b : V ) : Bool {
		return true;
	}
	
	function equal_arc_properties( a : A, b : A ) : Bool {
		return true;
	}
	
}