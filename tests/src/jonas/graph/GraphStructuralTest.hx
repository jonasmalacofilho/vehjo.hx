package jonas.graph;

/*
 * 
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

class GraphStructuralTest<D : Graph<V, A>, V : Vertex, A : Arc> extends DigraphStructuralTest<D, V, A> {

	override function digraph( ?params : Array<Dynamic>) : D {
		return cast new Graph<V, A>();
	}
	
	override public function test_valid_parallel() : Void {
		assertTrue( d.valid() );
		d.allow_parallel = true;
		assertFalse( d.valid() );
	}
	
	public function test_valid_not_symmetric() : Void {
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		d.add_arc( v, w, arc() );
		assertFalse( d.valid() );
	}
	
	public function test_valid_symmetric() : Void {
		var v = d.add_vertex( vertex() );
		var w = d.add_vertex( vertex() );
		d.add_arc( v, w, arc() );
		d.add_arc( w, v, arc() );
		assertTrue( d.valid() );
	}
	
	// TODO test_add_edge
	
	// TODO test_remove_edge
	
}