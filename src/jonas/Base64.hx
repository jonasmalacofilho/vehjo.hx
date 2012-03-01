package jonas;

import haxe.BaseCode;
import haxe.io.Bytes;
using StringTools;

/**
 * Base64 encoder/decoder
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

class Base64 {

	var line_length : Int;
	var b : BaseCode;
	var rc : EReg;
	var pad : String;
	var newline : String;
	
	public function new( c62 = '+', c63 = '/', pad = '=', newline = '\r\n', line_length = 64 ) {
		b = new BaseCode( Bytes.ofString( 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789' + c62 + c63 ) );
		rc = new EReg( '[^ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789' + c62 + c63 + ']', 'g' );
		this.pad = pad;
		this.newline = newline;
		this.line_length = line_length;
	}
	
	function split_lines( s : String ) : String {
		var buf = new StringBuf();
		var i = 0;
		while ( s.length > i ) {
			if ( 0 != i )
				buf.add( newline );
			buf.add( s.substr( i, line_length ) );
			if ( line_length > ( s.length - i ) )
				switch ( ( s.length - i ) % 4 ) {
					case 2:
						buf.add( pad );
						buf.add( pad );
					case 3:
						buf.add( pad );
					default:
						 // do nothing
				}
			i += line_length;
		}
		return buf.toString();
	}
	
	public function encode_string( s : String ) : String {
		return split_lines( b.encodeString( s ) );
	}
	
	function clean( s : String ) : String {
		return rc.replace( s, '' );
	}
	
	public function decode_string( s : String ) : String {
		return b.decodeString( clean( s ) );
	}
	
	public static function encode64( s : String ) : String {
		var b = new Base64();
		return b.encode_string( s );
	}
	
	public static function decode64( s : String ) : String {
		var b = new Base64();
		return b.decode_string( s );
	}
	
}