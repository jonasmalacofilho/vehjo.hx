package jonas.graph;

import jonas.graph.Digraph;
import jonas.MathExtension;

/*
 * Configurable (by extension) digraph generator
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

class DigraphGenerator<D : Digraph<V, A>, V : Vertex, A : Arc> {

	public var dg( default, null ) : D;
	var create_vertex : Void -> V;
	var create_arc : V -> V -> A;

	public function new( dg, create_vertex, create_arc ) {
		this.dg = dg;
		this.create_vertex = create_vertex;
		this.create_arc = create_arc;
		assembly();
	}
	
	public function assembly() : Void {
		
	}
	
}

class RandomDigraph<D : Digraph<V, A>, V : Vertex, A : Arc> extends DigraphGenerator<D, V, A> {
	
	var nV : Int;
	var nA : Int;
	
	public function new( dg, create_vertex, create_arc, vertices, arcs ) {
		nV = vertices;
		nA = arcs;
		super( dg, create_vertex, create_arc );
	}
	
	override function assembly() : Void {
		
		// vertices
		var vs = [];
		for ( i in 0...nV )
			vs.push( dg.add_vertex( create_vertex() ) );
		
		// arcs
		while ( dg.nA < nA ) {
			var v, w;
			while ( ( v = vs[Std.random( nV )] ) == ( w = vs[Std.random( nV )] ) ) { }
			dg.add_arc( v, create_arc( v, w ) );
		}
		
	}
	
}

class RandomGraph<D : Digraph<V, A>, V : Vertex, A : Arc> extends DigraphGenerator<D, V, A> {
	
	var nV : Int;
	var nE : Int;
	
	public function new( dg, create_vertex, create_arc, vertices, edges ) {
		nV = vertices;
		nE = edges;
		super( dg, create_vertex, create_arc );
	}
	
	override function assembly() : Void {
		
		// vertices
		var vs = [];
		for ( i in 0...nV )
			vs.push( dg.add_vertex( create_vertex() ) );
		
		// arcs
		while ( 2 * dg.nA < nE ) {
			var v, w;
			while ( ( v = vs[Std.random( nV )] ) == ( w = vs[Std.random( nV )] ) ) { }
			dg.add_edge( v, w, create_arc );
		}
		
	}
	
}

class PetersenGraph < D : Digraph < V, A > , V : Vertex, A : Arc > extends DigraphGenerator < D, V, A > {
	
	public function new( dg, create_vertex, create_arc ) {
		var nV = 10;
		var nA = 30;
		super( dg, create_vertex, create_arc );
		if ( dg.nV != nV )
			throw 'Bad construction nV = ' + dg.nV + ' (should be ' + nV + ')';
		if ( dg.nA != nA )
			throw 'Bad construction nA = ' + dg.nA + ' (should be ' + nA + ')';
	}
	
	override function assembly() : Void {
		var vs = [];
		for ( i in 0...10 )
			vs.push( dg.add_vertex( create_vertex() ) );
		dg.add_edge( vs[0], vs[1], create_arc );
		dg.add_edge( vs[0], vs[4], create_arc );
		dg.add_edge( vs[0], vs[5], create_arc );
		dg.add_edge( vs[1], vs[0], create_arc );
		dg.add_edge( vs[1], vs[2], create_arc );
		dg.add_edge( vs[1], vs[6], create_arc );
		dg.add_edge( vs[2], vs[1], create_arc );
		dg.add_edge( vs[2], vs[3], create_arc );
		dg.add_edge( vs[2], vs[7], create_arc );
		dg.add_edge( vs[3], vs[2], create_arc );
		dg.add_edge( vs[3], vs[4], create_arc );
		dg.add_edge( vs[3], vs[8], create_arc );
		dg.add_edge( vs[4], vs[0], create_arc );
		dg.add_edge( vs[4], vs[3], create_arc );
		dg.add_edge( vs[4], vs[9], create_arc );
		dg.add_edge( vs[5], vs[0], create_arc );
		dg.add_edge( vs[5], vs[7], create_arc );
		dg.add_edge( vs[5], vs[8], create_arc );
		dg.add_edge( vs[6], vs[1], create_arc );
		dg.add_edge( vs[6], vs[8], create_arc );
		dg.add_edge( vs[6], vs[9], create_arc );
		dg.add_edge( vs[7], vs[2], create_arc );
		dg.add_edge( vs[7], vs[5], create_arc );
		dg.add_edge( vs[7], vs[9], create_arc );
		dg.add_edge( vs[8], vs[3], create_arc );
		dg.add_edge( vs[8], vs[5], create_arc );
		dg.add_edge( vs[8], vs[6], create_arc );
		dg.add_edge( vs[9], vs[4], create_arc );
		dg.add_edge( vs[9], vs[6], create_arc );
		dg.add_edge( vs[9], vs[7], create_arc );
	}
	
}

// CrownGraph
// order == 0 => u0, v0, u1, v1, ..., un, vn
// order == 1 => u0, u1, ..., un, v0, v1, ..., vn
class CrownGraph < D : Digraph < V, A > , V : Vertex, A : Arc > extends DigraphGenerator < D, V, A > {
	
	var n : Int;
	var order : Int;
	
	public function new( dg, create_vertex, create_arc, n, order = 0 ) {
		if ( 0 != order && 1 != order )
			throw '0 <= order <= 1';
		this.order = order;
		this.n = n;
		var nV = 2 * n;
		var nA = 2 * n * ( n - 1 );
		super( dg, create_vertex, create_arc );
		if ( dg.nV != nV )
			throw 'Bad construction nV = ' + dg.nV + ' (should be ' + nV + ')';
		if ( dg.nA != nA )
			throw 'Bad construction nA = ' + dg.nA + ' (should be ' + nA + ')';
	}
	
	override function assembly() : Void {
		// vertices
		var us = [];
		var vs = [];
		if ( 0 == order )
			for ( i in 0...n ) {
				us.push( dg.add_vertex( create_vertex() ) );
				vs.push( dg.add_vertex( create_vertex() ) );
			}
		else {
			for ( i in 0...n )
				us.push( dg.add_vertex( create_vertex() ) );
			for ( i in 0...n )
				vs.push( dg.add_vertex( create_vertex() ) );
		}
		// edges
		for ( i in 0...n )
			for ( j in 0...n )
				if ( i != j )
					dg.add_edge( us[i], vs[j], create_arc );
	}
}