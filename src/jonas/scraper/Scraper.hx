package jonas.scraper;

import neko.vm.Mutex;

/**
 * Base scraper
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */
class Scraper {
	
	public var name : String;
	public var timeout : Float;
	public var started : Float;
	public var finished : Float;
	public var succeeded : Bool;
	public var children : Array<String>;
	
	static var uniqueName = {
		var mutex = new Mutex();
		var hash = new Hash();
		function( name : String ) : String {
			mutex.acquire();
			while ( hash.exists( name ) )
				name += '(1)';
			hash.set( name, name );
			mutex.release();
			return name;
		};
	};

	public function new( name ) {
		timeout = 60.;
		started = -1.;
		finished = -1.;
		succeeded = false;
		children = [];
		
		this.name = uniqueName( name );
	}
	
	public function run( dispatcher : Dispatcher ) : Void {
		
	}
	
}