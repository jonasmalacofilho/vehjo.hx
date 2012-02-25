package jonas.graph;

import jonas.graph.Digraph;

/*
 * Graph: arc classification
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

class AnalyzeArcsVertex extends Vertex {
	public var d : Int; // discovered
	public var f : Int; // finished
	public var parent : AnalyzeArcsVertex;
}

enum ArcType {
	ArborescenceArc;
	DescendentArc;
	ReturnArc;
	CrossedArc;
}

class AnalyzeArcsArc extends Arc {
	public var type : ArcType;
}
 
class AnalyzeArcsDigraph<V : AnalyzeArcsVertex, A : AnalyzeArcsArc> extends Digraph<V, A> {

	public function analyze_arcs() : Void {
		// setup
		var t = 0; // time
		for ( v in vs ) {
			v.f = v.d = -1;
			v.parent = null;
		}
		
		// dfs
		for ( v in vs )
			if ( -1 == v.d ) {
				v.parent = v;
				t = analyze_arcs_rec( t, v );
			}
		
		// arc classification
		for ( v in vs ) {
			var p : A = cast v.adj; while ( null != p ) {
				var w : V = cast p.w;
				if ( v.d < w.d && w.f < v.f )
					p.type = w.parent == v ? ArborescenceArc : DescendentArc;
				else
					p.type = v.f < w.f ? ReturnArc : CrossedArc;
				p = cast p._next;
			}
		}
	}
	
	function analyze_arcs_rec( t : Int, v : V ) : Int {
		v.d = t++;
		var p = v.adj; while ( null != p ) {
			var w : V = cast p.w;
			if ( -1 == w.d ) {
				w.parent = v;
				t = analyze_arcs_rec( t, w );
			}
			p = p._next;
		}
		v.f = t++;
		return t;
	}
	
	override public function show( separator : String ) : String {
		var b = new StringBuf();
		b.add( 'number of vertices = ' );
		b.add( nV );
		b.add( separator );
		b.add( 'number of arcs = ' );
		b.add( nA );
		for ( v in vs ) {
			var p : A = cast v.adj;
			while ( null != p ) {
				b.add( separator );
				b.add( v.vi );
				b.add( '-' );
				b.add( p.w.vi );
				b.add( '(' );
				b.add( p.type );
				b.add( ')' );
				p = cast p._next;
			}
		}
		return b.toString();
	}
	
	#if DIGRAPH_TESTS
	override public function test_example() : Void {
		// construction
		var d = new AnalyzeArcsDigraph();
		for ( i in 0...8 )
			d.add_vertex( new AnalyzeArcsVertex() );
		d.add_arc( d.get_vertex( 0 ), new AnalyzeArcsArc( d.get_vertex( 5 ) ) );
		d.add_arc( d.get_vertex( 5 ), new AnalyzeArcsArc( d.get_vertex( 2 ) ) );
		d.add_arc( d.get_vertex( 2 ), new AnalyzeArcsArc( d.get_vertex( 1 ) ) );
		d.add_arc( d.get_vertex( 1 ), new AnalyzeArcsArc( d.get_vertex( 5 ) ) );
		d.add_arc( d.get_vertex( 5 ), new AnalyzeArcsArc( d.get_vertex( 7 ) ) );
		d.add_arc( d.get_vertex( 7 ), new AnalyzeArcsArc( d.get_vertex( 1 ) ) );
		d.add_arc( d.get_vertex( 0 ), new AnalyzeArcsArc( d.get_vertex( 7 ) ) );
		d.add_arc( d.get_vertex( 4 ), new AnalyzeArcsArc( d.get_vertex( 0 ) ) );
		d.add_arc( d.get_vertex( 4 ), new AnalyzeArcsArc( d.get_vertex( 7 ) ) );
		d.add_arc( d.get_vertex( 3 ), new AnalyzeArcsArc( d.get_vertex( 4 ) ) );
		d.add_arc( d.get_vertex( 3 ), new AnalyzeArcsArc( d.get_vertex( 6 ) ) );
		d.add_arc( d.get_vertex( 6 ), new AnalyzeArcsArc( d.get_vertex( 4 ) ) );
		d.add_arc( d.get_vertex( 6 ), new AnalyzeArcsArc( d.get_vertex( 3 ) ) );
		assertEquals( 8, d.nV );
		assertEquals( 13, d.nA );
		
		d.analyze_arcs();
		trace( d );
		
		// parent, d & f checking
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
	#end
	
}