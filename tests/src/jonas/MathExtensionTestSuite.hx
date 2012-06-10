package jonas;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;
#if neko
import neko.vm.Thread;
#end
using jonas.MathExtension;

/**
 * MathExtension test suite
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

class MathExtensionTestSuite extends TestCase
{
	
	public static function add_tests( a : haxe.unit.TestRunner ) {
		a.add( new MathExtensionTestSuite() );
	}
	
	static inline var THREADS = 1;
	
	public static function main()
	{
	#if neko
		
		var ts = new List();
		for (i in 0...THREADS) {
			var t = Thread.create(run);
			ts.push(t);
		}
		
		for (t in ts)
			t.sendMessage(Thread.current());
		
		while (!ts.isEmpty())
			ts.remove(Thread.readMessage(true));
	
	#else
		run();
	#end
	}
	
	static function run()
	{
	#if neko
		var main : Thread = Thread.readMessage(true);
	#end
	
		var r = new TestRunner();
		r.add(new MathExtensionTestSuite());
		r.run();
		
	#if neko
		main.sendMessage(Thread.current());
	#end
	}
	
	public function test_round()
	{ // Follows the Math.round convention: rounds half-way values up
		assertEquals(23., 23.235.round(0));
		assertEquals(23.24, 23.235.round(2));
		assertEquals(23.25, 23.245.round(2));
		assertEquals((-23.23), (-23.235).round(2));
		assertEquals((-23.24), (-23.245).round(2));
		assertEquals(0., 2.3235e-5.round(2));
		assertEquals(2.3235e15, 2.3235e15.round(2));
		assertEquals(2.3234e14, 2.3234e14.round(2));
		assertEquals(2.3234e25, 2.3234e25.round(2));
		assertEquals(298273.2387239, 298273.23872387.round(7));
		assertEquals(71623762137812.23762736273, 71623762137812.23762736273.round(8));
		assertEquals(1073741823.1073741823, 1073741823.1073741823.round(10));
		assertEquals((-34836836112232322312123.42), (-34836836112232322312123.42).round(1));
		
	}
	
}