package jonas.scraper.app.ch;

import jonas.db.MutexConnection;
import jonas.scraper.Dispatcher;
import jonas.scraper.Scraper;
import neko.db.Sqlite;

/**
 * Calvin and Hobbes comic strips scraping
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */
class CalvinAndHobbes extends Scraper {
	
	var db : MutexConnection;

	public function new( db : MutexConnection ) {
		this.db = db;
		super( 'CalvinAndHobbesMain' );
	}
	
	override public function run( dispatcher : Dispatcher ) : Void {
		var cur = new Date( 1985, 10, 18, 12, 0, 0 );
		var end = new Date( 1995, 11, 31, 12, 0, 0 );
		//var cur = new Date( 2012, 02, 01, 12, 0, 0 );
		//var end = new Date( 2012, 02, 31, 12, 0, 0 );
		while ( cur.getTime() <= end.getTime() ) {
			//trace( cur );
			children.push( dispatcher.addScraper( new Linker( db, cur.getFullYear(), cur.getMonth() + 1, cur.getDate() ) ).name );
			cur = DateTools.delta( cur, DateTools.days( 1 ) );
		}
		succeeded = true;
	}
	
	static function main() {
		var db = Sqlite.open( 'CalvinAndHobbes.db3' );
		var dis = new Dispatcher();
		dis.addScraper( new CalvinAndHobbes( new MutexConnection( db ) ) );
		trace( dis.run( 32 ) );
		//trace( dis.run( 1 ) );
		trace( dis.completed.get( 'CalvinAndHobbes-1995-12-31' ) );
		db.close();
	}
	
}