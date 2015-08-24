package vehjo;

import haxe.io.Bytes;
import haxe.Utf8;

/*
 * vehjo.Base16 tests
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */
 
class Base16Tests extends vehjo.unit.TestCase {

	var encoded : String;
	var decoded : Bytes;
	var problematic : Bool;
	
	public function new() {
		super();
		set_configuration( _config_default = 'basic ASCII', {
			encoded : '6a6f6e6173313233',
			decoded : Bytes.ofString( 'vehjo123' ),
			problematic : false } );
		set_configuration( 'not lower case', {
			encoded : '6a6F6E6173313233',
			decoded : Bytes.ofString( 'vehjo123' ),
			problematic : false } );
		set_configuration( 'some UTF-8', {
			encoded : 'c3a7',
			decoded : Bytes.ofString( Utf8.validate( 'ç' ) ? 'ç' : Utf8.encode( 'ç' ) ),
			problematic : false } );
		set_configuration( 'not ASCII', {
			encoded : '0123456789abcdef',
			decoded : bytesFromArray( [ 1, 35, 69, 103, 137, 171, 205, 239 ] ),
			problematic : true } );
		set_configuration( 'binary', {
			encoded : '0100ab',
			decoded : bytesFromArray( [ 1, 0, 171 ] ),
			problematic : true } );
	}
	
	function bytesToArray( b : Bytes ) {
		var a = [];
		for ( i in 0...b.length )
			a.push( b.get( i ) );
		return a;
	}
	
	function bytesFromArray( a : Array<Int> ) {
		var b = Bytes.alloc( a.length );
		for ( i in 0...a.length )
			b.set( i, a[i] );
		return b;
	}
	
	public function testEncode() {
		assertEquals( encoded.toLowerCase(), Base16.encodeBytes16( decoded ).toLowerCase(), pos_infos( 'as bytes' ) );
		#if js
		if ( !problematic )
		#end {
			assertEquals( encoded.toLowerCase(), Base16.encode16( decoded.toString() ).toLowerCase(), pos_infos( 'as string' ) );
		}
	}
	
	public function testDecode() {
		assertEquals(
			bytesToArray( decoded ).toString().toLowerCase(),
			bytesToArray( Base16.decodeBytes16( encoded ) ).toString().toLowerCase(),
			pos_infos( 'as bytes' ) );
		#if js
		if ( !problematic )
		#end {
			assertEquals(
				decoded.toString().toLowerCase(),
				Base16.decode16( encoded ).toLowerCase(),
				pos_infos( 'as string' ));
		}
	}
	
	static function add_tests( t ) {
		t.add( new Base16Tests() );
	}	
	
}