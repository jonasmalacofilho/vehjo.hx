package jonas;

import jonas.Base64;

/*
 * Base64 test suite
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */
 
class Base64SimpleTestCase extends jonas.unit.TestCase {
	var inp : String;
	var out : String;
	var b : Base64;
	
	public function new() {
		super();
		set_configuration( 'any carnal pleasure.', 'YW55IGNhcm5hbCBwbGVhc3VyZS4=' );
		set_configuration( 'any carnal pleasure', 'YW55IGNhcm5hbCBwbGVhc3VyZQ==' );
		set_configuration( 'any carnal pleasur', 'YW55IGNhcm5hbCBwbGVhc3Vy' );
		set_configuration( 'any carnal pleasu', 'YW55IGNhcm5hbCBwbGVhc3U=' );
		set_configuration( 'any carnal pleas', 'YW55IGNhcm5hbCBwbGVhcw==' );
		set_configuration( 'pleasure.', 'cGxlYXN1cmUu' );
		set_configuration( 'leasure.', 'bGVhc3VyZS4=' );
		set_configuration( 'easure.', 'ZWFzdXJlLg==' );
		set_configuration( 'asure.', 'YXN1cmUu' );
		set_configuration( 'sure.', 'c3VyZS4=' );
		set_configuration( 'Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure.',
'TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlz
IHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2Yg
dGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGlu
dWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRo
ZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=' );
		_config_default = 'Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure.';
		
	}
	
	override public function setup() : Void {
		super.setup();
		b = new Base64( 76 );
	}
	
	override function configure( name : String ) : Void {
		inp = name;
		out = _configs.get( name );
	}
	
	public function test_encode() : Void {
		assertEquals( out, b.encode_string( inp ) );
	}
	
	public function test_encode_decode() : Void {
		assertEquals( inp, b.decode_string( b.encode_string( inp ) ) );
	}
}

class Base64TestSuite {
	public static function main() {
		var a = new jonas.unit.TestRunner();
		add_tests( a );
		a.run();
	}
	public static function add_tests( a : jonas.unit.TestRunner ) {
		a.add( new Base64SimpleTestCase() );

	}
}
