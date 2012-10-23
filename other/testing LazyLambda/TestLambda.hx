class TestLambda implements Tests<Int> {

	var it: Iterable<Int>;
	public var name( default, null ): String;

	public function new( it: Iterable<Int> ) {
		this.it = Lambda.array( it );
		name = 'Lambda';
	}

	public function testFoldSum() {
		var t0 = haxe.Timer.stamp();
		Lambda.fold( it, function ( x, first ) return first + x, 0 );
		return haxe.Timer.stamp() - t0;
	}

	public function testMapSqToList() {
		var t0 = haxe.Timer.stamp();
		Lambda.map( it, function( x ) return x*x );
		return haxe.Timer.stamp() - t0;
	}

	public function testMapSqToArray() {
		var t0 = haxe.Timer.stamp();
		Lambda.array( Lambda.map( it, function ( x ) return x*x ) );
		return haxe.Timer.stamp() - t0;
	}

	public function testMapSqFoldSum() {
		var t0 = haxe.Timer.stamp();
		Lambda.fold( Lambda.map( it, function ( x ) return x*x ), function ( x, first ) return first + x, 0 );
		return haxe.Timer.stamp() - t0;
	}

	public function testFilterEvenMapSqFoldSum() {
		var t0 = haxe.Timer.stamp();
		Lambda.fold( Lambda.filter( Lambda.map( it, function ( x ) return x*x ), function ( x ) return x%2==0 ), function ( x, first ) return first + x, 0 );
		return haxe.Timer.stamp() - t0;
	}

}