package jonas;

import jonas.Base64;

/*
 * Base64 test suite
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
 
class Base64SimpleTestCase extends haxe.unit.TestCase {
	var inp : String;
	var out : String;
	var b : Base64;
	
	public function new( inp, out, c62 = '+', c63 = '/', pad = '=', newline = '\r\n', line_length = 64 ) {
		super();
		this.inp = inp;
		this.out = out;
		b = new Base64( c62, c63, pad, newline, line_length );
	}
	
	public function test_encode() : Void {
		assertEquals( out, b.encode_string( inp ) );
	}
	
	public function test_encode_decode() : Void {
		assertEquals( inp, b.decode_string( b.encode_string( inp ) ) );
	}
}

class Base64TestSuite {
	public function new() {
		var a = new haxe.unit.TestRunner();
		add_tests( a );
		a.run();
	}
	public static function main() {
		new Base64TestSuite();
	}
	public static function add_tests( a : haxe.unit.TestRunner ) {
		a.add( new Base64SimpleTestCase( 'any carnal pleasure.', 'YW55IGNhcm5hbCBwbGVhc3VyZS4=' ) );
		a.add( new Base64SimpleTestCase( 'any carnal pleasure', 'YW55IGNhcm5hbCBwbGVhc3VyZQ==' ) );
		a.add( new Base64SimpleTestCase( 'any carnal pleasur', 'YW55IGNhcm5hbCBwbGVhc3Vy' ) );
		a.add( new Base64SimpleTestCase( 'any carnal pleasu', 'YW55IGNhcm5hbCBwbGVhc3U=' ) );
		a.add( new Base64SimpleTestCase( 'any carnal pleas', 'YW55IGNhcm5hbCBwbGVhcw==' ) );
		a.add( new Base64SimpleTestCase( 'pleasure.', 'cGxlYXN1cmUu' ) );
		a.add( new Base64SimpleTestCase( 'leasure.', 'bGVhc3VyZS4=' ) );
		a.add( new Base64SimpleTestCase( 'easure.', 'ZWFzdXJlLg==' ) );
		a.add( new Base64SimpleTestCase( 'asure.', 'YXN1cmUu' ) );
		a.add( new Base64SimpleTestCase( 'sure.', 'c3VyZS4=' ) );
		a.add( new Base64SimpleTestCase( 'Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure.',
'TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlz
IHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2Yg
dGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGlu
dWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRo
ZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=', 76 ) );
	}
}
