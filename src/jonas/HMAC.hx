package jonas;

import haxe.io.Bytes;
import jonas.io.BytesExtension;
using jonas.Base16;
using jonas.io.BytesExtension;

/**
 * haXe implementation for RFC 2104 - HMAC: Keyed-Hashing for Message Authentication
 *                  HMAC = H( K XOR opad, H( K XOR ipad, text ) )
 * 
 * References:
 * http://tools.ietf.org/html/rfc2104: HMAC: Keyed-Hashing for Message Authentication
 * http://tools.ietf.org/html/rfc2202: Test Cases for HMAC-MD5 and HMAC-SHA-1
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

class HMAC {
	
	var B : Int;
	var key : String;
	
	/**
	 * Hashing function, must return the digest encoded in base 0123456789abcdef
	 */
	function hash( s : String ) : String {
		throw 'Not implemented';
		return '';
	}
	
	/**
	 * Computes the HMAC for s, using the given key
	 * If truncate > 0, than only the truncate most significant bits will be displayed
	 */
	public function compute( s : String, truncate = 0 ) : String {
		var secret;
		if ( B >= key.length )
			secret = Bytes.ofString( key ).rpad( B, 0 );
		else
			secret = Bytes.ofString( hash( key ).decode16() ).rpad( B, 0 );
		var t = Bytes.ofString( s );
		var ipad = BytesExtension.alloc_filled( B, 0x36 );
		var opad = BytesExtension.alloc_filled( B, 0x5c );
		var hmac = hash( secret.xor( opad ).append( Bytes.ofString( hash( secret.xor( ipad ).append( t ).toString() ).decode16() ) ).toString() );
		if ( 0 == truncate )
			return hmac;
		else {
			var exbt = truncate % 8;
			if ( 0 == exbt ) {
				return Bytes.ofString( hmac.decode16() ).sub( 0, Math.floor( truncate / 8 ) ).toHex() ;
			}
			else {
				var byt = Math.round( ( truncate - exbt ) / 8 );
				var a = Bytes.ofString( hmac.decode16() ).sub( 0, byt + 1 );
				a.set( byt, a.get( byt ) & ( 255 << ( 8 - exbt ) ) );
				return a.toHex();
			}
		}
	}
	
	public static function hmac_md5( key : String, data : String, truncate = 0 ) : String {
		return new HMAC_Md5( key ).compute( data, truncate );
	}
	
	public static function hmac_sha1( key : String, data : String, truncate = 0 ) : String {
		return new HMAC_SHA1( key ).compute( data, truncate );
	}
}

class HMAC_Md5 extends HMAC {
	public function new( key : String ) {
		this.key = key;
		B = 64;
	}
	override function hash( s : String ) : String {
		return haxe.Md5.encode( s );
	}
}

class HMAC_SHA1 extends HMAC_Md5 {
	override function hash( s : String ) : String {
		return haxe.SHA1.encode( s );
	}
}