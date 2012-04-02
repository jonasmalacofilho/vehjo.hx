package jonas.scraper;

import haxe.PosInfos;
import haxe.Timer;
import jonas.NumberPrinter;
import neko.Sys;
import neko.vm.Mutex;
import neko.vm.Thread;
import neko.vm.Ui;
import neko.Lib;

/**
 * Scraper dispatcher
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */
class Dispatcher {
	
	var jobs : Hash<Scraper>;
	var working : Hash<Scraper>;
	public var completed : Hash<Scraper>;
	
	var mutex : Mutex;

	public function new() {
		jobs = new Hash();
		working = new Hash();
		completed = new Hash();
		mutex = new Mutex();
	}
	
	public function addScraper( s : Scraper ) : Scraper {
		mutex.acquire();
		jobs.set( s.name, s );
		mutex.release();
		return s;
	}
	
	public function run( nThreads : Int ) : Float {
		var started = Timer.stamp();
		var tracer = haxe.Log.trace;
		haxe.Log.trace = callback( customTrace, started );
		var sleep = .1 / nThreads;
		//var sleep = 1.;
		while ( true ) {
			var now = Timer.stamp();
			mutex.acquire();
			if ( Lambda.empty( jobs ) && Lambda.empty( working ) )
				break;
			var workingThreads = Lambda.count( working );
			var availableThreads = nThreads - workingThreads;
			mutex.release();
			for ( i in 0...availableThreads ) {
				var thread = Thread.create( threadMain );
				thread.sendMessage( this );
			}
			Sys.sleep( sleep );
		}
		haxe.Log.trace = tracer;
		return Timer.stamp() - started;
	}
	
	function getNewJob() : Null<Scraper> {
		mutex.acquire();
		var it = jobs.keys();
		var job = it.hasNext() ? jobs.get( it.next() ) : null;
		if ( null != job ) {
			jobs.remove( job.name );
			job.started = Timer.stamp();
			job.finished = -1;
			job.succeeded = false;
			working.set( job.name, job );
		}
		mutex.release();
		return job;
	}
	
	function returnJob( job : Scraper ) : Void {
		if ( job.succeeded ) {
			job.finished = Timer.stamp();
			mutex.acquire();
			working.remove( job.name );
			completed.set( job.name, job );
			mutex.release();
		}
		else {
			mutex.acquire();
			working.remove( job.name );
			jobs.set( job.name, job );
			mutex.release();
		}
	}
	
	public dynamic function customTrace( begin : Float, v, ?p : PosInfos ) {
		Lib.println( NumberPrinter.printDecimal( Timer.stamp() - begin, 5, 3 ) + 's: ' + v + ' (' + p.fileName + ':' + p.lineNumber + ')' );
	}
	
	static function threadMain() : Void {
		var raised : Dynamic = null;
		try {
			var dispatcher : Dispatcher = Thread.readMessage( true );
			var job;
			if ( null != ( job = dispatcher.getNewJob() ) ) {
				trace( 'got job "' + job.name + '"' );
				try { job.run( dispatcher ); } catch ( e : Dynamic ) { raised = e; job.succeeded = false; };
				dispatcher.returnJob( job );
				trace( 'finished job "' + job.name + '"' );
			}
		}
		catch ( e : Dynamic ) { raised = e; }
		if ( null != raised )
			trace( 'EXCEPTION ' + raised + haxe.Stack.toString( haxe.Stack.exceptionStack() ) );
	}
	
}