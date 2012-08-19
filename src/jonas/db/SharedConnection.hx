package jonas.db;

import sys.db.Connection;
import sys.db.ResultSet;

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
	
	// This always returns null, since the mutexes are automatically released
	public inline function request( s ) : ResultSet {
		mutex.acquire(); cnx.request( s ); mutex.release(); return null;
	}

	// This is safe, but will lock until release is called
	public inline function safeRequest( s ) : SharedResultSet {
		mutex.acquire();
		return new SharedResultSet( cnx.request( s ), mutex );
	}

	public function close() { mutex.acquire(); cnx.close(); cnx = null; mutex.release(); }

	public inline function escape( s ) { return cnx.escape( s ); }
	public inline function quote( s ) { return cnx.quote( s ); } 
	public inline function addValue( s, v : Dynamic ) { cnx.addValue( s, v ); }
	public function lastInsertId() { throw 'Forbiden'; return -1; }
	public inline function dbName() { return cnx.dbName(); }
	public function startTransaction() { throw 'Forbiden'; }
	public function commit() { throw 'Forbiden'; }
	public function rollback() { throw 'Forbiden'; }
	
}

class SharedResultSet implements ResultSet {

	var resultSet : ResultSet;
	var mutex : Mutex;

	public var length( getLength, null ) : Int;
	public var nfields( getNFields, null ) : Int;

	inline function getLength() : Int { return resultSet != null ? resultSet.length : 0; }
	inline function getNFields() : Int { return resultSet != null ? resultSet.nfields : 0; }

	public inline function new( resultSet, mutex ) {
		this.resultSet = resultSet;
	}

	public inline function release() : Void {
		resultSet = null;
		mutex.release();
	}

	public inline function getFieldsNames() : Null<Array<String>> { return resultSet != null ? resultSet.getFieldsNames() : null; }
	public inline function getFloatResult( n : Int ) : Float { return resultSet != null ? resultSet.getFloatResult( n ) : Math.NaN; }
	public inline function getIntResult( n : Int ) : Int { return resultSet != null ? resultSet.getIntResult( n ) : 0; }
	public inline function getResult( n : Int ) : String { return resultSet != null ? resultSet.getResult( n ) : ''; }
	public inline function hasNext() : Bool { return resultSet != null ? resultSet.hasNext() : false; }
	public inline function next() : Dynamic { return resultSet != null ? resultSet.results() : null; }
	public inline function results() : List<Dynamic> { return resultSet != null ? resultSet.results() : new List(); }

	// Returns all results (in a List<Dynamic>) and releases the mutex
	public inline function resultsAndRelease() : List<Dynamic> { var r = results(); release(); return r; }
	
}

#end