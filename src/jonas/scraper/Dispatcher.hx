package jonas.scraper;

import haxe.PosInfos;
import neko.Sys;
import neko.vm.Deque;
import neko.vm.Mutex;
import neko.vm.Thread;
import haxe.Timer;
import neko.Lib;

/**
 * Scraper NEW dispatcher
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */
class Dispatcher {
	
	var mutex : Mutex;
	var jobs : Deque<Msg>;
	var nJobs : Int;
	var jobsReceived : Deque<Msg>;
	var nJobsReceived : Int;
	public var completed( default, null ) : Hash<Scraper>;
	
	public function new() {
		mutex = new Mutex();
		jobs = new Deque();
		nJobs = 0;
		jobsReceived = new Deque();
		nJobsReceived = 0;
		completed = new Hash();
	}
	
	public function addScraper( s : Scraper ) : Scraper {
		mutex.acquire();
		if ( 0 == Std.random( 2 ) )
			jobs.add( NewJob( s ) );
		else
			jobs.push( NewJob( s ) );
		nJobs++;
		mutex.release();
		return s;
	}
	
	public function run( nThreads : Int ) : Float {
		var started = Timer.stamp();
		var tracer = haxe.Log.trace;
		haxe.Log.trace = callback( customTrace, started );
		
		// creating threads
		var threads = new IntHash();
		for ( i in 0...nThreads ) {
			var t = Thread.create( threadMain );
			t.sendMessage( Thread.current() );
			t.sendMessage( i );
			t.sendMessage( this );
			t.sendMessage( jobs );
			t.sendMessage( jobsReceived );
			threads.set( i, t );
		}
		
		while ( nJobsReceived < nJobs ) {
			var msg = jobsReceived.pop( true );
			switch ( msg ) {
				case ReturnJob( threadId, job ) :
					nJobsReceived++;
					if ( job.succeeded ) {
						job.finished = Timer.stamp();
						completed.set( job.name, job );
					}
					else {
						addScraper( job );
					}
				default : trace( 'Unexpected ' + msg );
			}
		}
		
		for ( t in threads )
			jobs.add( Exit );
		
		while ( threads.iterator().hasNext() ) {
			//trace( 'open threads: ' + Lambda.list( { iterator : threads.keys } ) );
			var msg = jobsReceived.pop( true );
			switch ( msg ) {
				case Exited( id ) : threads.remove( id );
				default : trace( 'Unexpected ' + msg );
			}
		}
		
		haxe.Log.trace = tracer;
		return Timer.stamp() - started;
	}
	
	public dynamic function customTrace( begin : Float, v, ?p : PosInfos ) {
		Lib.println( NumberPrinter.printDecimal( Timer.stamp() - begin, 5, 3 ) + 's: ' + v + ' (' + p.fileName + ':' + p.lineNumber + ')' );
	}
	
	static function threadMain() : Void {
		var main : Thread = Thread.readMessage( true );
		var id : Int = Thread.readMessage( true );
		var dispatcher : Dispatcher = Thread.readMessage( true );
		var get : Deque<Msg> = Thread.readMessage( true );
		var send : Deque<Msg> = Thread.readMessage( true );
		while ( true ) {
			var msg = get.pop( true );
			switch ( msg ) {
				case NewJob( job ) :
					trace( 'got job "' + job.name + '" (thread' + id + ')' );
					var raised = null;
					try {
						job.run( dispatcher );
					}
					catch ( e : Dynamic ) {
						job.succeeded = false;
						raised = e;
					}
					send.add( ReturnJob( id, job ) );
					if ( null != raised )
						try { trace( 'EXCEPTION: thread ' + id + ' raised ' + raised + haxe.Stack.toString( haxe.Stack.exceptionStack() ) ); } catch ( e : Dynamic ) { }
					trace( 'finished job "' + job.name + '" (thread' + id + ')' );
				case Exit() : send.add( Exited( id ) ); break;
				default : trace( 'Unexpected ' + msg );
			}
		}
	}
	
}

private enum Msg {
	NewJob( job : Scraper );
	ReturnJob( threadId : Int, job : Scraper );
	Exit();
	Exited( id : Int );
}