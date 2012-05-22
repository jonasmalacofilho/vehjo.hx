package jonas;

import haxe.BaseCode;
import haxe.io.Bytes;

/**
 * Base16 (hex) encoder/decoder
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */

class Base16 {
	
	static var base = Bytes.ofString( '0123456789abcdef' );

	public static inline function encode16( s : String ) : String {
		return new BaseCode( base ).encodeString( s );
	}
	
	public static inline function encodeBytes16( b : Bytes ) : Bytes {
		return new BaseCode( base ).encodeBytes( b );
	}
	
	public static inline function toHex( s : String ) : String {
		return encode16( s );
	}
	
	public static inline function decode16( s : String ) : String {
		return new BaseCode( base ).decodeString( s.toLowerCase() );
	}
	
	public static inline function decodeBytes16( b : Bytes ) : Bytes {
		return new BaseCode( base ).decodeBytes( b );
	}
	
	public static inline function fromHex( s : String ) : String {
		return decode16( s );
	}
	
}