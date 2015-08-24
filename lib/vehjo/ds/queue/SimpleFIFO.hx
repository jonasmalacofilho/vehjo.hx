package vehjo.ds.queue;

/**
 * Simple first in, first out queue, build on top of List
 * This is manteined for compatibility with old code that ran on circular
 * implementation of SimpleFIFO
 */
class SimpleFIFO<T> implements Queue<T>
{
	var q : List<T>;
	var max_size : Int;
	
	public function new( ?max_size : Int = -1 ) {
		q = new List();
		
		this.max_size = max_size;
	}
	
	function check_full() : Void {
		if ( q.length >= max_size )
			throw 'FIFO queue overflow ( size > max_size )';
	}
	
	public inline function empty() : Bool { return q.isEmpty(); }

	public inline function put( e: T ) : Void { check_full(); q.add( e ); }
	
	public inline function get() : T { return q.pop(); }
	
	public inline function iterator() : Iterator<T> { return q.iterator(); }
	
	public function toString() : String
	{
		return 'FIFO {' + Lambda.array(this).join(', ') + '}';
	}
	
}
