package jonas;

class Timezone {
	
	public static function localTimezone() : Float {
		var x1 = 181. * 24 * 3600 * 1000 - new Date( 1970, 6, 1, 0, 0, 0 ).getTime();
		var x2 = 365. * 24 * 3600 * 1000 - new Date( 1971, 0, 1, 0, 0, 0 ).getTime();
		return Math.min( x1, x2 );
	}

	public static function currectTimezone( ?date=null ) : Float {
		if ( date==null )
			date = Date.now();
		date = new Date( date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0 );
		return 24. * 3600 * 1000 * Math.floor( date.getTime() / 24 / 3600 / 1000 ) - date.getTime();
	}

}