package jonas.graph;

import haxe.unit.TestCase;
import jonas.graph.Digraph;


/*
 * This is part of jonas.graph test cases
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

class DigraphTest extends TestCase {
	
	public function test_basic() : Void {
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
	
}