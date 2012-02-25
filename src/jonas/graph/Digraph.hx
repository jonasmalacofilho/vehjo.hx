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

class Digraph<V : Vertex, A : Arc> #if debug extends haxe.unit.TestCase #end {
	
	var vs : Array<V>;
	public var nV( default, null ) : Int;
	public var nA( default, null ) : Int;
	
	public function new() {
		#if debug
		super();
		#end
		vs = [];
		nV = 0;
		nA = 0;
	}
	
	public function add_vertex( v : V ) : V {
		if ( null != v.vi )
			throw 'Vertex already belongs to another digraph';
		v.vi = vs.length;
		vs.push( v );
		nV++;
		return v;
	}
	
	public function get_vertex( vi : Int ) : V {
		return vs[vi];
	}
	
	public function add_arc( v : V, a : A ) : A {
		if ( null != a._next )
			throw '_next != null';
		if ( null == v.adj ) {
			v.adj = a;
			nA++;
			return a;
		}
		else {
			var p = v.adj;
			while ( true ) {
				if ( a.w == p.w )
					return cast p;
				if ( null == p._next )
					break;
				p = p._next;
			}
			p._next = a;
			nA++;
			return a;
		}
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
	
	public function add_edge( v : V, w : V, arc_constructor : V -> V -> A ) : Array<A> {
		var a1 = add_arc( v, arc_constructor( v, w ) );
		var a2 = add_arc( w, arc_constructor( w, v ) );
		return [ a1, a2 ];
	}
	
	#if debug
	public function test_example() : Void {
		// construction
		var d = new Digraph();
		for ( i in 0...8 )
			d.add_vertex( new Vertex() );
		d.add_arc( d.get_vertex( 0 ), new Arc( d.get_vertex( 5 ) ) );
		d.add_arc( d.get_vertex( 5 ), new Arc( d.get_vertex( 2 ) ) );
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