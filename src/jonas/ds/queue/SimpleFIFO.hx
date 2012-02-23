package jonas.ds.queue;

/*
 * FIFO queue
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