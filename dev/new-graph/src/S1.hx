package ;

// thanks, Cauê Waneck!

// please understand digraph as "a directed graph", or a non-symmetrical graph

// for convenience, this does not deal with multi(di)graphs (multiple arcs for
// a given vertex tuple) or self-loops (arcs with equal origin and destination
// vertices)

// even thought there are only constructors for the extended classes,
// I also need to be able to instanciate base classes

// the base Vertex class
class Vertex<A> {
	// head of the adjacency list of arcs the leave this vertex
	public var adjHead : A;
}

// the base Arc class
// arcs are stored as linked list nodes
// they do not know their origin node, only their destination one
class Arc<V, A:Arc<V, A>> {
	// destination vertex of this arc
	public var w : V;
	// next arc on the adjacency list (of the origin vertex)
	public var adjNext : A;
}

// the base Digraph class
class Digraph<V:Vertex<A>,A:Arc<V, A>> {
	// all vertices of the digraph
	var vs : Array<V>;
}

// the extended Vertex class
// adds a cost:Float property to Vertex
class ExtVertex extends Vertex<ExtArc> {
	public var cost : Float;
	public function new( cost ) {
		adjHead = null;
		this.cost = cost;
	}
}

// the extended Arc class
// adds a cost:Float property to Arc
class ExtArc extends Arc<ExtVertex, ExtArc> {
	public var cost : Float;
	public function new( w, cost ) {
		this.w = w;
		this.cost = cost;
	}
}

// the extended Digraph class
// do something that requires ExtVertex and ExtArc (use the cost properties
// of both)
class ExtDigraph extends Digraph<ExtVertex,ExtArc> {
	
	public function new() {
		vs = [];
	}
	
	public function test() {
		for ( v in vs ) {
			// outer loop; require ExtVertex (and NOT Vertex)
			trace( v.cost );
			// currently, jonas.graph uses an unsafe cast here: var p : A = cast v.adjHead;
			var p = v.adjHead;
			while ( p != null ) {
				// inner loop, require ExtArc (and NOT Arc)
				trace( p.w.cost );
				trace( p.cost );
				// currently, jonas.graph uses an unsafe cast here: var p = cast p.adjNext;
				p = p.adjNext;
			}
		}
	}
}

// some more tests, replicating the use of such ExtDigraph somewhere else
class S1 {
	static function main() {
		// just try to construct all relevant elements
		// a node
		var v = new ExtVertex( Math.random() );
		// another node
		var w = new ExtVertex( Math.random() );
		// an arc
		var a1 = new ExtArc( w, Math.random() );
		// register it on its origin vertex
		v.adjHead = a1;
		// another arc
		var a2 = new ExtArc( v, Math.random() );
		// register it on its origin vertex
		w.adjHead = a2;
		// a extended digraph
		var x = new ExtDigraph();
	}
}