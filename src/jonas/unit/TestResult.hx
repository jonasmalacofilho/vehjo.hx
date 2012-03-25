package jonas.unit;
import haxe.rtti.Meta;

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


class TestResult extends haxe.unit.TestResult {

	static var HLINE = { StringTools.lpad( '\n', '=', 61 ); };
	
	override public function toString() : String 	{
		var buf = new StringBuf();
		buf.add( HLINE );
		buf.add( 'Test runner result summary\n' );
		buf.add( '\n' );
		var failures = 0;
		for ( test in m_tests ){
			if ( !test.success ){
				buf.add( 'Case: ' );
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

				buf.add("\n");
				failures++;
			}
		}
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