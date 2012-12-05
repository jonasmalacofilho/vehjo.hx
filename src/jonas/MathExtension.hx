package jonas;

/*
 * Math aditional functions
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT License. Check LICENSE.txt for more information.
 */

class MathExtension 
{
	
	public static inline function round(v : Float, ?p = 0) : Float
	{
		var f = Math.pow(10., p);
		if (0x3FFFFFFF / f >= Math.abs(v))
			return Math.round(v * f) / f;
		else if (0x3FFFFFFF >= Math.abs(v) && 0x3FFFFFFF >= f) {
			var ip = Math.round(v);
			var dp = Math.round((v - ip) * f) / f;
			return ip + dp;
		}
		else
			return v;
	}
	
	inline public static function logb(v : Float, b : Float)
	{
		return Math.log(v) / Math.log(b);
	}
	
	inline public static function to_radians(deg : Float) : Float
	{
		return deg / 180. * Math.PI;
	}
	
	inline public static function eq(precision : Float, a : Float, b : Float) : Bool
	{
		return !(a - b > precision || a - b < - precision);
	}
	
	/**
	 * Returns the earth radius estimate in meters, based on a given
	 * latitude in degrees
	 * Based on: http://www.faqs.org/faqs/geography/infosystems-faq/
	 */
	inline static public function earth_radius( lat: Float ): Float {
		return ( 6378.137 - 21.*Math.abs( Math.sin( to_radians( lat ) ) ) )*1000.;
	}
	
	/**
	 * Calculate the distance in meters on the geoid between two given points
	 * Point coordinates must be supplied in latitude, longitude and in degrees
	 * Calculation performed using the 'haversine' formulation:
	 * http://www.faqs.org/faqs/geography/infosystems-faq/
	 * http://www.movable-type.co.uk/scripts/latlong.html
	 */
	inline static public function earth_distance_haversine(lat1 : Float, lon1 : Float, lat2 : Float, lon2 : Float) : Float
	{
		var dlat = to_radians(lat2 - lat1);
		var dlon = to_radians(lon2 - lon1);
		var arc = Math.sin(dlat * .5) * Math.sin(dlat * .5) 
				+ Math.sin(dlon * .5) * Math.sin(dlon * .5) * Math.cos(to_radians(lat1)) * Math.cos(to_radians(lat2));
		return earth_radius((lat1 + lat2) * .5) * 2. * Math.atan2(Math.sqrt(arc), Math.sqrt(1 - arc));
	}
	
	/**
	 * Mod operator (finite fields, from 0 to b-1)
	 */
	public static inline function mod( a : Int, b : Int ) : Int {
		return ( 0 > a ) ? a % b + b : a % b;
	}
	
	public static inline function pow2( e : Int ) : Int { return 1 << e; }
	
	/**
	 * Faster alternative to mod 2^r
	 */
	public static inline function mod2r( a : Int, r : Int ) : Int {
		return a & ( pow2( r ) - 1 );
	}
	
	public static inline var INT_MAX = #if neko 0x3fffffff #else 0x7fffffff #end;
	public static inline var INT_MIN = #if neko 0xc0000000 #else 0x80000000 #end;
	
}