package vehjo.ds.queue;

import vehjo.ds.DAryHeap;

/**
	Priority queue
	Currently implemented using an array based D-ary (binary) heap
**/
class PriorityQueue<T> extends DAryHeap<T> implements Queue<T> {
	
	static inline var DEFAULT_ARITY = 7;
	
	public function new( reserve = 0, arity = DEFAULT_ARITY ) {
		super( arity, reserve );
	}
	
	override public function iterator() : Iterator<T> {
		var g = copy();
		return {
			hasNext : g.not_empty,
			next : g.get
		};
	}
	
	override public function toString() : String {
		return 'PriorityQueue { ' + join( ', ' ) + ' }';
	}
	
}
