package jonas.db;

import sys.db.Connection;

#if neko
import neko.vm.Mutex;

/**
 * Shared connection
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */
class SharedConnection implements Connection {

	var cnx : Connection;
	var mutex : Mutex;
	
	public function new( cnx : Connection ) {
		this.cnx = cnx;
		mutex = new Mutex();
	}
	
	public inline function request( s ) { mutex.acquire(); var res = cnx.request( s ); mutex.release(); return res; }
	public function close() { throw 'Forbiden'; }
	public inline function escape( s ) { return cnx.escape( s ); }
	public inline function quote( s ) { return cnx.quote( s ); } 
	public inline function addValue( s, v : Dynamic ) { cnx.addValue( s, v ); }
	public function lastInsertId() { throw 'Forbiden'; return -1; }
	public inline function dbName() { return cnx.dbName(); }
	public function startTransaction() { throw 'Forbiden'; }
	public function commit() { throw 'Forbiden'; }
	public function rollback() { throw 'Forbiden'; }
	
}
#end