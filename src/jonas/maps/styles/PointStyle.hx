package jonas.maps.styles;

/*
 * Basic point style enumeration
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */
enum PointStyle {
	Circle( radius : Float );
	Elipse( width : Float, height : Float );
	Rectangle( width : Float, height : Float );
	InvisiblePoint;
}