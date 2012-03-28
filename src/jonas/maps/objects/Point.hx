package jonas.maps.objects;

import jonas.Vector;

/*
 * Basic point object
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */
class Point<T> extends Vector {
	
	public var data( default, null ) : T;
	
	public function new( x : Float, y : Float, data : T ) {
		super( x, y );
		this.data = data;
	}
	
	override public function toString() : String {
		return Std.string( data );
	}
	
}