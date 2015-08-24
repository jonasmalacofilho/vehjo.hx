package vehjo;

/* Timezone computation (local and current/taking into account daylight savings time)
   Copyright 2012 Jonas Malaco Filho
   Licensed under the MIT license. Check LICENSE.txt for more information. */
class Timezone {
	
	// Returns the local (invariant on time) timezone in miliseconds
	public static function localTimezone() : Float {
		var x1 = 181. * 24 * 3600 * 1000 - new Date( 1970, 6, 1, 0, 0, 0 ).getTime();
		var x2 = 365. * 24 * 3600 * 1000 - new Date( 1971, 0, 1, 0, 0, 0 ).getTime();
		return Math.min( x1, x2 );
	}

	// Returns the current (with/without daylight savings time) timezone in miliseconds
	public static function currentTimezone( ?date=null ) : Float {
		if ( date==null )
			date = Date.now();
		date = new Date( date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0 );
		return 24. * 3600 * 1000 * Math.floor( date.getTime() / 24 / 3600 / 1000 ) - date.getTime();
	}

}