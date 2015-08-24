import vehjo.Statistics;
using vehjo.LazyLambda;
using vehjo.NumberPrinter;

class BenchmarkLambda {
	static function main() {
		var dataSize = 256*1024; // since data element is a 4-byte integer, 10 KiB
		var noRuns = 100;

		Sys.println( Std.format( 'data size = $dataSize * 4 byte = ${dataSize*4} bytes; $noRuns runs for each (test,implementation) pair' ) );

		var data = ( 0...dataSize ).lazy().array();
		var tests: Array<Tests<Int>> = [ new TestLambda( data ), new TestLam( data ), new TestLazyLambda( data ) ];

		for ( method in Type.getInstanceFields( Tests ) ) {
			if ( method.substr( 0, 4 ) != 'test' )
				continue;
			Sys.println( 'testing function ' + method );
			for ( test in tests ) {
				Sys.print( '  using ' + test.name );
				var methodFucn = Reflect.field( test, method );
				var times = ( 0...noRuns ).lazy().map( Reflect.callMethod( test, methodFucn, [] ) ).array();
				var avg = times.fold( $pre + $x, 0. )/noRuns*1e3;
				var stdDev = Math.sqrt( times.fold( $pre + ( $x*1e3 - avg )*( $x*1e3 - avg ), 0. )/( noRuns - 1 ) );
				Sys.print( ': avg=' + avg.printDecimal( 1, 3 ) + 'ms sampleStdDev=' + stdDev.printDecimal( 1, 3 ) + 'ms' );
				var hist = Statistics.hist( times, 10 );
				Sys.println( ' hist: ' + hist.lowerNames.map( [ Math.floor( $x*1e3 ), hist.values[$i] ] ).array().join( ' ' ) );
			}
		}
	}
}
