package jonas.graph;

/*
 * This is part of jonas.graph test suite
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

private typedef V = Vertex;
private typedef A = Arc;
private typedef D = Digraph<V, A>;
 
class DigraphTest extends DigraphStructuralTest<D, V, A> {
	
	public function test_example() : Void {
		// construction
		for ( i in 0...8 )
			d.add_vertex( vertex() );
		d.add_arc( d.get_vertex( 0 ), d.get_vertex( 5 ), arc(), true );
		d.add_arc( d.get_vertex( 5 ), d.get_vertex( 2 ), arc(), true, true );
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
		d.add_arc( d.get_vertex( 6 ), d.get_vertex( 3 ), arc() );
		
		assertEquals( 8, d.nV );
		assertEquals( 13, d.nA );
		
		trace( d );
	}
	
}