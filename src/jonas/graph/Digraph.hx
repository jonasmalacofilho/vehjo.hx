package jonas.graph;

/*
 * Graph: base directed graph
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
}

class Arc {
	public var w : Vertex;
	public var _next : Arc;
	public function new( w ) { this.w = w; _next = null; }
}

class Digraph<V : Vertex, A : Arc>
#if DIGRAPH_TESTS
extends haxe.unit.TestCase
#end
{
	
	var vs : Array<V>;
	public var nV( default, null ) : Int;
	public var nA( default, null ) : Int;
	
	public function new() {
		#if DIGRAPH_TESTS
		super();
		#end
		vs = [];
		nV = 0;
		nA = 0;
	}
	
	public function add_vertex( v : V ) : V {
		if ( null != v.vi )
			throw 'v.vi must be null';
		v.vi = vs.length;
		vs.push( v );
		nV++;
		return v;
	}
	
	public function get_vertex( vi : Int ) : V {
		return vs[vi];
	}
	
	public function add_arc( v : V, a : A, ?unsafe : Bool = false, ?fast : Bool = false ) : A {
		if ( v == a.w )
			throw 'Arcs v-v not allowed';
		if ( null != a._next )
			throw 'a._next != null';
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
	
	public function get_arc( v : V, w : V ) : A {
		var p = v.adj;
		while ( null != p ) {
			if ( w == p.w )
				return cast p;
			p = p._next;
		}
		return null;
	}
	
	public function remove_arc( v : V, w : V ) : Bool {
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
	
	public function add_edge( v : V, w : V, arc_constructor : V -> V -> A ) : Array<A> {
		var a1 = add_arc( v, arc_constructor( v, w ), false, false );
		var a2 = add_arc( w, arc_constructor( w, v ), false, false );
		return [ a1, a2 ];
	}
	
	public function show( separator : String ) : String {
		var b = new StringBuf();
		b.add( 'number of vertices = ' );
		b.add( nV );
		b.add( separator );
		b.add( 'number of arcs = ' );
		b.add( nA );
		for ( v in vs ) {
			var p = v.adj;
			while ( null != p ) {
				b.add( separator );
				b.add( v.vi );
				b.add( '-' );
				b.add( p.w.vi );
				p = p._next;
			}
		}
		return b.toString();
	}
	
	public function toString() : String { return '{' + show( ', ' ) + '}'; }
	
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
	
	#if DIGRAPH_TESTS
	public function test_example() : Void {
		// construction
		var d = new Digraph();
		for ( i in 0...8 )
			d.add_vertex( new Vertex() );
		d.add_arc( d.get_vertex( 0 ), new Arc( d.get_vertex( 5 ) ), true );
		d.add_arc( d.get_vertex( 5 ), new Arc( d.get_vertex( 2 ) ), true, true );
		d.add_arc( d.get_vertex( 2 ), new Arc( d.get_vertex( 1 ) ) );
		d.add_arc( d.get_vertex( 1 ), new Arc( d.get_vertex( 5 ) ) );
		d.add_arc( d.get_vertex( 5 ), new Arc( d.get_vertex( 7 ) ) );
		d.add_arc( d.get_vertex( 7 ), new Arc( d.get_vertex( 1 ) ) );
		d.add_arc( d.get_vertex( 0 ), new Arc( d.get_vertex( 7 ) ) );
		d.add_arc( d.get_vertex( 4 ), new Arc( d.get_vertex( 0 ) ) );
		d.add_arc( d.get_vertex( 4 ), new Arc( d.get_vertex( 7 ) ) );
		d.add_arc( d.get_vertex( 3 ), new Arc( d.get_vertex( 4 ) ) );
		d.add_arc( d.get_vertex( 3 ), new Arc( d.get_vertex( 6 ) ) );
		d.add_arc( d.get_vertex( 6 ), new Arc( d.get_vertex( 4 ) ) );
		d.add_arc( d.get_vertex( 6 ), new Arc( d.get_vertex( 3 ) ) );
		d.add_arc( d.get_vertex( 6 ), new Arc( d.get_vertex( 3 ) ) );
		trace( d );
		// checking vertices
		assertEquals( 8, d.nV );
		for ( i in 0...8 ) {
			var v = d.get_vertex( i );
			assertFalse( null == v );
			if ( null != v )
				assertEquals( i, v.vi );
		}
		
		// checking arcs
		assertEquals( 13, d.nA );
		var check_arc = function( vi : Int, wi : Int ) {
			var v = d.get_vertex( vi );
			var w = d.get_vertex( wi );
			var p = d.get_arc( v, w );
			assertFalse( null == p );
			if ( null != p )
				assertEquals( w, p.w );
		}
		check_arc( 0, 5 );
		check_arc( 5, 2 );
		check_arc( 2, 1 );
		check_arc( 5, 7 );
		check_arc( 3, 4 );
		check_arc( 3, 6 );
		check_arc( 1, 5 );
		check_arc( 6, 3 );
		check_arc( 0, 7 );
		check_arc( 4, 0 );
		check_arc( 4, 7 );
		check_arc( 7, 1 );
		check_arc( 6, 4 );
	}
	#end
	
}