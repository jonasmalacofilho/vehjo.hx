package jonas.ds.queue;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import jonas.ds.queue.SimpleFIFO;

/*
 * Copyright (c) 2011 Jonas Malaco Filho
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
 * ...
 * @author Jonas Malaco Filho
 */

class SimpleFIFOTestSuite extends TestCase
{

	static function main()
	{
		var r = new TestRunner();
		add_tests( r );
		r.run();
	}
	
	public static function add_tests( r : TestRunner ) {
		r.add(new SimpleFIFOTestSuite());
	}
	
	public function test_put()
	{
		var q = new SimpleFIFO(10);
		assertEquals('FIFO {}', q.toString());
		q.put(1);
		assertEquals('FIFO {1}', q.toString());
		q.put(10);
		assertEquals('FIFO {1, 10}', q.toString());
		q.put(100);
		assertEquals('FIFO {1, 10, 100}', q.toString());
	}
	
	public function test_get()
	{
		var q = new SimpleFIFO(10);
		q.put(1);
		q.put(10);
		q.put(100);
		assertEquals(1, q.get());
		assertEquals('FIFO {10, 100}', q.toString());
		assertEquals(10, q.get());
		assertEquals('FIFO {100}', q.toString());
		assertEquals(100, q.get());
		assertEquals('FIFO {}', q.toString());
		assertEquals(null, q.get());
		assertEquals('FIFO {}', q.toString());
	}
	
	public function test_put_and_get()
	{
		var q = new SimpleFIFO(10);
		assertEquals('FIFO {}', q.toString());
		q.put(1);
		assertEquals('FIFO {1}', q.toString());
		q.put(10);
		assertEquals('FIFO {1, 10}', q.toString());
		q.put(100);
		assertEquals('FIFO {1, 10, 100}', q.toString());
		assertEquals(1, q.get());
		assertEquals('FIFO {10, 100}', q.toString());
		assertEquals(10, q.get());
		assertEquals('FIFO {100}', q.toString());
		assertEquals(100, q.get());
		assertEquals('FIFO {}', q.toString());
		assertEquals(null, q.get());
		assertEquals('FIFO {}', q.toString());
		q.put(1);
		assertEquals('FIFO {1}', q.toString());
		q.put(10);
		assertEquals('FIFO {1, 10}', q.toString());
		assertEquals(1, q.get());
		assertEquals('FIFO {10}', q.toString());
		q.put(100);
		assertEquals('FIFO {10, 100}', q.toString());
		q.put(1);
		assertEquals('FIFO {10, 100, 1}', q.toString());
		assertEquals(10, q.get());
		assertEquals('FIFO {100, 1}', q.toString());
	}
	
	public function test_limits()
	{
		var q = new SimpleFIFO(5);
		q.put(1);
		q.put(10);
		q.put(100);
		q.put(1000);
		q.put(10000);
		assertFalse(
			try { q.put(1000000); true; }
			catch (e : String) { false; }
		);
		q.get();
		q.put(2);
		assertFalse(
			try { q.put(-2); true; }
			catch (e : String) { false; }
		);
	}
	
}