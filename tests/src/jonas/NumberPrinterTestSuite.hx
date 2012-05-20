package jonas;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import jonas.NumberPrinter;
#if neko
import neko.vm.Thread;
#end
using jonas.NumberPrinter;

/**
 * NumberPrinter test suite
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

class NumberPrinterTestSuite extends TestCase
{

	public static function add_tests( a : haxe.unit.TestRunner ) {
		a.add( new NumberPrinterTestSuite() );
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
		r.add(new NumberPrinterTestSuite());
		r.run();
		
	#if neko
		main.sendMessage(Thread.current());
	#end
	}
	
	function assertMatch(pattern : String, string : String, ?options='')
	{
		assertEquals(pattern + ' ' + options, new EReg(pattern, options).match(string) ? pattern + ' ' + options : string);
	}

	public function test_printInteger_withInts()
	{
		var a : Int = 23;
		assertEquals("23", a.printInteger());
		assertEquals(" 023", a.printInteger(4, 3));
		assertEquals("   023", a.printInteger(6, 3));
		assertEquals("23", a.printInteger(1, 1));
	}
	
	public function test_printInteger_withNegativeInts()
	{
		var a : Int = -23;
		assertEquals("-23", a.printInteger());
		assertEquals("-023", a.printInteger(4, 3));
		assertEquals("  -023", a.printInteger(6, 3));
		assertEquals("-23", a.printInteger(1, 1));
	}
	
	public function test_printInteger_withFloats()
	{
		var a : Float = 23.231512;
		assertEquals("23", a.printInteger());
		assertEquals(" 023", a.printInteger(4, 3));
		assertEquals("   023", a.printInteger(6, 3));
		assertEquals("23", a.printInteger(1, 1));
	}
	
	public function test_printInteger_withFloatInts()
	{
		var a : Float = 23;
		assertEquals("23", a.printInteger());
		assertEquals(" 023", a.printInteger(4, 3));
		assertEquals("   023", a.printInteger(6, 3));
		assertEquals("23", a.printInteger(1, 1));
	}
	
	public function test_printInteger_withLargeFloats()
	{
		var r = '^-348368361122323((22312123)|(220{6})|(0{8}))$';
		var a : Float = -34836836112232322312123.42;
		assertMatch('^-348368361122323((22312123)|(220{6})|(0{8}))$', a.printInteger());
	}
	
	public function test_printInteger_withSmallFloats()
	{
		var a : Float = .000000000000023124;
		assertEquals("0", a.printInteger());
	}
	
	public function test_printDecimal_withFloats()
	{
		var a : Float = 23.23151223;
		assertEquals("23.231512", a.printDecimal(1, 6));
		assertMatch("^23.23[2]$", a.printDecimal(4, 3));
		assertEquals("23.2315", a.printDecimal(2, 4));
		assertMatch("^    23.23[2]$", a.printDecimal(10, 3));
		assertEquals("23.2", a.printDecimal());
	}
	
	public function test_printDecimal_withNegativeFloats()
	{
		var a : Float = -23.23151223;
		assertEquals("-23.231512", a.printDecimal(1, 6));
		assertMatch("^-23.23[2]$", a.printDecimal(4, 3));
		assertEquals("-23.2315", a.printDecimal(2, 4));
		assertMatch("^   -23.23[2]$", a.printDecimal(10, 3));
		assertEquals("-23.2", a.printDecimal());
	}

	public function test_printDecimal_withInts()
	{
		var a : Int = 23;
		assertEquals("23.000000", a.printDecimal(1, 6));
		assertEquals("23.000", a.printDecimal(4, 3));
		assertEquals("23.0000", a.printDecimal(2, 4));
		assertEquals("    23.000", a.printDecimal(10, 3));
		assertEquals("23.0", a.printDecimal());
	}
	
	public function test_printDecimal_withLargeFloats()
	{
		var r = '^-348368361122323((22312123)|(220{6})|(0{8}))\\.0$';
		var a : Float = -34836836112232322312123.42;
		assertMatch('^-348368361122323((22312123)|(220{6})|(0{8}))\\.0$', a.printDecimal());
	}
	
	public function test_printDecimal_withSmallFloats()
	{
		var a : Float = .000000000000023124;
		assertEquals("0.0", a.printDecimal());
		assertEquals("0.00000000000002312400", a.printDecimal(1, 20));
	}
	
	public function test_printDecimal_inside_limits1()
	{
		var s = Std.string(0x3FFFFFFF);
		var digits = Std.string(0x3FFFFFFF).length;
		var a = 0x3FFFFFFF + 0x3FFFFFFF / Math.pow(10., digits);
		assertEquals(StringTools.rpad(Std.string(a), '0', 2 * digits + 1), a.printDecimal(1, digits));
	}
	
	public function test_printDecimal_inside_limits2()
	{
		var s = Std.string(0x3FFFFFFF);
		var digits = Std.string(0x3FFFFFFF).length;
		var a = (0x3FFFFFFF * 10000.) + (0x3FFFFFFF / Math.pow(10., digits));
		assertEquals(StringTools.rpad(Std.string(a), '0', 2 * digits + 5), a.printDecimal(1, digits));
	}
	
}