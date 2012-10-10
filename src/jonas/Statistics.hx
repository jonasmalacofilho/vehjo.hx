package jonas;

using jonas.LazyLambda;

/**
	Statistics
	Copyright 2012 Jonas Malaco Filho. Licensed under the MIT License. 
**/
class Statistics {
	
	public static function hist( i: Iterable<Float>, ?noBins=10, ?min: Null<Float>, ?max: Null<Float> )
	: { width: Float, lowerNames: Array<Float>, values: Array<Int> } {
		
		var _min = Math.POSITIVE_INFINITY;
		var _max = Math.NEGATIVE_INFINITY;

		if ( min==null || max==null )
			for ( x in i ) {
				if ( x < _min )
					_min = x;
				if ( x > _max )
					_max = x;
			}

		if ( min != null )
			_min = min;
		if ( max != null )
			_max = max;

		var dx = ( _max - _min ) / ( noBins - 1 );
		var bins = ( 0...noBins ).lazy().map( 0 ).array();
		var lowerNames = bins.map( _min + dx * $x ).array();

		for ( x in i )
			if ( x >= _min && x <= _max )
				bins[Std.int( ( x - _min )/dx )] += 1;

		return { width: dx, lowerNames: lowerNames, values: bins };
	}

}