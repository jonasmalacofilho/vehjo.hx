package jonas;

import haxe.io.Bytes;
import jonas.io.BytesExtension;
using jonas.Base16;
using jonas.io.BytesExtension;

/**
	Haxe implementation for RFC 2104 - HMAC: Keyed-Hashing for Message Authentication
	                 HMAC = H( K XOR opad, H( K XOR ipad, text ) )
	
	References:
	http://tools.ietf.org/html/rfc2104: HMAC: Keyed-Hashing for Message Authentication
	http://tools.ietf.org/html/rfc2202: Test Cases for HMAC-MD5 and HMAC-SHA-1
	
	Depends on the hash implementation being able to handle any binary data in strings
**/
class HMAC {
	
	var B : Int;
	var key : Bytes;
	
	/**
	 * Hashing function, must return the digest encoded in base 0123456789abcdef
	 */
	function hash( b : Bytes ) : String {
		throw 'Not implemented';
		return '';
	}
	
	/**
	 * Computes the HMAC for s, using the given key
	 * If truncate > 0, than only the truncate most significant bits will be displayed
	 */
	public function compute( b : Bytes, truncate = 0 ) : String {
		var secret;
		if ( B >= key.length )
			secret = key.rpad( B, 0 );
		else
			secret = hash( key ).decodeBytes16().rpad( B, 0 );
		var ipad = BytesExtension.alloc_filled( B, 0x36 );
		var opad = BytesExtension.alloc_filled( B, 0x5c );
		var hmac = hash( secret.xor( opad ).append( hash( secret.xor( ipad ).append( b ) ).decodeBytes16() ) );
		if ( 0 == truncate )
			return hmac;
		else {
			var exbt = truncate % 8;
			if ( 0 == exbt ) {
				return hmac.decodeBytes16().sub( 0, Math.floor( truncate / 8 ) ).encodeBytes16() ;
			}
			else {
				var byt = Math.round( ( truncate - exbt ) / 8 );
				var a = hmac.decodeBytes16().sub( 0, byt + 1 );
				a.set( byt, a.get( byt ) & ( 255 << ( 8 - exbt ) ) );
				return a.encodeBytes16();
			}
		}
	}
	
	public static function hmac_md5( key : String, data : String, truncate = 0 ) : String {
		return new HMAC_Md5( Bytes.ofString( key ) ).compute( Bytes.ofString( data ), truncate );
	}
	
	public static function hmac_sha1( key : String, data : String, truncate = 0 ) : String {
		return new HMAC_SHA1( Bytes.ofString( key ) ).compute( Bytes.ofString( data ), truncate );
	}
}

class HMAC_Md5 extends HMAC {
	public function new( key : Bytes ) {
		this.key = key;
		B = 64;
	}
	override function hash( b : Bytes ) : String {
		return haxe.crypto.Md5.encode( b.toString() );
	}
}

class HMAC_SHA1 extends HMAC_Md5 {
	override function hash( b : Bytes ) : String {
		return haxe.crypto.Sha1.encode( b.toString() );
	}
}