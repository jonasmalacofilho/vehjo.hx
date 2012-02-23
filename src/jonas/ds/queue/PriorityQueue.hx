package jonas.ds.queue;

import jonas.ds.DAryHeap;

/*
 * Priority queue
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
 * Priority queue
 * Currently implemented using an array based D-ary (binary) heap
 */
class PriorityQueue<T> extends DAryHeap<T>, implements Queue<T> {
	
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