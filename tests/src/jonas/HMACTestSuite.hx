package jonas;

import haxe.Md5;
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

class HMACTestCase extends jonas.unit.TestCase {
	var key : String;
	var data : String;
	var digest : String;
	var truncate : Int;
	var c : HMAC;
	
	public function new() {
		super();
		// Test vectors from RFC 2202
		set_configuration( 'RFC 2202 - 01', { key : '0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b'.decode16(), data : 'Hi There', digest : '9294727a3638bb1c13f48ef8158bfc9d', hash : 'md5', truncate : 0 } );
		set_configuration( 'RFC 2202 - 02', { key : 'Jefe', data : 'what do ya want for nothing?', digest : '750c783e6ab0b503eaa86e310a5db738', hash : 'md5', truncate : 0 } );
		set_configuration( 'RFC 2202 - 03', { key : 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.decode16(), data : 'DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD'.decode16(), digest : '56be34521d144c88dbb8c733f0e8b3f6', hash : 'md5', truncate : 0 } );
		set_configuration( 'RFC 2202 - 04', { key : '0102030405060708090a0b0c0d0e0f10111213141516171819'.decode16(), data : BytesExtension.alloc_filled( 50, 0xcd ).toString(), digest : '697eaf0aca3a3aea3a75164746ffaa79', hash : 'md5', truncate : 0 } );
		set_configuration( 'RFC 2202 - 05', { key : '0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c'.decode16(), data : 'Test With Truncation', digest : '56461ef2342edc00f9bab995690efd4c', hash : 'md5', truncate : 0 } );
		set_configuration( 'RFC 2202 - 06', { key : '0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c'.decode16(), data : 'Test With Truncation', digest : '56461ef2342edc00f9bab995', hash : 'md5', truncate : 96 } );
		set_configuration( 'RFC 2202 - 07', { key : BytesExtension.alloc_filled( 80, 0xaa ).toString(), data : 'Test Using Larger Than Block-Size Key - Hash Key First', digest : '6b1ab7fe4bd7bf8f0b62e6ce61b9d0cd', hash : 'md5', truncate : 0 } );
		set_configuration( 'RFC 2202 - 08', { key : BytesExtension.alloc_filled( 80, 0xaa ).toString(), data : 'Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data', digest : '6f630fad67cda0ee1fb1f562db3aa53e', hash : 'md5', truncate : 0 } );
		set_configuration( 'RFC 2202 - 09', { key : '0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b'.decode16(), data : 'Hi There', digest : 'b617318655057264e28bc0b6fb378c8ef146be00', hash : 'sha1', truncate : 0 } );
		set_configuration( 'RFC 2202 - 10', { key : 'Jefe', data : 'what do ya want for nothing?', digest : 'effcdf6ae5eb2fa2d27416d5f184df9c259a7c79', hash : 'sha1', truncate : 0 } );
		set_configuration( 'RFC 2202 - 11', { key : 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'.decode16(), data : BytesExtension.alloc_filled( 50, 0xdd ).toString(), digest : '125d7342b9ac11cd91a39af48aa17b4f63f175d3', hash : 'sha1', truncate : 0 } );
		set_configuration( 'RFC 2202 - 12', { key : '0102030405060708090a0b0c0d0e0f10111213141516171819'.decode16(), data : BytesExtension.alloc_filled( 50, 0xcd ).toString(), digest : '4c9007f4026250c6bc8414f9bf50c86c2d7235da', hash : 'sha1', truncate : 0 } );
		set_configuration( 'RFC 2202 - 13', { key : '0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c'.decode16(), data : 'Test With Truncation', digest : '4c1a03424b55e07fe7f27be1d58bb9324a9a5a04', hash : 'sha1', truncate : 0 } );
		set_configuration( 'RFC 2202 - 14', { key : '0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c'.decode16(), data : 'Test With Truncation', digest : '4c1a03424b55e07fe7f27be1', hash : 'sha1', truncate : 96 } );
		set_configuration( 'RFC 2202 - 15', { key : BytesExtension.alloc_filled( 80, 0xaa ).toString(), data : 'Test Using Larger Than Block-Size Key - Hash Key First', digest : 'aa4ae5e15272d00e95705637ce8a3b55ed402112', hash : 'sha1', truncate : 0 } );
		set_configuration( 'RFC 2202 - 16', { key : BytesExtension.alloc_filled( 80, 0xaa ).toString(), data : 'Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data', digest : 'e8e99d0f45237d786d6bbaa7965c7808bbff1a91', hash : 'sha1', truncate : 0 } );
		// Other test vectors
		set_configuration( 'Other - 01', { key : '', data : '', digest : '74e6f7298a9c2d168935f58c001bad88', hash : 'md5', truncate : 0 } );
		set_configuration( 'Other - 02', { key : '', data : '', digest : 'fbdb1d1b18aa6c08324b7d64b71fb76370690e1d', hash : 'sha1', truncate : 0 } );
		set_configuration( 'Other - 03', { key : 'key', data : 'The quick brown fox jumps over the lazy dog', digest : '80070713463e7749b90c2dc24911e275', hash : 'md5', truncate : 0 } );
		set_configuration( 'Other - 04', { key : 'key', data : 'The quick brown fox jumps over the lazy dog', digest : '80070713463e7749b90c2dc24911e274', hash : 'md5', truncate : 127 } );
		set_configuration( 'Other - 05', { key : 'key', data : 'The quick brown fox jumps over the lazy dog', digest : 'de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9', hash : 'sha1', truncate : 0 } );
		_config_default = 'RFC 2202 - 14';
	}
		
	override function configure( name : String ) : Void {
		var c = _configs.get( name );
		key = c.key;
		data = c.data;
		digest = c.digest;
		truncate = c.truncate;
		switch ( c.hash.toLowerCase() ) {
			case 'md5': this.c = new HMAC_Md5( key );
			case 'sha1': this.c = new HMAC_SHA1( key );
			default: throw 'Unkown hash function';
		}
	}
	
	public function test() {
		assertEquals( digest, c.compute( data, truncate ) );
	}
	
	public function testMd5() {
		assertEquals( 'd41d8cd98f00b204e9800998ecf8427e', Md5.encode( '' ) );
		assertEquals( 'e4d909c290d0fb1ca068ffaddf22cbd0', Md5.encode( 'The quick brown fox jumps over the lazy dog.' ) );
		assertEquals( '9e107d9d372bb6826bd81d3542a419d6', Md5.encode( 'The quick brown fox jumps over the lazy dog' ) );
	}
	
	public function testBaseCode() {
		var a = 'c5738ffbaa1ff9d62e688841e89e608e';
		assertEquals( a, Base16.encode16( Base16.decode16( a ) ) );
	}
	
}

class HMACTestSuite {
	static function main() {
		var a = new jonas.unit.TestRunner();
		add_tests( a );
		a.run();
	}
	public static function add_tests( a : haxe.unit.TestRunner ) {
		a.add( new HMACTestCase() );
	}
}