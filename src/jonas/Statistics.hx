package jonas;

/**
	Statistics
	Copyright 2012 Jonas Malaco Filho. Licensed under the MIT License. 
**/
class Statistics {
	
	/* i.iterator must be imutable
	   only if min and max are supplied that i.iterator may have side-effects */
	public static function hist( i: Iterable<Float>, ?noBins=10, ?min: Float, ?max: Float )
	: { names: Array<Float>, values: Array<Int> } {
		
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
		var bins = Lam.map( Lam.it( 0...noBins ), function ( i ) return 0 );
		var binNames = Lam.map( Lam.it( 0...noBins ), function ( i ) return dx*i );

		var insert = function ( x: Float ) bins[Std.int( ( x - _min )/dx )] += 1;
		for ( x in i )
			if ( x >= _min && x <= _max )
				insert( x );
		
		return { names: binNames, values: bins };
	}

}