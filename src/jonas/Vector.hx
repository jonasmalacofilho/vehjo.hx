package jonas;

/*
 * Vector in R2 - bidimensional vector
 * Copyright (c) 2012 Jonas Malaco Filho
 * 
 * Licensed under the MIT License. Check LICENSE.txt for more information.
 */
typedef Vector2 = Vector;
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

	public inline function crossProduct( b: Vector ): Float {
		return x*b.y - b.x*y;
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
		// |y| = dotProduct( x )/x.mod()
		//  y  = x.scale( |y|/|x| )
		return x.scale( dotProduct( x )/x.mod()/x.mod() );
	}
	
	public function toString() : String {
		return '(' + x + ', ' + y + ')';
	}
	
}