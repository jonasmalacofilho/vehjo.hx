package jonas.maps.layers;

import jonas.ds.RjTree;
import jonas.maps.core.Encoder;
import jonas.maps.core.Layer;
import jonas.maps.objects.Point;
import jonas.maps.styles.PointStyle;
import jonas.Vector;
using jonas.sort.Heapsort;

/*
 * Basic layer of bidimensional points
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */
class PointLayer extends Layer {

	var objs : RjTree<Point<T>>;
	
	public dynamic function visible( obj : T, boundingBoxDimensions : Vector ) : Bool { return true; }
	public dynamic function fillColor( obj : T ) : Int { return 0; }
	public dynamic function fillAlpha( obj : T ) : Float { return 1.; }
	public dynamic function lineThickness( obj : T ) : Float { return 1.; }
	public dynamic function lineColor( obj : T ) : Int { return 0; }
	public dynamic function lineAlpha( obj : T ) : Float { return 1.; }
	public dynamic function style( obj : T ) : PointStyle { return Circle( 1. ); }
	
	public function new( encoder : Encoder ) {
		super( encoder );
		objs = new RjTree();
	}
	
	override public function draw( ?refreshBinds = false ) : Void {
		super.draw( refreshBinds );
		if ( active ) {
		// layer is active/visible
			
			#if JMAPS_TRACE_RTREE
			traceRTree();
			#end
			
			var graphics = sprite.graphics;
			var boundingBoxDimensions = encoder.max.sub( encoder.min );
			
			// TODO fix bug that all objects are being drawn to the Sprite (appeared when updated to the new RjTree)
			for ( o in objs.search( encoder.min.x, encoder.min.y, encoder.max.x - encoder.min.x, encoder.max.y - encoder.min.y ) )
				if ( visible( o.data, boundingBoxDimensions ) ) {
				// object is visible at this level of detail
				
					var toCanvas = encoder.encode( o );
					graphics.lineStyle( lineThickness( o.data ), lineColor( o.data ), lineAlpha( o.data ) );
					graphics.beginFill( fillColor( o.data ), fillAlpha( o.data ) );
					
					// object display style
					switch ( style( o.data ) ) {
						case Circle( radius ) : graphics.drawCircle( toCanvas.x, toCanvas.y, radius );
						case Elipse( width, height ) : graphics.drawEllipse( toCanvas.x, toCanvas.y, width, height ); 
						case Rectangle( width, height ) : graphics.drawRect( toCanvas.x - .5 * width, toCanvas.y - .5 * height, width, height );
						case InvisiblePoint : // invisible!
						default : throw 'Not implemented';
					}
					graphics.endFill();
				}
			
		}
		
	}
	
	#if JMAPS_TRACE_RTREE
	#if !RJTREE_DEBUG
	#error "JMAPS_TRACE_RTREE requires RJTREE_DEBUG"
	#end
	
	function traceRTree() : Void {
		var graphics = sprite.graphics;
		var bbBoxes = Lambda.array( { iterator : objs.boudingBoxes } );
		bbBoxes = bbBoxes.heapsort( function( a, b ) { return b.level > a.level; } );
		for ( bb in bbBoxes ) {
			var min = encoder.encode( new Vector( bb.xMin, bb.yMin ) );
			var max = encoder.encode( new Vector( bb.xMax, bb.yMax ) );
			switch ( bb.level ) {
				case 0 : graphics.lineStyle( 0., 0xffffff, 0. );
				case 1 : graphics.lineStyle( 4., 0xff0000, 1. );
				case 2 : graphics.lineStyle( 3., 0x0000ff, 1. );
				case 3 : graphics.lineStyle( 2., 0x00ff00, 1. );
				default : graphics.lineStyle( 1., 0x000000, 1. );
			};
			graphics.drawRect( min.x, min.y, max.x - min.x, max.y - min.y );
		}
	}
	
	#end
	
	public function addObject( p : Point<T> ) : Void {
		objs.insertPoint( p.x, p.y, p );
	}
	
	override public function info( p : Vector, ?d : Vector ) : Null<Dynamic> {
		var min = encoder.decode( p );
		var res;
		if ( null == d )
			res = Lambda.array( { iterator : callback( objs.search, min.x, min.y, 0., 0. ) } );
		else {
			var max = encoder.decode( p.sum( d ) );
			res = Lambda.array( { iterator : callback( objs.search, min.x, min.y, max.x - min.x, max.y - min.y ) } );
			
		}
		if ( 0 == res.length )
			return null;
		res = res.heapsort( function( a, b ) { return Reflect.compare( a, b ) > 0; } );
		return res;
	}
	
}

private typedef T = Dynamic;
