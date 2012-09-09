package jonas.format.csv;

import haxe.io.Output;

/* RFC 4180 compliant writer for Comma-Separated Values (CSV) streams
   Copyright 2012 Jonas Malaco Filho
   Licensed under the MIT license. Check LICENSE.txt for more information. */
class Writer {

	var o : Output;
	var sep : String;
	var qte : String;
	var nl : String;

	public function new( o : Output, ?sep=',', ?qte='"', ?nl='\r\n' ) {
		this.o = o;
		this.sep = sep;
		this.qte = qte;
		this.nl = nl;
	}

	public function writeRecord( data : Array<String> ) {
		for ( i in 0...data.length )
			if ( i != data.length-1 )
				o.writeString( qte + data[i].split( qte ).join( qte+qte ) + qte + sep );
			else
				o.writeString( qte + data[i].split( qte ).join( qte+qte ) + qte + nl );
	}

}