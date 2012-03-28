package jonas.maps.core;

import jonas.Vector;
import nme.display.Sprite;

/*
 * Base class for layers
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */
class Layer {
	
	public var canvas : Canvas;
	public var sprite : Sprite;
	public var encoder : Encoder;
	
	public var active : Bool;

	public function new( encoder : Encoder ) {
		this.encoder = encoder;
		canvas = encoder.canvas;
		sprite = new Sprite();
		#if !debug
		sprite.cacheAsBitmap = true;
		#end
		canvas.addLayer( this );
		
		active = true;
	}
	
	public function draw( ?refreshBinds = false ) : Void {
		sprite.graphics.clear();
		
		#if false
		sprite.graphics.lineStyle( 3., 0xff0000, .3 );
		var inXY = encoder.encode( encoder.min );
		var inSIZE = encoder.encode( encoder.max );
		sprite.graphics.drawRect( inXY.x, inXY.y, inSIZE.x, inSIZE.y );
		#end
	}
	
	public function info( p : Vector, ?d : Vector ) : Null<Dynamic> {
		return null;
	}
	
}