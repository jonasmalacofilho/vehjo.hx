package jonas.ds;

import haxe.io.Eof;
import haxe.io.Input;
import haxe.io.Output;
import jonas.ds.HashTable;
import Type;

/*
 * Associative matrices
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

typedef AssociativeMatrix<K, D> = {
	public function set( i : K, j : K, value : D ) : D;
	public function get( i : K, j : K ) : D;
}
 
class DenseAssociativeMatrix<K, D> {
	
	public var N( default, null ) : Int;
	var index : HashTable<K, Int>;
	var names : Array<K>;
	var data : Array<Array<D>>;
	var default_value : D;

	public function new( names : Iterable<K>, default_value : D ) {
		N = 0;
		this.default_value = default_value;
		
		//index
		index = switch ( Type.typeof( names.iterator().next() ) ) {
			case TInt : cast new IntHash();
			case TClass( String ) : cast new Hash();
			default : throw 'Bad key type';
		}
		this.names = [];
		for ( name in names )
			if ( !index.exists( name ) ) {
				index.set( name, N++ );
				this.names.push( name );
			}
		
		// d alloc
		data = [];
		for ( i in 0...N ) {
			var line = data[i] = [];
			for ( j in 0...N )
				line.push( default_value );
		}
		
	}
	
	public inline function set( i : K, j : K, value : D ) {
		data[index.get( i )][index.get( j )] = value;
	}
	
	public inline function get( i : K, j : K ) : D {
		return data[index.get( i )][index.get( j )];
	}
	
	public function write( write : K -> K -> D -> Void, skip_defaults : Bool ) : Void {
		for ( i in 0...N ) {
			var namei = names[i];
			for ( j in 0...N ) {
				var value = data[i][j];
				if ( !skip_defaults || default_value != value )
					write( namei, names[j], value );
			}
		}
	}
	
	public function read1( i : Input, parse : String -> Null<{ i : K, j : K, value : D }> ) : Void {
		var line = '';
		while (
			try {
				line = i.readLine();
				true;
			}
			catch ( e : Eof ) {
				false;
			}
		) {
			var d = parse( line );
			if ( null != d )
				set( d.i, d.j, d.value );
		}
	}
	
	public function write1( o : Output, write : K -> K -> D -> String, skip_defaults : Bool ) : Void {
		for ( i in 0...N ) {
			var namei = names[i];
			for ( j in 0...N ) {
				var value = data[i][j];
				if ( !skip_defaults || default_value != value )
					o.writeString( write( namei, names[j], value ) + '\n' );
			}
		}
	}
	
	public function write2( o : Output, column_separator : String ) : Void {
		// header
		o.writeString( 'MATRIZ' );
		for ( j in 0...N )
			o.writeString( column_separator + Std.string( names[j] ) );
		o.writeString( '\n' );
		
		// data
		for ( i in 0...N ) {
			o.writeString( Std.string( names[i] ) );
			for ( j in 0...N )
				o.writeString( column_separator + Std.string( data[i][j] ) );
			o.writeString( '\n' );
		}
	}
	
	public function iterator() : Iterator<D> {
		var i = 0;
		var j = 0;
		return {
			hasNext : function() {
				return i < N && j < N;
			},
			next : function() {
				var x = data[i][j++];
				if ( j >= N ) {
					j = 0;
					i++;
				}
				return x;
			}
		};
	}
	
	public function symbols() : Iterator<K> {
		return names.iterator();
	}
	
}