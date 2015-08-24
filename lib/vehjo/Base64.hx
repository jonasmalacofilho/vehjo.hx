package vehjo;

import haxe.crypto.BaseCode;
import haxe.io.Bytes;
using StringTools;

/**
	Base64 encoder/decoder
**/
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
	
	public function encode_bytes( bytes : Bytes ) : String {
		return split_lines( b.encodeBytes( bytes ).toString() );
	}
	
	function clean( s : String ) : String {
		return rc.replace( s, '' );
	}
	
	public function decode_string( s : String ) : String {
		return b.decodeString( clean( s ) );
	}
	
	public function decode_bytes( s : String ) : Bytes {
		return b.decodeBytes( Bytes.ofString( clean( s ) ) );
	}
	
	public static function encode64( s : String ) : String {
		return new Base64().encode_string( s );
	}
	
	public static function encodeBytes64( bytes : Bytes ) : String {
		return new Base64().encode_bytes( bytes );
	}
	
	public static function decode64( s : String ) : String {
		return new Base64().decode_string( s );
	}
	
	public static function decodeBytes64( s : String ) : Bytes {
		return new Base64().decode_bytes( s );
	}
	
}