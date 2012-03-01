package jonas.graph;

import jonas.graph.ArcClassification;

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

class ArcClassificationTest extends DigraphTest {

	override public function test_basic() : Void {
		// construction
		var d = new ArcClassificationDigraph();
		for ( i in 0...8 )
			d.add_vertex( new ArcClassificationVertex() );
		d.add_arc( d.get_vertex( 0 ), new ArcClassificationArc( d.get_vertex( 5 ) ) );
		d.add_arc( d.get_vertex( 5 ), new ArcClassificationArc( d.get_vertex( 2 ) ) );
		d.add_arc( d.get_vertex( 2 ), new ArcClassificationArc( d.get_vertex( 1 ) ) );
		d.add_arc( d.get_vertex( 1 ), new ArcClassificationArc( d.get_vertex( 5 ) ) );
		d.add_arc( d.get_vertex( 5 ), new ArcClassificationArc( d.get_vertex( 7 ) ) );
		d.add_arc( d.get_vertex( 7 ), new ArcClassificationArc( d.get_vertex( 1 ) ) );
		d.add_arc( d.get_vertex( 0 ), new ArcClassificationArc( d.get_vertex( 7 ) ) );
		d.add_arc( d.get_vertex( 4 ), new ArcClassificationArc( d.get_vertex( 0 ) ) );
		d.add_arc( d.get_vertex( 4 ), new ArcClassificationArc( d.get_vertex( 7 ) ) );
		d.add_arc( d.get_vertex( 3 ), new ArcClassificationArc( d.get_vertex( 4 ) ) );
		d.add_arc( d.get_vertex( 3 ), new ArcClassificationArc( d.get_vertex( 6 ) ) );
		d.add_arc( d.get_vertex( 6 ), new ArcClassificationArc( d.get_vertex( 4 ) ) );
		d.add_arc( d.get_vertex( 6 ), new ArcClassificationArc( d.get_vertex( 3 ) ) );
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