package vehjo;

import StringTools.lpad;

/**
Local and current timezone offsets

Copyright 2012, 2017  Jonas Malaco Filho
Licensed under the MIT license; see LICENSE.txt for more information
**/
class Timezone {
	/**
	Offset (ms) for the local timezone.

	Returns an offset in milliseconds that does not change whether we are in
	daylight savings time (DST) or not.
	**/
	public static function localTimezone():Float
	{
		var x1 = 181. * 24 * 3600 * 1000 - new Date( 1970, 6, 1, 0, 0, 0 ).getTime();
		var x2 = 365. * 24 * 3600 * 1000 - new Date( 1971, 0, 1, 0, 0, 0 ).getTime();
		return Math.min( x1, x2 );
	}

	/**
	Timezone offset (ms) valid at an specified `date`.

	Returns an offset in milliseconds, taking into account daylight savings time
	(DST).

	If `date` is `null`, returns the offset for the current timezone.
	**/
	public static function currentTimezone(?date=null):Float
	{
		if ( date==null )
			date = Date.now();
		var utc = date.getTime();
		var days = 24*3600*1e3*Math.floor(utc/24/3600/1e3);
		var local = days + date.getHours()*3600*1e3 + date.getMinutes()*60*1e3 + date.getSeconds()*1e3;
		return Math.round((local - utc)/1e3)*1e3;  // discard sub-second info
	}

	/**
	ISO 8601 string representation of an offset.

	Examples:
	 - UTC time offset: "+0000"
	 - BST standard time offset: "-0300"
	**/
	public static function offsetToString(ms:Float):String
	{
		var sign = "+";
		if (ms < 0) {
			sign = "-";
			ms = -ms;
		}
		var minutes = Math.round((ms/1e3/60) % 60);
		var hours = Math.round((ms - minutes*1e3*60)/1e3/3600);
		return sign + lpad('$hours', "0", 2) + lpad('$minutes', "0", 2);
	}
}

