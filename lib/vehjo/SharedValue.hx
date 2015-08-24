package vehjo;

#if neko
import neko.vm.Mutex;

/**
 * Shared value over multiple threads
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */
class SharedValue<T> {
	
	var mutex : Mutex;
	public var v( getValue, setValue ) : T;

	public function new( v ) {
		this.v = v;
	}

	function getValue() : T {
		mutex.acquire();
		var v = this.v;
		mutex.release();
		return v;
	}
	
	function setValue( v : T ) : T {
		mutex.acquire();
		this.v = v;
		mutex.release();
		return v;
	}
	
}
#end