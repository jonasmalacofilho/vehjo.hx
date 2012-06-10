package jonas.graph;

/*
 * Arc classification (DFS)
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

enum ArcType {
	ArborescenceArc;
	DescendentArc;
	ReturnArc;
	CrossedArc;
}

class ArcClassificationDigraph<V : ArcClassificationVertex, A : ArcClassificationArc> extends Digraph<V, A> {

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
	
}