interface Tests<A> implements Dynamic {
	public var name( default, null ): String;
	public function testFoldSum(): Float;
	public function testMapSqToList(): Float;
	public function testMapSqToArray(): Float;
	public function testMapSqFoldSum(): Float;
	public function testFilterEvenMapSqFoldSum(): Float;
}