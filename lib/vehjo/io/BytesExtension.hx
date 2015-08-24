package vehjo.io;

import haxe.io.Bytes;

/*
 * Bytes extensions
 * 
 * Copyright (c) 2011 Jonas Malaco Filho
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


class BytesExtension {
	
	public static function alloc_filled( length : Int, v : Int ) : Bytes {
		var b = Bytes.alloc( length );
		for ( i in 0...length )
			b.set( i, v );
		return b;
	}
	
	public static function xor( a : Bytes, b : Bytes ) : Bytes {
		//trace( 'xor' );
		if ( a.length != b.length )
			throw 'Both Bytes should have the same length';
		var r = Bytes.alloc( a.length );
		for ( i in 0...r.length )
			r.set( i, a.get( i ) ^ b.get( i ) );
		//trace( a.toHex() );
		//trace( b.toHex() );
		//trace( r.toHex() );
		return r;
	}
	
	public static function rpad( a : Bytes, l : Int, v : Int ) : Bytes {
		//trace( 'rpad' );
		if ( l == a.length )
			return a;
		var r = Bytes.alloc( l );
		for ( i in 0...a.length )
			r.set( i, a.get( i ) );
		for ( i in a.length...l )
			r.set( i, v );
		//trace( a.toHex() );
		//trace( r.toHex() );
		return r;
	}
	
	public static function append( a : Bytes, b : Bytes ) : Bytes {
		//trace( 'append' );
		var r = Bytes.alloc( a.length + b.length );
		var k = a.length;
		for ( i in 0...k )
			r.set( i, a.get( i ) );
		for ( i in 0...b.length )
			r.set( i + k, b.get( i ) );
		//trace( a.toHex() );
		//trace( b.toHex() );
		//trace( r.toHex() );
		return r;
	}
	
}