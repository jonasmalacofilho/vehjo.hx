package vehjo.graph;

/*
 * Generic shortest path algorithm
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

class SPDigraph < V : SPVertex, A : SPArc > extends PathExistanceDigraph < V, A > {
	
	// shortest path tree from s
	public function compute_spt( s : V ) : Void {
		throw 'Not implemented';
	}
	
	// shortest path from s to t
	public function compute_shortest_path( s : V, t : V ) : Void {
		throw 'Not implemented';
	}
	
	// shortest paths from s to t( v ) == true
	public function compute_shortest_paths( s : V, t : V -> Bool ) : Void {
		throw 'Not implemented';
	}
	
	override function equal_arc_properties( a : A, b : A ) : Bool {
		return a.cost == b.cost;
	}
	
}