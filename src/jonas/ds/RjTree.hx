package jonas.ds;

import jonas.RevIntIterator;
import jonas.Vector;

/**
 * R-Tree variant 'j'
 * 
 * Differences from the original R-Tree:
	 * nodes may have simultaneously both node and object entries, so no node splitting algorithm  
	 * forced 1-level reinsertion on node overflow (from R*-Tree/can be turned off)
 * 
 * Compilation switches:
 * RJTREE_DEBUG:
	 * enables access to node level and bounding box information
 * RJTREE_LISTS
     * use List (instead of Array) as bucket entries container
 * 
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */
class RjTree<T> {
	
	
	// --- (sub) tree information and entries
	
	// (sub) tree size
	public var length( default, null ) : Int;
	// parent node (null if root)
	var parent : RjTree<T>;
	// bucket entries (up to bucketSize)
	#if RJTREE_LISTS
	var entries : List<Entry<T>>;
	#else
	var entries : Array<Entry<T>>;
	#end
	// max num of entries in a bucket
	public var bucketSize( default, null ) : Int;
	// forced 1-level reinsertion on overflow
	public var forcedReinsertion( default, null ) : Bool;
	
	
	// ---- (sub) tree bounding box
	#if RJTREE_DEBUG
	public var xMin( default, null ) : Float;
	public var yMin( default, null ) : Float;
	public var xMax( default, null ) : Float;
	public var yMax( default, null ) : Float;
	public var area( default, null ) : Float;
	public var level( default, null ) : Int;
	#else
	var xMin : Float;
	var yMin : Float;
	var xMax : Float;
	var yMax : Float;
	var area : Float;
	#end
	
	
	// ---- construction
	
	public function new( ?bucketSize = 16, ?forcedReinsertion = true ) {
		this.bucketSize = bucketSize;
		this.forcedReinsertion = forcedReinsertion;
		
		#if RJTREE_LISTS
		entries = new List();
		#else
		entries = new Array();
		#end
		xMin = Math.POSITIVE_INFINITY;
		yMin = Math.POSITIVE_INFINITY;
		xMax = Math.NEGATIVE_INFINITY;
		yMax = Math.NEGATIVE_INFINITY;
		area = 0.;
		length = 0;
		#if RJTREE_DEBUG
		level = 0;
		#end
	}
	
	inline static function child<A>( parent : RjTree<A> ) : RjTree<A> {
		var r = new RjTree<A>( parent.bucketSize, parent.forcedReinsertion );
		r.parent = parent;
		#if RJTREE_DEBUG
		r.level = parent.level + 1;
		#end
		return r;
	}
	
	
	// --- querying

	static inline function searchStep<A>( cache : List<A>, stack : List<RjTree<A>>, minCacheSize : Int, xMin : Float, yMin : Float, xMax : Float, yMax : Float ) : Void {
		while ( minCacheSize > cache.length && !stack.isEmpty() ) {
			var node = stack.pop();
			if ( node.entries.length > 0 && node.rectangleOverlaps( xMin, yMin, xMax, yMax ) )
				for ( ent in node.entries )
					switch ( ent ) {
						case Node( entChild ) :
							stack.add( entChild );
						case LeafPoint( entObject, entX, entY ) :
							if ( pointOverlapsRectangle( entX, entY, xMin, yMin, xMax, yMax ) )
								cache.add( entObject );
						case LeafRectangle( entObject, entX, entY, entWidth, entHeight ) :
							if ( rectangleOverlapsRectangle( entX, entY, entX + entWidth, entY + entHeight, xMin, yMin, xMax, yMax ) )
								cache.add( entObject );
						default : throw 'Unexpected ' + ent;
					}
		}
	}
	
	public function search( xMin : Float, yMin : Float, width : Float, height : Float ) : Iterator<T> {
		if ( width < 0 )
			throw 'Width must be >= 0';
		if ( height < 0 )
			throw 'Height must be >= 0';
		var xMax = xMin + width;
		var yMax = yMin + height;
			
		var cache = new List();
		var stack = new List();
		
		stack.add( this );
		searchStep( cache, stack, 1, xMin, yMin, xMax, yMax );
		
		return {
			hasNext : function() { return !cache.isEmpty(); },
			next : function() { searchStep( cache, stack, 2, xMin, yMin, xMax, yMax ); return cache.pop(); }
		};
	}
	
	static inline function iteratorStep<A>( cache : List<A>, stack : List<RjTree<A>>, minCacheSize : Int ) : Void {
		while ( minCacheSize > cache.length && !stack.isEmpty() )
			for ( ent in stack.pop().entries )
				switch ( ent ) {
					case Node( entChild ) :
						stack.add( entChild );
					case LeafPoint( entObject, entX, entY ) :
						cache.add( entObject );
					case LeafRectangle( entObject, entX, entY, entWidth, entHeight ) :
						cache.add( entObject );
					default : throw 'Unexpected ' + ent;
				}
	}
		
	public function iterator() : Iterator<T> {
		var cache = new List();
		var stack = new List();
		
		stack.add( this );
		iteratorStep( cache, stack, 1 );
		
		return {
			hasNext : function() { return !cache.isEmpty(); },
			next : function() { iteratorStep( cache, stack, 2 ); return cache.pop(); }
		};
	}
	
	
	// ---- updating
	
	inline function evaluteCandidateEntry( ent : Entry<T>, xMin : Float, yMin : Float, xMax : Float, yMax : Float ) : Float {
		var a0 = Math.NaN;
		var xMin1 = Math.NaN;
		var yMin1 = Math.NaN;
		var xMax1 = Math.NaN;
		var yMax1 = Math.NaN;
		switch ( ent ) {
			case Node( entChild ) :
				a0 = entChild.area;
				xMin1 = Math.min( xMin, entChild.xMin );
				yMin1 = Math.min( yMin, entChild.yMin );
				xMax1 = Math.max( xMax, entChild.xMax );
				yMax1 = Math.max( yMax, entChild.yMax );
			case LeafPoint( entObject, entX, entY ) :
				a0 = 0.;
				xMin1 = Math.min( xMin, entX );
				yMin1 = Math.min( yMin, entY );
				xMax1 = Math.max( xMax, entX );
				yMax1 = Math.max( yMax, entY );
			case LeafRectangle( entObject, entX, entY, entWidth, entHeight ) :
				a0 = rectangleArea( entX, entY, entX + entWidth, entY + entHeight );
				xMin1 = Math.min( xMin, entX );
				yMin1 = Math.min( yMin, entY );
				xMax1 = Math.max( xMax, entX + entWidth );
				yMax1 = Math.max( yMax, entY + entHeight );
			default : throw 'Unexpected ' + ent;
		}
		var a1 = rectangleArea( xMin1, yMin1, xMax1, yMax1 );
		return a1 - a0; // basic stuff
	}
	
	inline function chooseEntryToInsert( xMin : Float, yMin : Float, xMax : Float, yMax : Float ) : #if RJTREE_LISTS Entry<T> #else Int #end {
		var best = Math.POSITIVE_INFINITY;
		#if RJTREE_LISTS
		var bestEntry = Empty;
		for ( ent in entries ) {
			var x = evaluteCandidateEntry( ent, xMin, yMin, xMax, yMax );
		#else
		var bestEntry = -1;
		for ( i in 0...entries.length ) {
			var x = evaluteCandidateEntry( entries[i], xMin, yMin, xMax, yMax );
		#end
			if ( x < best ) {
				best = x;
				#if RJTREE_LISTS
				bestEntry = ent;
				#else
				bestEntry = i;
				#end
			}
		}
		return bestEntry;
	}
	
	function insertOnOverflow( ent : Entry<T>, reinsert : Bool ) : Void {
		#if !RJTREE_LISTS
		var pi = -1;
		#end
		var p = switch ( ent ) {
			case LeafPoint( entObject, entX, entY ) :
				#if RJTREE_LISTS
				chooseEntryToInsert( entX, entY, entX, entY );
				#else
				entries[ pi = chooseEntryToInsert( entX, entY, entX, entY ) ];
				#end
			case LeafRectangle( entObject, entX, entY, entWidth, entHeight ) :
				#if RJTREE_LISTS
				chooseEntryToInsert( entX, entY, entX + entWidth, entY + entHeight );
				#else
				entries[ pi = chooseEntryToInsert( entX, entY, entX + entWidth, entY + entHeight ) ];
				#end
			default : throw 'Unexpected ' + ent;
		};
		switch ( p ) {
			case Empty : throw 'Unexpected ' + p;
			case Node( pChild ) :
				// propagate
				pChild.insertEntry( ent );
			default :
				// split
				var newChild = child( this );
				#if RJTREE_LISTS
				entries.remove( p );
				entries.push( Node( newChild ) );
				#else
				entries[pi] = Node( newChild );
				#end
				// insert the new leaf
				newChild.entries.push( ent );
				// insert the original leaf
				if ( reinsert ) {
					newChild.computeBoundingBox();
					insertOnOverflow( p, false );
				}
				else {
					newChild.entries.push( p );
					newChild.computeBoundingBox();
				}
				
		}
	}
	
	function insertEntry( ent : Entry<T> ) : Void {
		if ( entries.length < bucketSize ) {
			// just push
			entries.push( ent );
			switch ( ent ) {
				case LeafPoint( entObject, entX, entY ) : expandBoundingBox( entX, entY, entX, entY ); 
				case LeafRectangle( entObject, entX, entY, entWidth, entHeight ) : expandBoundingBox( entX, entY, entX + entWidth, entY + entHeight );
				default : throw 'Unexpected ' + ent;
			}
		}
		else {
			// maximum number of entries per node reached
			// must split an entry
			insertOnOverflow( ent, forcedReinsertion );
		}
		length++;
	}
	
	public function insertPoint( x : Float, y : Float, object : T ) : Void {
		insertEntry( LeafPoint( object, x, y ) );
	}
	
	public function insertRectangle( x : Float, y : Float, width : Float, height : Float, object : T ) : Void {
		if ( width < 0 )
			throw 'Width must be >= 0';
		if ( height < 0 )
			throw 'Height must be >= 0';
		insertEntry( LeafRectangle( object, x, y, x + width, y + height ) );
	}
	
	public function removePoint( x : Float, y : Float, ?object : Null<T> ) : Int {
		var removed = 0;
		if ( entries.length > 0 && pointOverlaps( x, y ) )
			#if RJTREE_LISTS
			for ( ent in entries ) {
			#else
			for ( i in new RevIntIterator( entries.length, 0 ) ) {
				var ent = entries[i];
			#end
				switch ( ent ) {
					case Node( entChild ) : 
						removed += entChild.removePoint( x, y, object );
					case LeafPoint( entObject, entX, entY ) : 
						if ( entX == x && entY == y && ( null == object || entObject == object ) ) {
							#if RJTREE_LISTS
							entries.remove( ent );
							#else
							if ( i < entries.length - 1 )
								entries[i] = entries.pop();
							else
								entries.pop();
							#end
							removed++;
							computeBoundingBox();
						}
					case LeafRectangle( entObject, entX, entY, entWidth, entHeight ) : // nothing to do
					default : throw 'Unexpected ' + ent;
				}
			}
		length -= removed;
		return removed;
	}
	
	public function removeRectangle( x : Float, y : Float, width : Float, height : Float, ?object : T ) : Int {
		if ( width < 0 )
			throw 'Width must be >= 0';
		if ( height < 0 )
			throw 'Height must be >= 0';
		var removed = 0;
		if ( entries.length > 0 && rectangleOverlaps( x, y, x + width, y + height ) )
			#if RJTREE_LISTS
			for ( ent in entries ) {
			#else
			for ( i in new RevIntIterator( entries.length, 0 ) ) {
				var ent = entries[i];
			#end
				switch ( ent ) {
					case Node( entChild ) : 
						removed += entChild.removeRectangle( x, y, width, height, object );
					case LeafRectangle( entObject, entX, entY, entWidth, entHeight ) : 
						if ( entX == x && entY == y && entWidth == width && height == height && ( null == object || entObject == object ) ) {
							#if RJTREE_LISTS
							entries.remove( ent );
							#else
							if ( i < entries.length - 1 )
								entries[i] = entries.pop();
							else
								entries.pop();
							#end
							removed++;
							computeBoundingBox();
						}
					case LeafPoint( entObject, entX, entY ) : // nothing to do
					default : throw 'Unexpected ' + ent;
				}
			}
		length -= removed;
		return removed;
	}
	
	public function removeObject( object : T ) : Int {
		var removed = 0;
		if ( entries.length > 0 )
			#if RJTREE_LISTS
			for ( ent in entries ) {
			#else
			for ( i in new RevIntIterator( entries.length, 0 ) ) {
				var ent = entries[i];
			#end
				switch ( ent ) {
					case Node( entChild ) : 
						removed += entChild.removeObject( object );
					case LeafPoint( entObject, entX, entY ) : 
						if ( entObject == object ) {
							#if RJTREE_LISTS
							entries.remove( ent );
							#else
							if ( i < entries.length - 1 )
								entries[i] = entries.pop();
							else
								entries.pop();
							#end
							removed++;
							computeBoundingBox();
						}
					case LeafRectangle( entObject, entX, entY, entWidth, entHeight ) : 
						if ( entObject == object ) {
							#if RJTREE_LISTS
							entries.remove( ent );
							#else
							if ( i < entries.length - 1 )
								entries[i] = entries.pop();
							else
								entries.pop();
							#end
							removed++;
							computeBoundingBox();
						}
					default : throw 'Unexpected ' + ent;
				}
			}
		length -= removed;
		return removed;
	}
	
	
	// ---- rectangle helpers
	
	static inline function rectangleArea( _xMin : Float, _yMin : Float, _xMax : Float, _yMax : Float ) : Float {
		return ( _xMax - _xMin ) * ( _yMax - _yMin );
	}
	
	inline function boundingBoxArea() : Float { return rectangleArea( xMin, yMin, xMax, yMax ); }
	
	static inline function pointOverlapsRectangle( x : Float, y : Float, _xMin : Float, _yMin : Float, _xMax : Float, _yMax : Float ) : Bool {
		return x >= _xMin && x <= _xMax && y >= _yMin && y <= _yMax;
	}	
	
	inline function pointOverlaps( x : Float, y : Float ) : Bool { return pointOverlapsRectangle( x, y, xMin, yMin, xMax, yMax ); }
	
	static inline function rectangleOverlapsRectangle( xMin : Float, yMin : Float, xMax : Float, yMax : Float, _xMin : Float, _yMin : Float, _xMax : Float, _yMax : Float ) : Bool {
		return xMax >= _xMin && _xMax >= xMin && yMax >= _yMin && _yMax >= yMin;
	}
	
	inline function rectangleOverlaps( xMin : Float, yMin : Float, xMax : Float, yMax : Float ) : Bool { return rectangleOverlapsRectangle( xMin, yMin, xMax, yMax, this.xMin, this.yMin, this.xMax, this.yMax ); }
	
	function computeBoundingBox() : Void {
		var xMin = Math.POSITIVE_INFINITY;
		var yMin = Math.POSITIVE_INFINITY;
		var xMax = Math.NEGATIVE_INFINITY;
		var yMax = Math.NEGATIVE_INFINITY;
		
		for ( ent in entries )
			switch ( ent ) {
				case Node( entChild ) : 
					xMin = Math.min( xMin, entChild.xMin );
					yMin = Math.min( yMin, entChild.yMin );
					xMax = Math.max( xMax, entChild.xMax );
					yMax = Math.max( yMax, entChild.yMax );
				case LeafPoint( entChild, entX, entY ) :
					xMin = Math.min( xMin, entX );
					yMin = Math.min( yMin, entY );
					xMax = Math.max( xMax, entX );
					yMax = Math.max( yMax, entY );
				case LeafRectangle( entChild, entX, entY, entWidth, entHeight ) :
					xMin = Math.min( xMin, entX );
					yMin = Math.min( yMin, entY );
					xMax = Math.max( xMax, entX + entWidth );
					yMax = Math.max( yMax, entY + entHeight );
				default : throw 'Unexpected ' + ent;
			}
		
		var updated = false;
		if ( xMin != this.xMin ) {
			this.xMin = xMin;
			updated = true;
		}
		if ( yMin != this.yMin ) {
			this.yMin = yMin;
			updated = true;
		}
		if ( xMax != this.xMax ) {
			this.xMax = xMax;
			updated = true;
		}
		if ( yMax != this.yMax ) {
			this.yMax = yMax;
			updated = true;
		}
		if ( updated ) {
			area = boundingBoxArea();
			if ( null != parent )
				parent.computeBoundingBox();
		}
	}
	
	function expandBoundingBox( xMin : Float, yMin : Float, xMax : Float, yMax : Float ) : Void {
		var updated = false;
		if ( xMin < this.xMin ) {
			this.xMin = xMin;
			updated = true;
		}
		if ( yMin < this.yMin ) {
			this.yMin = yMin;
			updated = true;
		}
		if ( xMax > this.xMax ) {
			this.xMax = xMax;
			updated = true;
		}
		if ( yMax > this.yMax ) {
			this.yMax = yMax;
			updated = true;
		}
		if ( updated ) {
			area = boundingBoxArea();
			if ( null != parent )
				parent.expandBoundingBox( xMin, yMin, xMax, yMax );
		}
	}
	
	
	// ---- debug api
	#if RJTREE_DEBUG
	
	public static inline var BUCKET_ENTRIES_CONTAINER = #if RJTREE_LISTS 'List' #else 'Array' #end;
	
	static inline function bBoxIteratorStep<A>( cache : List<RjTreeBoundingBox>, stack : List<RjTree<A>>, minCacheSize : Int ) : Void {
		while ( minCacheSize > cache.length && !stack.isEmpty() ) {
			var node = stack.pop();
			cache.add( new RjTreeBoundingBox( node.xMin, node.yMin, node.xMax, node.yMax, node.area, node.level ) );
			for ( ent in node.entries )
				switch ( ent ) {
					case Node( entChild ) :
						stack.add( entChild );
					case LeafPoint( entObject, entX, entY ) : // nothing to do here
					case LeafRectangle( entObject, entX, entY, entWidth, entHeight ) : // nothing to do here
					default : throw 'Unexpected ' + ent;
				}
		}
	}
		
	public function boudingBoxes() : Iterator<RjTreeBoundingBox> {
		var cache = new List();
		var stack = new List();
		
		stack.add( this );
		bBoxIteratorStep( cache, stack, 1 );
		
		return {
			hasNext : function() { return !cache.isEmpty(); },
			next : function() { bBoxIteratorStep( cache, stack, 2 ); return cache.pop(); }
		};
	}
	
	public function maxDepth() : Int {
		var maxLevel = level;
		for ( b in boudingBoxes() )
			if ( b.level > maxLevel )
				maxLevel = b.level;
		return maxLevel + 1;
	}
	
	#end
	
}

private enum Entry<T> {
	Node( child : RjTree<T> );
	LeafPoint( object : T, x : Float, y : Float );
	LeafRectangle( object : T, x : Float, y : Float, width : Float, height : Float );
	Empty;
}

#if RJTREE_DEBUG
class RjTreeBoundingBox {
	public var xMin( default, null ) : Float;
	public var yMin( default, null ) : Float;
	public var xMax( default, null ) : Float;
	public var yMax( default, null ) : Float;
	public var area( default, null ) : Float;
	public var level( default, null ) : Int;
	public function new( xMin, yMin, xMax, yMax, area, level ) {
		this.xMin = xMin;
		this.yMin = yMin;
		this.xMax = xMax;
		this.yMax = yMax;
		this.area = area;
		this.level = level;
	}
	public function toString() : String {
		return '{(' + xMin + ',' + yMin + '),(' + xMax + ',' + yMax + ')}';
	}
}
#end
