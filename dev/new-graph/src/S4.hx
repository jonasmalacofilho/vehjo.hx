package ;

// typedef based approach, on top of S3

// please understand digraph as "a directed graph", or a non-symmetrical graph

// for convenience, this does not deal with multi(di)graphs (multiple arcs for
// a given vertex tuple) or self-loops (arcs with equal origin and destination
// vertices)

// even thought there are only constructors for the extended classes,
// I also need to be able to instanciate base classes


/** First level **/


// the base Vertex interface
typedef Vertex<V, A> = {
	// head of the adjacency list of arcs the leave this vertex
	public var adjHead: A;
}

// the base Arc interface
// arcs are stored as linked list nodes
// they do not know their origin node, only their destination one
typedef Arc<V, A> = {
	// destination vertex of this arc
	public var w: V;
	// next arc on the adjacency list (of the origin vertex)
	public var adjNext: A;
}

// the base Digraph class
class Digraph<V: Vertex<V,A>, A: Arc<V,A>> {
	// all vertices of the digraph
	var vs: Array<V>;

	// Digraph constructor
	public function new() {
		vs = [];
	}

	// add vertex
	public function addVertex( v: V ): V {
		vs.push( v );
		return v;
	}

	// add arc
	public function addArc( v: V, w: V, a: A ): A {
		a.adjNext = v.adjHead;
		v.adjHead = a;
		a.w = w;
		return a;
	}
}


/** Second level **/


// extended Vertex interface
// adds a cost:Float property to Vertex
typedef ExtVertex<V, A, C: Float> = {
	public var adjHead: A;
	public var cost: C;
}

// extended Arc interface
// adds a cost:Float property to Arc
typedef ExtArc<V, A, C: Float> = {
	public var w: V;
	public var adjNext: A;
	public var cost: C;
}

// extended Digraph class
// do something that requires ExtVertex and ExtArc (use the cost properties
// of both)
class ExtDigraph<V: ExtVertex<V, A, C>, A: ExtArc<V, A, C>, C: Float>
	extends Digraph<V, A>
{	
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


/** Third level **/


// another extended Vertex interface
// adds a cost:Float property to Vertex
typedef Ext2Vertex<V, A, C: Float, T: Float> = {
	public var adjHead: A;
	public var cost: C;
	public var time: T;
}

// another extended Arc interface
// adds a cost:Float property to Arc
typedef Ext2Arc<V, A, C: Float, T: Float> = {
	public var w: V;
	public var adjNext: A;
	public var cost: C;
	public var time: T;
}

// another Digraph class
// do something that requires ExtVertex and ExtArc (use the cost properties
// of both)
class Ext2Digraph<V: Ext2Vertex<V, A, C, T>, A: Ext2Arc<V, A, C, T>, C: Float, T: Float>
	extends ExtDigraph<V, A, C>
{	
	public function test2() {
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


/** Implementation and testing **/


class MyVertex {
	public var adjHead: MyArc;
	public var cost: Float;
	public var time: Float;
	public function new( cost, time ) {
		adjHead = null;
		this.cost = cost;
		this.time = time;
	}
}

class MyArc {
	public var w: MyVertex;
	public var adjNext: MyArc;
	public var cost: Float;
	public var time: Float;
	public function new( cost, time ) {
		this.cost = cost;
		this.time = time;
	}
}

class S4 {
	static function main() {
		// a second generation extended digraph
		var x = new Ext2Digraph();

		// just try to construct all relevant elements
		// a node
		var v = x.addVertex( new MyVertex( Math.random(), Math.random() ) );
		// another node
		var w = x.addVertex( new MyVertex( Math.random(), Math.random() ) );
		// an arc
		var a1 = x.addArc( v, w, new MyArc( Math.random(), Math.random() ) );
		// another arc
		var a2 = x.addArc( w, v, new MyArc( Math.random(), Math.random() ) );

		trace( [ v, w ].join( '\n' ) );
		trace( [ a1, a2 ].join( '\n' ) );
		trace( x );
	}
}