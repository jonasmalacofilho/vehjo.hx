package jonas.net;

import jonas.net.Proxy;
import haxe.xml.Fast;
import neko.io.File;

/**
 * Get proxy servers
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */
class ProxyServers {

	public static function fromText( data : String ) {
		var proxies = [];
		for ( line in data.split( '\n' ) )
			if ( line.length > 0 ) {
				var x = line.split( ':' );
				proxies.push( { host : x[0], port : Std.parseInt( x[1] ), auth : null } );
			}
		return proxies;
	}
	
	static function main() {
		var f = File.read( 'spys.ru.anonymous.txt' );
		var ps = fromText( f.readAll().toString() );
		trace( ps );
		f.close();
		var cnx = new Http( 'http://automation.whatismyip.com/n09230945.asp' );
		cnx.onData = function( data ) { trace( data ); };
		cnx.cnxTimeout = 10.;
		cnx.onError = function( msg ) { trace( msg ); };
		//cnx.onStatus = function( sta ) { trace( sta ); };
		for ( i in 0...100 ) {
			cnx.proxy = ps[i];
			for ( j in 0...10 )
				cnx.request( false );
		}
	}
	
}