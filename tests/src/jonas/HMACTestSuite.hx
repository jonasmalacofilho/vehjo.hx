package jonas;

import jonas.HMAC;
import jonas.io.BytesExtension;
using jonas.Base16;

/*
 * HMAC test suite
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

class HMACTestCase extends haxe.unit.TestCase {
	var key : String;
	var data : String;
	var digest : String;
	var truncate : Int;
	var c : HMAC;
	
	public function new( key, data, digest, hash, truncate = 0 ) {
		super();
		this.key = key;
		this.data = data;
		this.digest = digest;
		this.truncate = truncate;
		switch ( hash.toLowerCase() ) {
			case 'md5': c = new HMAC_Md5( key );
			case 'sha1': c = new HMAC_SHA1( key );
			default: throw 'Unkown hash function';
		}
	}
	
	public function test() {
		assertEquals( digest, c.compute( data, truncate ) );
	}
}

class HMACTestSuite {
	public function new() {
		var a = new haxe.unit.TestRunner();
		add_tests( a );
		a.run();
	}
	public static function main() {
		new HMACTestSuite();
	}
	public static function add_tests( a : haxe.unit.TestRunner ) {
		// Test vectors from RFC 2202
		a.add( new HMACTestCase( '0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b'.decode16(), 'Hi There', '9294727a3638bb1c13f48ef8158bfc9d', 'md5' ) );
		a.add( new HMACTestCase( 'Jefe', 'what do ya want for nothing?', '750c783e6ab0b503eaa86e310a5db738', 'md5' ) );
		a.add( new HMACTestCase( 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.decode16(), 'DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD'.decode16(), '56be34521d144c88dbb8c733f0e8b3f6', 'md5' ) );
		a.add( new HMACTestCase( '0102030405060708090a0b0c0d0e0f10111213141516171819'.decode16(), BytesExtension.alloc_filled( 50, 0xcd ).toString(), '697eaf0aca3a3aea3a75164746ffaa79', 'md5' ) );
		a.add( new HMACTestCase( '0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c'.decode16(), 'Test With Truncation', '56461ef2342edc00f9bab995690efd4c', 'md5' ) );
		a.add( new HMACTestCase( '0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c'.decode16(), 'Test With Truncation', '56461ef2342edc00f9bab995', 'md5', 96 ) );
		a.add( new HMACTestCase( BytesExtension.alloc_filled( 80, 0xaa ).toString(), 'Test Using Larger Than Block-Size Key - Hash Key First', '6b1ab7fe4bd7bf8f0b62e6ce61b9d0cd', 'md5' ) );
		a.add( new HMACTestCase( BytesExtension.alloc_filled( 80, 0xaa ).toString(), 'Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data', '6f630fad67cda0ee1fb1f562db3aa53e', 'md5' ) );
		a.add( new HMACTestCase( '0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b'.decode16(), 'Hi There', 'b617318655057264e28bc0b6fb378c8ef146be00', 'sha1' ) );
		a.add( new HMACTestCase( 'Jefe', 'what do ya want for nothing?', 'effcdf6ae5eb2fa2d27416d5f184df9c259a7c79', 'sha1' ) );
		a.add( new HMACTestCase( 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'.decode16(), BytesExtension.alloc_filled( 50, 0xdd ).toString(), '125d7342b9ac11cd91a39af48aa17b4f63f175d3', 'sha1' ) );
		a.add( new HMACTestCase( '0102030405060708090a0b0c0d0e0f10111213141516171819'.decode16(), BytesExtension.alloc_filled( 50, 0xcd ).toString(), '4c9007f4026250c6bc8414f9bf50c86c2d7235da', 'sha1' ) );
		a.add( new HMACTestCase( '0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c'.decode16(), 'Test With Truncation', '4c1a03424b55e07fe7f27be1d58bb9324a9a5a04', 'sha1' ) );
		a.add( new HMACTestCase( '0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c'.decode16(), 'Test With Truncation', '4c1a03424b55e07fe7f27be1', 'sha1', 96 ) );
		a.add( new HMACTestCase( BytesExtension.alloc_filled( 80, 0xaa ).toString(), 'Test Using Larger Than Block-Size Key - Hash Key First', 'aa4ae5e15272d00e95705637ce8a3b55ed402112', 'sha1' ) );
		a.add( new HMACTestCase( BytesExtension.alloc_filled( 80, 0xaa ).toString(), 'Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data', 'e8e99d0f45237d786d6bbaa7965c7808bbff1a91', 'sha1' ) );
		//a.add( new HMACTestCase( BytesExtension.alloc_filled( 80, 0xaa ).toString(), 'e8e99d0f45237d786d6bbaa7965c7808bbff1a91'.decode16(), '4c1a03424b55e07fe7f27be1d58bb9324a9a5a04', 'sha1' ) );
		// Other test vectors
		a.add( new HMACTestCase( '', '', '74e6f7298a9c2d168935f58c001bad88', 'md5' ) );
		a.add( new HMACTestCase( '', '', 'fbdb1d1b18aa6c08324b7d64b71fb76370690e1d', 'sha1' ) );
		a.add( new HMACTestCase( 'key', 'The quick brown fox jumps over the lazy dog', '80070713463e7749b90c2dc24911e275', 'md5' ) );
		a.add( new HMACTestCase( 'key', 'The quick brown fox jumps over the lazy dog', '80070713463e7749b90c2dc24911e274', 'md5', 127 ) );
		a.add( new HMACTestCase( 'key', 'The quick brown fox jumps over the lazy dog', 'de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9', 'sha1' ) );
	}
}