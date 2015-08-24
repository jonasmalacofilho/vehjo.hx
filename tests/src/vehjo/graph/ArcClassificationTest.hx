package vehjo.graph;

import vehjo.graph.ArcClassificationDigraph;

/*
 * This is part of vehjo.graph test suite
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

private typedef V = ArcClassificationVertex;
private typedef A = ArcClassificationArc;
private typedef D = ArcClassificationDigraph<V, A>;

class ArcClassificationTest extends DigraphStructuralTest<D, V, A> {

	override function digraph( ?params : Array<Dynamic> ) : D {
		return cast new D();
	}
	
	override function vertex( ?params : Array<Dynamic> ) : V {
		return cast new V();
	}
	
	override function arc( ?params : Array<Dynamic> ) : A {
		return cast new A();
	}
	
	public function test_example() : Void {
		// construction
		for ( i in 0...8 )
			d.add_vertex( vertex() );
		d.add_arc( d.get_vertex( 0 ), d.get_vertex( 5 ), arc() );
		d.add_arc( d.get_vertex( 5 ), d.get_vertex( 2 ), arc() );
		d.add_arc( d.get_vertex( 2 ), d.get_vertex( 1 ), arc() );
		d.add_arc( d.get_vertex( 1 ), d.get_vertex( 5 ), arc() );
		d.add_arc( d.get_vertex( 5 ), d.get_vertex( 7 ), arc() );
		d.add_arc( d.get_vertex( 7 ), d.get_vertex( 1 ), arc() );
		d.add_arc( d.get_vertex( 0 ), d.get_vertex( 7 ), arc() );
		d.add_arc( d.get_vertex( 4 ), d.get_vertex( 0 ), arc() );
		d.add_arc( d.get_vertex( 4 ), d.get_vertex( 7 ), arc() );
		d.add_arc( d.get_vertex( 3 ), d.get_vertex( 4 ), arc() );
		d.add_arc( d.get_vertex( 3 ), d.get_vertex( 6 ), arc() );
		d.add_arc( d.get_vertex( 6 ), d.get_vertex( 4 ), arc() );
		d.add_arc( d.get_vertex( 6 ), d.get_vertex( 3 ), arc() );
		
		assertEquals( 8, d.nV );
		assertEquals( 13, d.nA );
		
		d.analyze_arcs();
		trace( d );
		
		// parent, d & f checking (implementation dependent)
		var get_vertex_data = function( vi : Int ) {
			var v = d.get_vertex( vi );
			if ( null == v )
				throw 'Could not get vertex ' + vi;
			return [ v.vi, v.parent.vi, v.d, v.f ];
		};
		assertEquals( [ 0, 0, 0, 9 ].toString(), get_vertex_data( 0 ).toString() );
		assertEquals( [ 1, 2, 3, 4 ].toString(), get_vertex_data( 1 ).toString() );
		assertEquals( [ 2, 5, 2, 5 ].toString(), get_vertex_data( 2 ).toString() );
		assertEquals( [ 3, 3, 10, 15 ].toString(), get_vertex_data( 3 ).toString() );
		assertEquals( [ 4, 3, 11, 12 ].toString(), get_vertex_data( 4 ).toString() );
		assertEquals( [ 5, 0, 1, 8 ].toString(), get_vertex_data( 5 ).toString() );
		assertEquals( [ 6, 3, 13, 14 ].toString(), get_vertex_data( 6 ).toString() );
		assertEquals( [ 7, 5, 6, 7 ].toString(), get_vertex_data( 7 ).toString() );
		
		// arc type checking
		var get_arc_type = function( vi : Int, wi : Int ) {
			var p = d.get_arc( d.get_vertex( vi ), d.get_vertex( wi ) );
			if ( null == p )
				throw 'Could not get arc ' + vi + '-' + wi;
			return p.type;
		};
		assertEquals( ArborescenceArc, get_arc_type( 0, 5 ) );
		assertEquals( ArborescenceArc, get_arc_type( 5, 2 ) );
		assertEquals( ArborescenceArc, get_arc_type( 2, 1 ) );
		assertEquals( ArborescenceArc, get_arc_type( 5, 7 ) );
		assertEquals( ArborescenceArc, get_arc_type( 3, 4 ) );
		assertEquals( ArborescenceArc, get_arc_type( 3, 6 ) );
		assertEquals( DescendentArc, get_arc_type( 0, 7 ) );
		assertEquals( ReturnArc, get_arc_type( 1, 5 ) );
		assertEquals( ReturnArc, get_arc_type( 6, 3 ) );
		assertEquals( CrossedArc, get_arc_type( 6, 4 ) );
		assertEquals( CrossedArc, get_arc_type( 4, 0 ) );
		assertEquals( CrossedArc, get_arc_type( 4, 7 ) );
		assertEquals( CrossedArc, get_arc_type( 7, 1 ) );
	}
	
}