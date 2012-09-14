package jonas.format.csv;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.io.Input;
import jonas.macro.Debug;

/* RFC 4180 quasi-compliant reader for Comma-Separated Values (CSV) streams
   The limitations are
    - all records must end in a proper newline sequence
    - fields stated by a quote will be treated as quoted
   Copyright 2012 Jonas Malaco Filho
   Licensed under the MIT license. Check LICENSE.txt for more information. */
class Reader {

	var i : Input;
	var sep : Int;
	var qte : Int;
	var nl0 : Int;
	var nl1 : Int;

	public function new( i : Input, ?sep=',', ?qte='"', ?nl='\r\n' ) {
		Debug.assertTrue( sep.length==1 );
		Debug.assertTrue( qte.length==1 || qte.length==-1 );
		Debug.assertTrue( nl.length==1 || nl.length==2 );
		this.i = i;
		this.sep = sep.charCodeAt( 0 );
		if ( qte.length > 0 )
			this.qte = qte.charCodeAt( 0 );
		else
			this.qte = -1;
		this.nl0 = nl.charCodeAt( 0 );
		if ( nl.length > 1 )
			this.nl1 = nl.charCodeAt( 1 );
		else
			this.nl1 = -1;
	}

	public function readData( ?headers=true ) : Array<Dynamic> {
		var h = headers ? readRecord() : null;
		var data = [];
		while ( true ) try {
			var r = readRecord();
			// Debug.assert( r );
			Debug.assertTrue( h==null || r.length==h.length );
			var x : Dynamic = cast {};
			for ( i in 0...r.length )
				if ( h==null )
					Reflect.setField( x, 'V'+(i+1), r[i] );
				else
					Reflect.setField( x, h[i], r[i] );
			// Debug.assert( x );
			data.push( x );
		}
		catch ( e : haxe.io.Eof ) {
			break;
		}
		return data;
	}

	public function readRecord() : Array<String> {
		// Debug.assert( this );
		var fs = [];
		var f = new BytesBuffer();
		var qtd = false; // quoted field
		var c = -1; // current byte
		var beforeLast = -1; // before last read byte
		var last = -1; // last read byte
		while ( true ) {
			c = i.readByte();
			// Debug.assert( [ qtd, last, beforeLast, c, String.fromCharCode( c ) ] );
			// Debug.assertTrue( c!=qte );
			switch ( c ) {
				case sep : // field separator
					if ( last==nl0 )
						f.addByte( last );
					if ( qtd && last!=qte )
						f.addByte( c );
					else {
						fs.push( f.getBytes().toString() );
						f = new BytesBuffer();
						c = -1;
						qtd = false;
					}
				case qte : // quote
					if ( last==nl0 )
						f.addByte( last );
					if ( qtd && last==qte ) {
						f.addByte( c );
						c = beforeLast;
					}
					else if ( !qtd && last!=-1 )
						f.addByte( c );
					else if ( last==-1 ) {
						qtd = true;
						c = sep;
					}
				case nl0 : // newline separator (first byte)
					if ( ( !qtd || last==qte ) && nl1==-1 ) {
						fs.push( f.getBytes().toString() );
						c = -1;
						qtd = false;
						break;
					}
				case nl1 : // newline separator (second byte)
					if ( ( !qtd || beforeLast==qte ) && last==nl0 ) {
						fs.push( f.getBytes().toString() );
						c = -1;
						qtd = false;
						break;
					}
					else {
						if ( last==nl0 )
							f.addByte( last );
						f.addByte( c );
					}
				default : // everything else
					if ( last==nl0 )
						f.addByte( last );
					f.addByte( c );
			}
			beforeLast = last;
			last = c;
			// Debug.assert( fs );
		}
		return fs;
	}

}
