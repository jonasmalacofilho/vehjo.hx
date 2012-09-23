package jonas.format;

import haxe.io.Eof;
import haxe.io.StringInput;
import jonas.format.csv.Reader;
import jonas.format.csv.Writer;

class TestCSV extends jonas.unit.TestCase {

	static var d1 = [ 'a,b,cNL1,2,3NL', 'a|b|c;1|2|3' ];
	static var d2 = [ 'a, b,c NL', 'a| b|c ' ];
	static var d3 = [ 'a,"b",cNL', 'a|b|c' ];
	static var d4 = [ '"aNL","b""","c,",d","e""""",f""NL', 'aNL|b"|c,|d"|e""|f""' ];
	// static var d5 = [ 'a,"b""",c","d,""NL', 'a|b"|c"|"d|""' ];

	function readEverything( x : String, ?sep=',', ?qte='"', ?nl='\r\n' ) {
		var x = new Reader( new StringInput( x ), sep, qte, nl );
		var data = [];
		while ( true ) try {
			data.push( x.readRecord().join( '|' ) );
		}
		catch ( e : Eof ) { break; }
		return data.join( ';' );
	}

	function testReaderBasic() {
		// ending on newline
		assertEquals( d1[1], readEverything( d1[0], ',', '"', 'NL' ) );
		assertEquals( d1[1], readEverything( d1[0].split( 'NL' ).join( 'N' ), ',', '"', 'N' ) );
		assertEquals( d2[1], readEverything( d2[0], ',', '"', 'NL' ) );
		assertEquals( d2[1], readEverything( d2[0].split( 'NL' ).join( 'N' ), ',', '"', 'N' ) );

		// ending on EOF
		assertEquals( d1[1], readEverything( d1[0].substr( 0, d1[0].length-2 ), ',', '"', 'NL' ) );
		assertEquals( d1[1], readEverything( d1[0].substr( 0, d1[0].length-2 ).split( 'NL' ).join( 'N' ), ',', '"', 'N' ) );
		assertEquals( d2[1], readEverything( d2[0].substr( 0, d2[0].length-2 ), ',', '"', 'NL' ) );
		assertEquals( d2[1], readEverything( d2[0].substr( 0, d2[0].length-2 ).split( 'NL' ).join( 'N' ), ',', '"', 'N' ) );
	}

	function testReaderQuotes() {
		// ending on newline
		assertEquals( d3[1], readEverything( d3[0], ',', '"', 'NL' ) );
		assertEquals( d3[1], readEverything( d3[0].split( 'NL' ).join( 'N' ), ',', '"', 'N' ) );
		assertEquals( d4[1], readEverything( d4[0], ',', '"', 'NL' ) );
		assertEquals( d4[1].split( 'NL' ).join( 'N' ), readEverything( d4[0].split( 'NL' ).join( 'N' ), ',', '"', 'N' ) );

		// ending on eof
		assertEquals( d3[1], readEverything( d3[0].substr( 0, d3[0].length-2 ), ',', '"', 'NL' ) );
		assertEquals( d3[1], readEverything( d3[0].substr( 0, d3[0].length-2 ).split( 'NL' ).join( 'N' ), ',', '"', 'N' ) );
		assertEquals( d4[1], readEverything( d4[0].substr( 0, d4[0].length-2 ), ',', '"', 'NL' ) );
		assertEquals( d4[1].split( 'NL' ).join( 'N' ), readEverything( d4[0].substr( 0, d4[0].length-2 ).split( 'NL' ).join( 'N' ), ',', '"', 'N' ) );

		// assertEquals( d5[1], readEverything( d5[0], ',', '"', 'NL' ) );
		// assertEquals( d5[1], readEverything( d5[0].split( 'NL' ).join( 'N' ), ',', '"', 'N' ) );
	}

	static function main() {
		var x = new jonas.unit.TestRunner();
		x.add( new TestCSV() );
		x.run();
	}

}