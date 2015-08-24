package vehjo.unit;

import haxe.rtti.Meta;

/*
 * This is part of vehjo.unit
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */
class TestResult extends haxe.unit.TestResult {

	static var HLINE = { StringTools.lpad( '\n', '=', 61 ); };
	
	override public function toString() : String 	{
		var buf = new StringBuf();
		buf.add( HLINE );
		buf.add( 'Test runner result summary\n' );
		var failures = 0;
		for ( test in m_tests ){
			if ( !test.success ){
				buf.add( '\nCase: ' );
				buf.add(test.classname);
				buf.add( '\nMethod: ' );
				buf.add(test.method);
				buf.add( '()\n' );
				var cm = Meta.getFields( Type.resolveClass( null != test.posInfos ? test.posInfos.className : test.classname ) );
				var mm = Reflect.field( cm, test.method );
				if ( null != mm )
					for ( x in Reflect.fields( mm ) ) {
						buf.add( '@' );
						buf.add( x );
						buf.add( ': ' );
						buf.add( Reflect.field( mm, x ).join( ', ' ) );
						buf.add( '\n' );
					}

				buf.add( 'Error: ' );
				if ( test.posInfos != null ) {
					buf.add( '(' );
					buf.add(test.posInfos.fileName);
					buf.add(":");
					buf.add(test.posInfos.lineNumber);
					if ( null != test.posInfos.customParams && test.posInfos.customParams.length > 0 ) {
						buf.add( ': ' );
						buf.add( test.posInfos.customParams.join( ', ' ) );
					}
					buf.add( ') ' );
				}
				buf.add(test.error);

				if (test.backtrace != null) {
					buf.add(test.backtrace);
					buf.add("\n");
				}
				
				buf.add( '\n' );
				failures++;
			}
		}
		buf.add( '\n' );
		if (failures == 0)
			buf.add("OK");
		else
			buf.add("FAILED");
		buf.add( '. Ran ' );
		buf.add(m_tests.length);
		if ( m_tests.length != 1 )
			buf.add(" tests, ");
		else
			buf.add( ' test, ' );
		buf.add(failures);
		buf.add(" failed, ");
		buf.add( (m_tests.length - failures) );
		buf.add(" succeeded\n");
		buf.add( HLINE );
		return buf.toString();
	}
	
}