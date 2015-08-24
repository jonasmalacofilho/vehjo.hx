import vehjo.Lam;

class TestLam implements Tests<Int> {

	var it: Iterable<Int>;
	public var name( default, null ): String;

	public function new( it: Iterable<Int> ) {
		this.it = Lambda.array( it );
		name = 'vehjo.Lam';
	}

	public function testFoldSum() {
		var t0 = haxe.Timer.stamp();
		Lam.fold( it, function ( x, first ) return first + x, 0 );
		return haxe.Timer.stamp() - t0;
	}

	public function testMapSqToList() {
		var t0 = haxe.Timer.stamp();
		Lambda.list( Lam.map( it, function( x ) return x*x ) );
		return haxe.Timer.stamp() - t0;
	}

	public function testMapSqToArray() {
		var t0 = haxe.Timer.stamp();
		Lam.map( it, function ( x ) return x*x );
		return haxe.Timer.stamp() - t0;
	}

	public function testMapSqFoldSum() {
		var t0 = haxe.Timer.stamp();
		Lam.fold( Lam.map( it, function ( x ) return x*x ), function ( x, first ) return first + x, 0 );
		return haxe.Timer.stamp() - t0;
	}

	public function testFilterEvenMapSqFoldSum() {
		var t0 = haxe.Timer.stamp();
		Lam.fold( Lam.filter( Lam.map( it, function ( x ) return x*x ), function ( x ) return x%2==0 ), function ( x, first ) return first + x, 0 );
		return haxe.Timer.stamp() - t0;
	}

}