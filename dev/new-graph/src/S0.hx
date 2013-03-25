package ;

// what jonas.graph does now

// please understand digraph as "a directed graph", or a non-symmetrical graph

// for convenience, this does not deal with multi(di)graphs (multiple arcs for
// a given vertex tuple) or self-loops (arcs with equal origin and destination
// vertices)

// even thought there are only constructors for the extended classes,
// I also need to be able to instanciate base classes

// the base Vertex class
class Vertex {
	// head of the adjacency list of arcs the leave this vertex
	public var adjHead : Arc;
}

// the base Arc class
// arcs are stored as linked list nodes
// they do not know their origin node, only their destination one
class Arc {
	// destination vertex of this arc
	public var w : Vertex;
	// next arc on the adjacency list (of the origin vertex)
	public var adjNext : Arc;
}

// the base Digraph class
class Digraph<V:Vertex,A:Arc> {
	// all vertices of the digraph
	var vs : Array<V>;
}

// the extended Vertex class
// adds a cost:Float property to Vertex
class ExtVertex extends Vertex {
	public var cost : Float;
	public function new( cost ) {
		adjHead = null;
		this.cost = cost;
	}
}

// the extended Arc class
// adds a cost:Float property to Arc
class ExtArc extends Arc {
	public var cost : Float;
	public function new( w, cost ) {
		this.w = w;
		this.cost = cost;
	}
}

// the extended Digraph class
// do something that requires ExtVertex and ExtArc (use the cost properties
// of both)
class ExtDigraph<V:ExtVertex,A:ExtArc> extends Digraph<V,A > {
	
	public function new() {
		vs = [];
	}
	
	public function test() {
		for ( v in vs ) {
			// outer loop; require ExtVertex (and NOT Vertex)
			trace( v.cost );
			// currently, jonas.graph uses an unsafe cast here: var p : A = cast v.adjHead;
			var p : A = cast v.adjHead;
			while ( p != null ) {
				// inner loop, require ExtArc (and NOT Arc)
				var w : V = cast p.w;
				trace( w.cost );
				trace( p.cost );
				// currently, jonas.graph uses an unsafe cast here: var p = cast p.adjNext;
				p = cast p.adjNext;
			}
		}
	}
}

// some more tests, replicating the use of such ExtDigraph somewhere else
class S0 {
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
		trace( [ v, w ].join( '\n' ) );
		trace( [ a1, a2 ].join( '\n' ) );
		trace( x );
	}
}