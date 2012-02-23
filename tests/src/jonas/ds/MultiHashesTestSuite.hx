package jonas.ds;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import jonas.ds.IntMultiHash;
import jonas.ds.MultiHash;
using jonas.ds.IntMultiHash;
using jonas.ds.MultiHash;

/**
 * MutiHash and IntMultiHash test suite
 * Copyright (c) 2012 Jonas Malaco Filho
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:�
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

class MultiHashesTestSuite
{
	static function main()
	{
		var r = new TestRunner();
		add_tests( r );
		r.run();
	}
	
	public static function add_tests( r : TestRunner ) {
		r.add(new MultiHashTests());
		r.add(new IntMultiHashTests());
	}
}
 
class MultiHashTests extends TestCase
{
	
	function _create()
	{
		var a = ["foo", "bar", "soap"];
		var b = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
		var h = new MultiHash();
		h.push(a[0], b[0]);
		h.push(a[2], b[7]);
		h.push(a[1], b[3]);
		h.push(a[1], b[2]);
		h.push(a[2], b[9]);
		h.push(a[0], b[4]);
		h.push(a[1], b[6]);
		h.push(a[0], b[5]);
		h.push(a[2], b[8]);
		h.push(a[1], b[1]);
		return h;
	}
	
	public function test_push()
	{
		var a = new MultiHash();
		assertEquals("{}", a.toString());
		
		var b = _create();
		assertEquals("{bar => {2, 7, 3, 4}, foo => {6, 5, 1}, soap => {9, 10, 8}}", b.toString());
	}
	
	public function test_get()
	{
		var a = new MultiHash();
		assertEquals("{}", a.toString());
		
		var b = _create();
		assertEquals("{2, 7, 3, 4}", b.get("bar").toString());
		assertEquals("{}", b.get("foobar").toString());
	}
	
	public function test_remove()
	{
		var a = new MultiHash();
		a.remove("foo");
		assertEquals("{}", a.toString());
		
		var b = _create();
		b.remove("foo");
		assertEquals("{2, 7, 3, 4}", b.get("bar").toString());
		assertEquals("{}", b.get("foo").toString());
	}

	public function test_remove_specific()
	{
		var a = new MultiHash();
		a.remove_specific("foo", function(x) { return 0 != x % 2; } );
		assertEquals("{}", a.toString());
		
		var b = _create();
		b.remove_specific("foo", function(x) { return 0 != x % 2; } );
		assertEquals("{2, 7, 3, 4}", b.get("bar").toString());
		assertEquals("{5, 1}", b.get("foo").toString());
	}
	
	public function test_values()
	{
		var a = new MultiHash();
		var x = new List();
		for (v in a.values())
			x.add(v);
		assertEquals("{}", x.toString());
			
		var b = _create();
		var y = new List();
		for (v in b.values())
			y.add(v);
		assertEquals("{2, 7, 3, 4, 6, 5, 1, 9, 10, 8}", y.toString());
	}
	
	public function test_pop()
	{
		var a = new MultiHash();
		a.pop("foo");
		assertEquals("{}", a.toString());
		
		var b = _create();
		b.pop("foo");
		assertEquals("{2, 7, 3, 4}", b.get("bar").toString());
		assertEquals("{5, 1}", b.get("foo").toString());
		b.pop("foo");
		assertEquals("{1}", b.get("foo").toString());
		b.pop("foo");
		assertEquals("{}", b.get("foo").toString());
		b.pop("foo");
		assertEquals("{}", b.get("foo").toString());
	}
	
	public function test_group_by_hash()
	{
		var a = [1.1 , 2.32, 3.51, 4.12, 1.15];
		assertEquals("{4 => {4.12}, 3 => {3.51}, 2 => {2.32}, 1 => {1.15, 1.1}}",
			MultiHash.groupByHash(a, function(x)
			{
				return Std.string(Std.int(x));
			}).toString());
	}
}

class IntMultiHashTests extends TestCase
{
	function _create()
	{
		var a = [23, 73, 93];
		var b = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
		var h = new IntMultiHash();
		h.push(a[0], b[0]);
		h.push(a[2], b[7]);
		h.push(a[1], b[3]);
		h.push(a[1], b[2]);
		h.push(a[2], b[9]);
		h.push(a[0], b[4]);
		h.push(a[1], b[6]);
		h.push(a[0], b[5]);
		h.push(a[2], b[8]);
		h.push(a[1], b[1]);
		return h;
	}
	
	public function test_push()
	{
		var a = new IntMultiHash();
		assertEquals("{}", a.toString());
		
		var b = _create();
		assertEquals("{73 => {2, 7, 3, 4}, 23 => {6, 5, 1}, 93 => {9, 10, 8}}", b.toString());
	}
	
	public function test_get()
	{
		var a = new IntMultiHash();
		assertEquals("{}", a.toString());
		
		var b = _create();
		assertEquals("{2, 7, 3, 4}", b.get(73).toString());
		assertEquals("{}", b.get(2373).toString());
	}
	
	public function test_remove()
	{
		var a = new IntMultiHash();
		a.remove(23);
		assertEquals("{}", a.toString());
		
		var b = _create();
		b.remove(23);
		assertEquals("{2, 7, 3, 4}", b.get(73).toString());
		assertEquals("{}", b.get(23).toString());
	}

	public function test_remove_specific()
	{
		var a = new IntMultiHash();
		a.remove_specific(23, function(x) { return 0 != x % 2; } );
		assertEquals("{}", a.toString());
		
		var b = _create();
		b.remove_specific(23, function(x) { return 0 != x % 2; } );
		assertEquals("{2, 7, 3, 4}", b.get(73).toString());
		assertEquals("{5, 1}", b.get(23).toString());
	}
	
	public function test_values()
	{
		var a = new IntMultiHash();
		var x = new List();
		for (v in a.values())
			x.add(v);
		assertEquals("{}", x.toString());
			
		var b = _create();
		var y = new List();
		for (v in b.values())
			y.add(v);
		assertEquals("{2, 7, 3, 4, 6, 5, 1, 9, 10, 8}", y.toString());
	}
	
	public function test_pop()
	{
		var a = new IntMultiHash();
		a.pop(23);
		assertEquals("{}", a.toString());
		
		var b = _create();
		b.pop(23);
		assertEquals("{2, 7, 3, 4}", b.get(73).toString());
		assertEquals("{5, 1}", b.get(23).toString());
		b.pop(23);
		assertEquals("{1}", b.get(23).toString());
		b.pop(23);
		assertEquals("{}", b.get(23).toString());
		b.pop(23);
		assertEquals("{}", b.get(23).toString());
	}
	
	public function test_group_by_hash()
	{
		var a = [1.1 , 2.32, 3.51, 4.12, 1.15];
		assertEquals("{4 => {4.12}, 3 => {3.51}, 2 => {2.32}, 1 => {1.15, 1.1}}",
			IntMultiHash.groupByHash(a, function(x)
			{
				return Std.int(x);
			}).toString());
	}
	
}