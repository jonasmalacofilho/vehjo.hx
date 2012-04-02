package jonas.db;
import neko.vm.Mutex;
import sys.db.Connection;

/*
 * 
 * Copyright (c) 2012 Jonas Malaco Filho
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */


class MutexConnection implements Connection {

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