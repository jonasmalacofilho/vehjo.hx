package jonas.scraper.app.ch;

import jonas.db.MutexConnection;
import jonas.net.Http;
import jonas.NumberPrinter;
import jonas.scraper.Dispatcher;
import jonas.scraper.Scraper;

/**
 * Calvin and Hobbes comic strips scraping
 * Linker: visit the site and extract the strip url
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */
class Linker extends Scraper {
	
	var year : Int;
	var month : Int;
	var day : Int;
	var db : MutexConnection;
	var png : String;
	var stripUrl : String;

	public function new( db : MutexConnection, year : Int, month : Int, day : Int ) {
		this.db = db;
		this.year = year;
		this.month = month;
		this.day = day;
		super( 'CalvinAndHobbesLinker-' + date() );
	}
	
	function date() : String {
		return NumberPrinter.printInteger( year, 4, 4 ) + '/' + NumberPrinter.printInteger( month, 2, 2 ) + '/' + NumberPrinter.printInteger( day, 2, 2 );
	}
	
	function get() : Void {
		var cnx = new Http( 'www.gocomics.com/calvinandhobbes/' + date() );
		cnx.onData = function( page : String ) : Void {
			//trace( page );
			var r = ~/(cdn\.svcs\.c2\.uclick\.com\/c2\/[a-z0-9]{32})\?width/;
			if ( r.match( page ) ) {
				stripUrl = r.matched( 1 );
				//trace( 'high: ' + stripUrl );
				succeeded = true;
			}
			else {
				r = ~/(cdn\.svcs\.c2\.uclick\.com\/c2\/[a-z0-9]{32})/;
				if ( r.match( page ) ) {
					stripUrl = r.matched( 1 );
					//trace( 'low: ' + stripUrl );
					succeeded = true;
				}
			}
		};
		cnx.onError = function( msg ) { trace( name + ' FAILED with ' + msg ) ; };
		//cnx.onStatus = function( status ) { trace( status ); };
		cnx.cnxTimeout = 10.;
		cnx.request( false );
	}
	
	override function run( dispatcher : Dispatcher ) : Void {
		get();
		if ( succeeded )
			children.push( dispatcher.addScraper( new Strip( db, year, month, day, stripUrl ) ).name );
	}
	
	
}