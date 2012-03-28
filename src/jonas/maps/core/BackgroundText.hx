package jonas.maps.core;

import haxe.PosInfos;
import nme.display.Sprite;
import nme.text.TextField;
import nme.text.TextFormat;

/*
 * Background text field, used for log/trace
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */
class BackgroundText {
	
	public var textField( default, null ) : TextField;
	
	var buffer : List<String>;
	var maxBufferSize : Int;
	
	public function new( width : Float, height : Float, parent : Sprite ) {
		
		parent.addChild( textField = new TextField() );
		textField.defaultTextFormat = new TextFormat( '_typewriter', 12, 0x707070 );
		textField.multiline = true;
		textField.wordWrap = true;
		textField.selectable = false;
		textField.mouseEnabled = false;
		
		textField.width = width;
		textField.height = height;
		
		buffer = new List();
		maxBufferSize = 300;
	}

	public function println( s : String ) : Void {
		buffer.add( s );
		while ( buffer.length > maxBufferSize )
			buffer.pop();
		textField.text = buffer.join( '\n' );
		textField.scrollV = textField.numLines;
	}
	
	public function customTrace( v, ?p : PosInfos ) {
		println( p.fileName + ':' + p.lineNumber + ': ' + v );
		#if debug
		#if neko
		neko.Lib.println( p.fileName + ':' + p.lineNumber + ': ' + v );
		#else
		cpp.Lib.println( p.fileName + ':' + p.lineNumber + ': ' + v );
		#end
		#end
	}
	
}