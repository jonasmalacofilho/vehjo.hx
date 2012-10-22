package jonas;

/*
 * Bidimensional vectors
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

/**
 * Vector (2D)
 */
class Vector {
	
	public var x( default, null ) : Float;
	public var y( default, null ) : Float;
	
	public inline function new( x, y ) {
		this.x = x;
		this.y = y;
	}
	
	public inline function sum( v : Vector ) : Vector {
		return new Vector( x + v.x, y + v.y );
	}
	
	public inline function sub( v : Vector ) : Vector {
		return new Vector( x - v.x, y - v.y );
	}
	
	public inline function dotProduct( v : Vector ) : Float {
		return x * v.x + y * v.y;
	}
	
	public inline function rev() : Vector {
		return new Vector( -x, -y );
	}
	
	public inline function ort() : Vector {
		return new Vector( - y, x );
	}
	
	public inline function mod() : Float {
		return Math.sqrt( x * x + y * y );
	}
	
	public inline function theta() : Float {
		return Math.atan2( y, x );
	}
	
	public inline function rotate( radians : Float ) : Vector {
		var mod = mod();
		var theta = theta() + radians;
		return new Vector( mod * Math.cos( theta ), mod * Math.sin( theta ) );
	}
	
	public inline function scale( f : Float ) : Vector {
		return new Vector( x * f , y * f );
	}

	public inline function proj( x: Vector ): Vector {
		return x.scale( dotProduct( x )/x.mod() );
	}
	
	public function toString() : String {
		return '(' + x + ', ' + y + ')';
	}
	
}