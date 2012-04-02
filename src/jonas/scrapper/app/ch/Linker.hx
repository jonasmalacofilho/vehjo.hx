package jonas.scrapper.app.ch;

import jonas.net.Http;
import haxe.Timer;
import jonas.db.MutexConnection;
import jonas.NumberPrinter;
import jonas.scrapper.Dispatcher;
import jonas.scrapper.Scrapper;

class Linker extends Scrapper {
	
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
			children.push( dispatcher.addScrapper( new Strip( db, year, month, day, stripUrl ) ).name );
	}
	
	
}