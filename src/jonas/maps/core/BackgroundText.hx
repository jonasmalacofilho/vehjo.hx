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
		
		maxBufferSize = 10000;
	}

	public function println( s : String ) : Void {
		s += '\n';
		if ( s.length > maxBufferSize )
			s = s.substr( s.length - maxBufferSize - 1 );
		if ( textField.text.length + s.length > maxBufferSize )
			textField.text = textField.text.substr( textField.text.length + s.length - maxBufferSize - 1 );
		textField.text += s;
		textField.scrollV = textField.numLines - Std.int( textField.height / textField.textHeight * textField.numLines ) + 1;
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