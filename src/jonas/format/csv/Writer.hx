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

	public function new( o : Output, ?sep=',', ?qte='"', ?nl='\n' ) {
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

	public function dump( it: Iterable<Dynamic>, ?headers=true ) {
		var fields: Array<String> = null;
		for ( x in it ) {
			if ( headers ) {
				writeRecord( fields = Reflect.fields( x ) );
				headers = false;
			}
			writeRecord( Lam.map( ( fields!=null ? fields : Reflect.fields( x ) ), function ( f ) return Std.string( Reflect.field( x, f ) ) ) );
		}
	}

	public static function stringDump<A>( it: Iterable<A>, ?headers=true, ?sep=',', ?qte='"', ?nl='\n' ): String {
		var out = new haxe.io.BytesOutput();
		var writer = new Writer( out, sep, qte, nl );
		writer.dump( it, headers );
		return out.getBytes().toString();
	}

	public function close(): Void {
		o.close();
	}

}