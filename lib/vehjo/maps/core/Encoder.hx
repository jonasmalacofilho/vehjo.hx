package vehjo.maps.core;

import vehjo.Vector;

/*
 * Encoder, responsable for encoding/decoding real data x,y to canvas (and stage) x,y
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */
class Encoder {
	
	public var min : Vector;
	public var max : Vector;
	public var canvas : Canvas;
	
	// cache
	public var cachedWidth : Float;
	public var cachedHeight : Float;
	public var cachedCanvasWidth : Float;
	public var cachedCanvasHeight : Float;
	public var cachedWidthFactor : Float; // canvas.width / width()
	public var cachedHeightFactor : Float; // canvas.height / height()

	public function new( canvas : Canvas ) {
		this.canvas = canvas;
		canvas.addEncoder( this );
		goToUniverse();
		update();
	}
	
	public function update( ?propagate = true, ?pan : Null<Vector>, ?zoom : Null<Float> ) : Void {
		if ( propagate ) {
			canvas.update( pan, zoom );
			return;
		}
		
		if ( null != pan )
			this.pan( pan );
		if ( null != zoom )
			this.zoom( zoom );
		
		cachedWidth = width();
		cachedHeight = height();
		cachedCanvasWidth = canvas.width;
		cachedCanvasHeight = canvas.height;
		cachedWidthFactor = cachedCanvasWidth / cachedWidth;
		cachedHeightFactor = cachedCanvasHeight / cachedHeight;
	}
	
	public function encode( ofData : Vector ) : Vector {
		return new Vector( ( ofData.x - min.x ) * cachedWidthFactor, ( ofData.y - min.y ) * cachedHeightFactor );
	}
	
	public function decode( ofCanvas : Vector ) : Vector {
		return new Vector( min.x + ofCanvas.x / cachedWidthFactor, min.y + ofCanvas.y / cachedHeightFactor );
	}
	
	public function width() : Float { return max.x - min.x; }
	public function height() : Float { return max.y - min.y; }
	public function center() : Vector { return new Vector( .5 * ( min.x + max.x ), .5 * ( min.y + max.y ) ); }
	
	// Bounding box manipulations
	
	function goToUniverse() : Void { min = new Vector( 0, 0 ); max = new Vector( canvas.width, canvas.height ); }
	function pan( v : Vector ) : Void {
		var offset = new Vector( v.x * width(), v.y * height() );
		min = min.sub( offset );
		max = max.sub( offset );
	}
	function zoom( f : Float ) : Void {
		var c = center();
		var d = new Vector( .5 * width() / f, .5 * height() / f );
		min = c.sub( d );
		max = c.sum( d );
	}
	
}