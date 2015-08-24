package vehjo;

import haxe.crypto.BaseCode;
import haxe.crypto.Md5;
import vehjo.HMAC;
import vehjo.io.BytesExtension;
using vehjo.Base16;

/**
	HMAC test suite
**/
class HMACTestCase extends vehjo.unit.TestCase {
	var key : String;
	var data : String;
	var digest : String;
	var truncate : Int;
	var hash : String;
	
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
	
	public function test() {
		assertEquals( digest, switch ( hash.toLowerCase() ) {
			case 'md5' :
				HMAC.hmac_md5( key, data, truncate );
			case 'sha1' :
				HMAC.hmac_sha1( key, data, truncate );
			case _: throw 'unkown hash function $hash';
		}, pos_infos( 'unsafe string based hash function ($hash)' ) );
	}
	
}

class HMACTestSuite {
	static function main() {
		var a = new vehjo.unit.TestRunner();
		add_tests( a );
		a.run();
	}
	public static function add_tests( a : haxe.unit.TestRunner ) {
		a.add( new HMACTestCase() );
	}
}