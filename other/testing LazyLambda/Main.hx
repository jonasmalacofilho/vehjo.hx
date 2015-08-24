import vehjo.macro.Debug;
using vehjo.LazyLambda;

class Main {
	static function main() {

		var it = [0,1,2];
		Debug.assert( it.map( $x ).array() );

		haxe.Log.trace = function( v: Dynamic, ?p: haxe.PosInfos ) Sys.println( v );

		trace( 'Testing "array"' );
		Debug.assert( ( 10...15 ).lazy().array() ); // [10,11,12,13,14]

		trace( 'Testing "concat"' );
		Debug.assert( ( 10...15 ).lazy().concat( ( 20...25 ).lazy() ).array() ); // [10,11,12,13,14,20,21,22,23,24]

		trace( 'Testing "count"' );
		Debug.assert( ( 10...15 ).lazy().count() ); // 5

		trace( 'Testing "empty"' );
		Debug.assert( ( 10...15 ).lazy().empty() ); // false
		Debug.assert( ( 15...15 ).lazy().empty() ); // true

		trace( 'Testing "filter"' );
		Debug.assert( ( 10...15 ).lazy().filter( true ).array() ); // [10,11,12,13,14]
		Debug.assert( ( 10...15 ).lazy().filter( $i == 1 ).array() ); // [11]
		Debug.assert( ( 10...15 ).lazy().filter( $x == 11 ).array() ); // [11]
		Debug.assert( ( 10...15 ).lazy().filter( $x + $i == 12 ).array() ); // [11]
		Debug.assert( ( 10...15 ).lazy().filter( false ).array() ); // []
		Debug.assert( ( 10...15 ).lazy().filter( $i == -1 ).array() ); // []
		Debug.assert( ( 10...15 ).lazy().filter( $x == -1 ).array() ); // []
		Debug.assert( ( 10...15 ).lazy().filter( $x + $i == -1 ).array() ); // []

		trace( 'Testing "find"' );
		Debug.assert( ( 10...15 ).lazy().find( true ) ); // 10
		Debug.assert( ( 10...15 ).lazy().find( $i == 1 ) ); // 11
		Debug.assert( ( 10...15 ).lazy().find( $x == 11 ) ); // 11
		Debug.assert( ( 10...15 ).lazy().find( $x + $i == 12 ) ); // 11
		Debug.assert( ( 10...15 ).lazy().find( false ) ); // null
		Debug.assert( ( 10...15 ).lazy().find( $i == -1 ) ); // null
		Debug.assert( ( 10...15 ).lazy().find( $x == -1 ) ); // null
		Debug.assert( ( 10...15 ).lazy().find( $x + $i == -1 ) ); // null

		trace( 'Testing "fold"' );
		Debug.assert( ( 10...15 ).lazy().fold( 1, 1 ) ); // 1
		Debug.assert( ( 10...15 ).lazy().fold( $pre + 1, 1 ) ); // 6
		Debug.assert( ( 10...15 ).lazy().fold( $pre + $i, 1 ) );  // 11
		Debug.assert( ( 10...15 ).lazy().fold( $pre + $i + $x, 1 ) ); // 71

		trace( 'Testing "holdsOnce"' );
		Debug.assert( ( 10...15 ).lazy().holdsOnce( true ) ); // true
		Debug.assert( ( 10...15 ).lazy().holdsOnce( $i == 1 ) ); // true
		Debug.assert( ( 10...15 ).lazy().holdsOnce( $x == 11 ) ); // true
		Debug.assert( ( 10...15 ).lazy().holdsOnce( $x + $i == 12 ) ); // true
		Debug.assert( ( 10...15 ).lazy().holdsOnce( false ) ); // false
		Debug.assert( ( 10...15 ).lazy().holdsOnce( $i == -1 ) ); // false
		Debug.assert( ( 10...15 ).lazy().holdsOnce( $x == -1 ) ); // false
		Debug.assert( ( 10...15 ).lazy().holdsOnce( $x + $i == -1 ) ); // false

		trace( 'Testing "holds"' );
		Debug.assert( ( 10...15 ).lazy().holds( true ) ); // true
		Debug.assert( ( 10...15 ).lazy().holds( $i < 5 ) ); // true
		Debug.assert( ( 10...15 ).lazy().holds( $x < 15 ) ); // true
		Debug.assert( ( 10...15 ).lazy().holds( $x + $i < 20 ) ); // true
		Debug.assert( ( 10...15 ).lazy().holds( false ) ); // false
		Debug.assert( ( 10...15 ).lazy().holds( $i < 4 ) ); // false
		Debug.assert( ( 10...15 ).lazy().holds( $x < 14 ) ); // false
		Debug.assert( ( 10...15 ).lazy().holds( $x + $i < 18 ) ); // false

		trace( 'Testing "indexOf"' );
		Debug.assert( ( 10...15 ).lazy().indexOf( true ) ); // 0
		Debug.assert( ( 10...15 ).lazy().indexOf( $i == 1 ) ); // 1
		Debug.assert( ( 10...15 ).lazy().indexOf( $x == 11 ) ); // 1
		Debug.assert( ( 10...15 ).lazy().indexOf( $x + $i == 12 ) ); // 1
		Debug.assert( ( 10...15 ).lazy().indexOf( false ) ); // -1
		Debug.assert( ( 10...15 ).lazy().indexOf( $i == -1 ) ); // -1
		Debug.assert( ( 10...15 ).lazy().indexOf( $x == -1 ) ); // -1
		Debug.assert( ( 10...15 ).lazy().indexOf( $x + $i == -1 ) ); // -1

		trace( 'Testing "iter"' );
		Debug.assert( { var y = []; ( 10...15 ).lazy().iter( y.push( 1 ) ); y; } ); // [1,1,1,1,1]
		Debug.assert( { var y = []; ( 10...15 ).lazy().iter( y.push( $i*2 ) ); y; } ); // [0,2,4,6,8]
		Debug.assert( { var y = []; ( 10...15 ).lazy().iter( y.push( $x*2 ) ); y; } ); // [20,22,24,26,28]
		Debug.assert( { var y = []; ( 10...15 ).lazy().iter( y.push( $x + $i ) ); y; } ); // [10,12,14,16,18]

		trace( 'Testing "map"' );
		Debug.assert( ( 10...15 ).lazy().map( 1 ).array() ); // [1,1,1,1,1]
		Debug.assert( ( 10...15 ).lazy().map( $i*2 ).array() ); // [0,2,4,6,8]
		Debug.assert( ( 10...15 ).lazy().map( $x*2 ).array() ); // [20,22,24,26,28]
		Debug.assert( ( 10...15 ).lazy().map( $x + $i ).array() ); // [10,12,14,16,18]

	}
}