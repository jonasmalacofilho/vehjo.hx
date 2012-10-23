using jonas.LazyLambda;

class TestLazyLambda implements Tests<Int> {

	var it: Iterable<Int>;
	public var name( default, null ): String;

	public function new( it: Iterable<Int> ) {
		this.it = Lambda.array( it );
		name = 'jonas.LazyLambda';
	}

	public function testFoldSum() {
		var t0 = haxe.Timer.stamp();
		it.fold( $pre + $x, 0 );
		return haxe.Timer.stamp() - t0;
	}

	public function testMapSqToList() {
		var t0 = haxe.Timer.stamp();
		it.map( $x*$x ).list();
		return haxe.Timer.stamp() - t0;
	}

	public function testMapSqToArray() {
		var t0 = haxe.Timer.stamp();
		it.map( $x*$x ).array();
		return haxe.Timer.stamp() - t0;
	}

	public function testMapSqFoldSum() {
		var t0 = haxe.Timer.stamp();
		it.map( $x*$x ).fold( $pre + $x, 0 );
		return haxe.Timer.stamp() - t0;
	}

	public function testFilterEvenMapSqFoldSum() {
		var t0 = haxe.Timer.stamp();
		it.filter( $x%2 == 0 ).map( $x*$x ).fold( $pre + $x, 0 );
		return haxe.Timer.stamp() - t0;
	}

}