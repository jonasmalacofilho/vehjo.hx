package vehjo.ds.queue;

/**
 * Queue interface
 */
interface Queue<T> {

	public function empty() : Bool;
	public function put( e : T ) : Void;
	public function get() : T;
	
}
