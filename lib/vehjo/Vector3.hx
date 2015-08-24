package vehjo;

/*
 * Vector in R3
 * Copyright (c) 2012 Jonas Malaco Filho
 * 
 * Licensed under the MIT License. Check LICENSE.txt for more information.
 */
class Vector3 {
	
	public var x( default, null ): Float;
	public var y( default, null ): Float;
	public var z( default, null ): Float;
	
	public inline function new( x, y ) {
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	public inline function sum( v: Vector3 ): Vector3 {
		return new Vector3( x + v.x, y + v.y, z + v.z );
	}
	
	public inline function sub( v: Vector3 ): Vector3 {
		return new Vector3( x - v.x, y - v.y, z - v.z );
	}
	
	public inline function dotProduct( v: Vector3 ): Float {
		return x*v.x + y*v.y + z*v.z;
	}

	public inline function crossProduct( v: Vector3 ): Vector3 {
		return new Vector3( y*v.z - z*v.y, z*v.x - x*v.z, x*v.y - y*v.x );
	}
	
	public inline function rev(): Vector3 {
		return new Vector3( -x, -y, -z );
	}
	
	public inline function mod(): Float {
		return Math.sqrt( x*x + y*y + z*z );
	}
	
	public inline function scale( f: Float ): Vector3 {
		return new Vector3( x*f , y*f, z*f );
	}

	public inline function proj( x: Vector3 ): Vector3 {
		return x.scale( dotProduct( x )/x.mod()/x.mod() );
	}
	
	public function toString(): String {
		return '(' + x + ', ' + y + ')';
	}
	
}