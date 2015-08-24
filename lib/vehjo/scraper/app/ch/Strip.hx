package vehjo.scraper.app.ch;

import haxe.Timer;
import vehjo.db.SharedConnection;
import vehjo.net.Http;
import vehjo.NumberPrinter;
import vehjo.scraper.Dispatcher;
import vehjo.scraper.Scraper;
import neko.io.File;

/**
 * Calvin and Hobbes comic strips scraping
 * Strip: get and save the strip
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */
class Strip extends Scraper {
	
	var year : Int;
	var month : Int;
	var day : Int;
	var db : SharedConnection;
	var png : String;
	var url : String;

	public function new( db : SharedConnection, year : Int, month : Int, day : Int, url : String ) {
		this.db = db;
		this.year = year;
		this.month = month;
		this.day = day;
		this.url = url;
		super( 'CalvinAndHobbesStrip-' + date() );
	}
	
	function date() : String {
		return NumberPrinter.printInteger( year, 4, 4 ) + '/' + NumberPrinter.printInteger( month, 2, 2 ) + '/' + NumberPrinter.printInteger( day, 2, 2 );
	}
	
	function createTable() : Void {
		db.request(
'CREATE TABLE IF NOT EXISTS calvinAndHobbes (
-- Calvin and Hobbes comic strips
	year INTEGER NOT NULL,
	month INTEGER NOT NULL,
	day INTEGER NOT NULL,
	png BLOB,
	scrapped REAL,
	PRIMARY KEY ( year, month, day )
)' );
	}
	
	function addToDb() : Void {
		createTable();
		var b = new StringBuf();
		b.add( 'INSERT OR REPLACE INTO calvinAndHobbes VALUES (' );
		db.addValue( b, year );
		b.add( ',' );
		db.addValue( b, month );
		b.add( ',' );
		db.addValue( b, day );
		b.add( ',' );
		db.addValue( b, png );
		b.add( ',' );
		db.addValue( b, Timer.stamp() );
		b.add( ')' );
		//trace( b.toString() );
		db.request( b.toString() );
	}
	
	function saveToFile() : Void {
		var f = File.write( 'CalvinAndHobbes-' + date().split( '/' ).join( '-' ) + '.png', true );
		f.writeString( png );
		f.close();
	}
	
	function get() : Void {
		//trace( url );
		var cnx = new Http( url );
		cnx.onData = function( png : String ) : Void {
			if ( png.length > 0 ) {
				this.png = png;
				succeeded = true;
			}
		};
		cnx.onError = function( msg ) { trace( name + ' FAILED with ' + msg ) ; };
		//cnx.onStatus = function( status ) { trace( status ); };
		cnx.cnxTimeout = 10.;
		cnx.request( false );
	}
	
	override public function run( dispatcher : Dispatcher ) : Void {
		get();
		if ( succeeded ) {
			addToDb();
			saveToFile();
		}
	}
	
}