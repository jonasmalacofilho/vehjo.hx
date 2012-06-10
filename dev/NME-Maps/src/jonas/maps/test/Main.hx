package jonas.maps.test;

import haxe.Log;
import haxei.NmeConsole;
import jonas.maps.core.BackgroundText;
import jonas.maps.core.Canvas;
import jonas.maps.core.Encoder;
import jonas.maps.core.Layer;
import jonas.maps.layers.PointLayer;
import jonas.maps.objects.Point;
import jonas.maps.styles.PointStyle;
import jonas.Vector;
import nme.display.FPS;
import nme.display.Sprite;
import nme.events.KeyboardEvent;
import nme.events.MouseEvent;
import nme.Lib;
import nme.system.System;
import nme.text.TextField;
import nme.text.TextFieldType;
import nme.text.TextFormat;

/*
 * jonas.maps (NmeMaps) test
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */
class Main {
// TODO LineLayer
// TODO PolygonLayer
// TODO projections
// TODO Polyconic

	public static function main() : Void {
		
		// ---- init
		
		// Fps
		Lib.current.addChild( new FPS( Lib.current.stage.stageWidth - 100, 20, 0 ) );
		
		// Keyboard shortcut: quit on Alt+F4
		Lib.current.stage.addEventListener( KeyboardEvent.KEY_DOWN, function( e : KeyboardEvent ) {
			//trace( e );
			if ( !e.ctrlKey && !e.shiftKey && e.altKey && 0 == e.charCode && 115 == e.keyCode )
				System.exit( 0 );
		} );
		
		
		// ---- dimensions
		
		var topMargin = 15;
		var leftMargin = 15;
		var bottomMargin = 15;
		var rightMargin = 15;
		var separator = 10;
		var consoleHeight = 200;
		var canvasWidth = Lib.current.stage.stageWidth - leftMargin - rightMargin;
		var canvasHeight = Lib.current.stage.stageHeight - topMargin - bottomMargin - separator - consoleHeight;
		
		
		// ---- canvas
		
		var canvasSprite = new Sprite();
		Lib.current.addChild( canvasSprite );
		canvasSprite.x = leftMargin;
		canvasSprite.y = topMargin;
		
		var bgText = new BackgroundText( canvasWidth, canvasHeight, canvasSprite );
		Log.trace = bgText.customTrace;
		
		var canvas1 = new Canvas( canvasWidth, canvasHeight, canvasSprite, 0 );
		
		
		// ---- console
		
		var consoleTextFormat = new TextFormat( '_typewriter', 12, 0 );
		
		var consoleInp = new TextField();
		Lib.current.addChild( consoleInp );
		consoleInp.type = TextFieldType.INPUT;
		consoleInp.defaultTextFormat = consoleTextFormat;
		consoleInp.text = '';
		consoleInp.width = canvasWidth;
		consoleInp.height = Math.round( consoleHeight * .3 / consoleInp.textHeight ) * consoleInp.textHeight;
		consoleInp.x = leftMargin;
		consoleInp.y = topMargin + canvasHeight + separator + consoleHeight - consoleInp.height;
		consoleInp.multiline = true;
		consoleInp.wordWrap = true;
		consoleInp.border = true;
		consoleInp.background = true;
		consoleInp.stage.focus = consoleInp;
		
		var consoleOut = new TextField();
		Lib.current.addChild( consoleOut );
		consoleOut.defaultTextFormat = consoleTextFormat;
		consoleOut.text = '';
		consoleOut.width = consoleInp.width;
		consoleOut.height = consoleHeight - consoleInp.height;
		consoleOut.x = leftMargin;
		consoleOut.y = topMargin + canvasHeight + separator;
		consoleOut.multiline = true;
		consoleOut.wordWrap = true;
		consoleOut.border = true;
		consoleOut.background = true;
		
		var shell = new NmeConsole( consoleInp, consoleOut, [ '"Hello World!"' ] );
		
		
		// ---- frame
		
		var frame = new Sprite();
		Lib.current.addChild( frame );
		frame.graphics.beginFill( 0x303030, 1. );
		frame.graphics.drawRect( 0, 0, leftMargin, Lib.current.stage.stageHeight ); // left margin
		frame.graphics.drawRect( leftMargin, 0, Lib.current.stage.stageWidth - rightMargin, topMargin ); // top margin
		frame.graphics.drawRect( Lib.current.stage.stageWidth - rightMargin, 0, rightMargin, Lib.current.stage.stageHeight ); // right margin
		frame.graphics.drawRect( leftMargin, Lib.current.stage.stageHeight - bottomMargin, Lib.current.stage.stageWidth - rightMargin, bottomMargin ); // bottom margin
		frame.graphics.drawRect( leftMargin, Lib.current.stage.stageHeight - bottomMargin - consoleHeight - separator, Lib.current.stage.stageWidth - rightMargin, separator ); // separator
		frame.graphics.endFill();
		
		
		// ---- hash color
		
		var w = #if neko 31 #else 32 #end;
		var A = {
			var A = 1;
			for ( i in 0...( w - 1 ) )
				A = ( A << 1 ) | Std.random( 2 );
			A |= 1;
		};
		var shift = w - 24;
		var color = function( k : Int ) : Int { return ( A * k ) >> shift; };
		
		
		// ---- test layers
		
		var encoder1 = new Encoder( canvas1 );
		
		var layer1 = new PointLayer( encoder1 );
		var shapes = new IntHash();
		//layer1.fillColor = function( o ) { return 0; };
		layer1.fillColor = color;
		layer1.lineColor = layer1.fillColor;
		layer1.style = function( o ) { return shapes.get( o ); };
		for ( i in 0...1000 )
			for ( j in 0...450 )
				if ( i % 10 == 0 && j % 10 == 0 ) {
					var key = i * 1000 + j;
					//shapes.set( key, Elipse( 1. + Math.random() * 10, 1. + Math.random() * 10 ) );
					shapes.set( key, Circle( 1. ) );
					//layer1.addObject( new Point( i + 20, j + 20, key ) );
					layer1.addObject( new Point( Std.random( 1001 ) + 20, Std.random( 451 ) + 20, key ) );
				}
		
		canvas1.update();
		
	}
	
}