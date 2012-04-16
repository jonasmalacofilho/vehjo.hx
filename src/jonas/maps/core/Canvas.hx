package jonas.maps.core;

import haxe.Timer;
import jonas.Vector;
import nme.display.MovieClip;
import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.Lib;

/*
 * Canvas object, container of layers and event/input handler
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */
class Canvas {

	var movieClip : MovieClip;
	var isPlaying : Bool;
	var sprite : Sprite;
	
	public var width : Float;
	public var height : Float;
	
	var defaultZoomFactor : Float;
	var defaultPointerDeviation : Float;
	
	var encoders : List<Encoder>;
	var layers : List<Layer>;

	public function new( width : Float, height : Float, ?parent : Sprite, ?pos : Null<Int> ) {
		
		if ( null == parent )
			parent = Lib.current;
		parent.addChildAt( movieClip = new MovieClip(), ( null != pos ? pos : parent.numChildren ) );
		movieClip.addChild( sprite = new Sprite() );
		
		// TODO suport resize
		this.width = width;
		this.height = height;
		backgroundRectangle();
		
		defaultZoomFactor = 1.4; // x1.4
		defaultPointerDeviation = 3.; // 3 px
		
		encoders = new List();
		layers = new List();
		
		addEvents();
	}
	
	public function stop() : Void {
		movieClip.stop();
		isPlaying = false;
	}
	
	public function play() : Void {
		isPlaying = true;
		movieClip.play();
	}
	
	public function backgroundRectangle() : Void {
		sprite.graphics.clear();
		sprite.graphics.beginFill( 0xffffff, 1. );
		#if debug
		sprite.graphics.lineStyle( 3., 0xff0000, .3 );
		#end
		sprite.graphics.drawRect( 0, 0, width - 100, height );
		sprite.graphics.endFill();
	}
	
	public function update( ?pan : Null<Vector>, ?zoom : Null<Float>, ?binds = false ) : Void {
		var wasPlaying = isPlaying;
		stop();
		
		backgroundRectangle();
		
		for ( e in encoders )
			e.update( false, pan, zoom );
		for ( lr in layers )
			lr.draw( binds );
		
		if ( wasPlaying )
			play();
	}
	
	public function addLayer( layer : Layer ) : Void {
		layers.remove( layer );
		try { sprite.removeChild( layer.sprite ); } catch ( e : Dynamic ) { }
		layers.add( layer );
		sprite.addChild( layer.sprite );
	}
	
	public function addEncoder( encoder : Encoder ) : Void {
		encoders.remove( encoder );
		encoders.add( encoder );
	}
	
	public dynamic function showInfo( info : Null<Dynamic> ) : Void {
		if ( info != null )
			trace( info );
	}
	
	public function showInfos( p : Vector, ?d : Vector ) : Void {
		if ( d.mod() < .1 ) {
			d = new Vector( defaultPointerDeviation, defaultPointerDeviation );
			p = p.sub( d );
			d = d.scale( 2. );
		}
		for ( lr in layers )
			showInfo( lr.info( p, d ) );
	}
	
	function addEvents() : Void {
		stop();
		
		// Events: zoom
		zoomPrepare();
		
		// Events: select
		selectPrepare();
		
		// Events: pan
		panPrepare();
		
		play();
	}
	
	
	// ---- Events: zoom
	
	function zoomPrepare() : Void {
		// gesture: zoom on mouse wheel (or scroll?)
		sprite.addEventListener( MouseEvent.MOUSE_WHEEL, function( e : MouseEvent ) {
			//trace( e );
			var f = Math.pow( defaultZoomFactor, Math.abs( e.delta ) );
			if ( e.delta < 0 )
				f = 1 / f;
			var pan = new Vector( width, height ).scale( .5 ).sub( new Vector( e.localX, e.localY ) ).scale( 1. - 1. / f );
			update( new Vector( pan.x / width, pan.y / height ), f );
		} );
		
		// gesture: zoom on double click
		// TODO make it work
		sprite.doubleClickEnabled = true;
		sprite.addEventListener( MouseEvent.DOUBLE_CLICK, function( e : MouseEvent ) {
			trace( e );
		} );
	}
	
	
	// ---- Events: pan
	
	var dragOn : Bool;
	
	function panPrepare() : Void {
		dragOn = false;
		sprite.addEventListener( MouseEvent.MIDDLE_MOUSE_DOWN, panBegin );
		sprite.addEventListener( MouseEvent.MIDDLE_MOUSE_UP, panFinish );
		sprite.addEventListener( MouseEvent.ROLL_OUT, panFinish );
	}
	
	function panBegin( e : MouseEvent ) : Void {
		if ( dragOn || e.ctrlKey || e.shiftKey || e.altKey )
			return;
		sprite.startDrag();
		dragOn = true;
	}
	
	function panFinish( e : MouseEvent ) : Void {
		if ( dragOn ) {
			sprite.stopDrag();
			dragOn = false;
			var pan = new Vector( sprite.x, sprite.y );
			stop();
			sprite.x = sprite.y = 0;
			if ( 0 < pan.mod() )
				update( new Vector( pan.x / width, pan.y / height ), null, false );
			play();
		}
	}
	
	
	// ---- Events: select
	
	var selectionBegin : Vector;
	var selectionCtrlKey : Bool;
	var selectionAltKey : Bool;
	var selectionShiftKey : Bool;
	var selectionSprite : Sprite;
	
	function selectPrepare() : Void {
		selectionBegin = null;
		sprite.addChild( selectionSprite = new Sprite() );
		
		sprite.addEventListener( MouseEvent.MOUSE_DOWN, selectBegin );
		sprite.addEventListener( MouseEvent.MOUSE_UP, selectFinish );
		sprite.addEventListener( MouseEvent.MOUSE_MOVE, selectUpdateBox );
		sprite.addEventListener( MouseEvent.ROLL_OUT, selectClear );
	}
	
	public dynamic function selectAction( ctrlKey : Bool, altKey : Bool, shiftKey : Bool, xy : Vector, wh : Vector ) : Void {
		showInfos( xy, wh );
	}
	
	function selectBegin( e : MouseEvent ) : Void {
		if ( null == selectionBegin ) {
			
			selectionBegin = new Vector( e.localX, e.localY );
			
			selectionCtrlKey = e.ctrlKey;
			selectionAltKey = e.altKey;
			selectionShiftKey = e.shiftKey;
		}
	}
	
	function selectFinish( e : MouseEvent ) : Void {
		if ( null != selectionBegin	) {
			
			var dx = e.localX - selectionBegin.x;
			var dy = e.localY - selectionBegin.y;
			var p = new Vector( ( dx >= 0 ? selectionBegin.x : selectionBegin.x + dx ), ( dy >= 0 ? selectionBegin.y : selectionBegin.y + dy ) );
			var d = new Vector( Math.abs( dx ), Math.abs( dy ) );
			selectAction( selectionCtrlKey, selectionAltKey, selectionShiftKey, p, d );
			
			selectClear( e );
		}
	}
	
	function selectClear( e : MouseEvent ) : Void {
		if ( null != selectionBegin ) {
			selectionSprite.graphics.clear();
			selectionBegin = null;
		}
	}
	
	function selectUpdateBox( e : MouseEvent ) : Void {
		if ( null != selectionBegin ) {
			selectionSprite.graphics.clear();
			selectionSprite.graphics.lineStyle( 1., 0, .5 );
			selectionSprite.graphics.drawRect( selectionBegin.x, selectionBegin.y, e.localX - selectionBegin.x, e.localY - selectionBegin.y );
		}
	}
	
}