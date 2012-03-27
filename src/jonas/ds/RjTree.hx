package jonas.ds;

import jonas.Vector;

/**
 * R-Tree variant 'j'.
 * Changes from the original R-Tree:
	 * - nodes may have simultaneously both node and object entries
	 * - no node splitting algorithm
	 * - forced 1-level reinsertion on node overflow (from R*-Tree)
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
	var entries : EntryContainer<T>;
	// max num of entries in a bucket
	public var bucketSize( default, null ) : Int;
	// forced 1-level reinsertion on overflow
	public var forcedReinsertion( default, null ) : Bool;
	
	
	// ---- (sub) tree bounding box
	
	var xMin : Float;
	var yMin : Float;
	var xMax : Float;
	var yMax : Float;
	var area : Float;
	
	
	// ---- debug information
	
	#if RJTREE_DEBUG
	public var level( default, null ) : Int;
	#end
	
	
	// ---- construction
	
	public function new( ?bucketSize = 7, ?forcedReinsertion = true ) {
		this.bucketSize = bucketSize;
		this.forcedReinsertion = forcedReinsertion;
		
		entries = new EntryContainer();
		xMin = Math.POSITIVE_INFINITY;
		yMin = Math.POSITIVE_INFINITY;
		xMax = Math.NEGATIVE_INFINITY;
		yMax = Math.NEGATIVE_INFINITY;
		area = 0.;
		length = 0;
		#if RJTREE_DEBUG
		if ( null != parent )
			level = parent.level + 1;
		else
			level = 0;
		#end
	}
	
	inline static function child<A>( parent : RjTree<A> ) : RjTree<A> {
		var r = new RjTree( parent.bucketSize, parent.forcedReinsertion );
		r.parent = parent;
		return r;
	}
	
	
	// --- querying
	
	static inline function searchNode<A>( node : RjTree<A>, cache : List<A>, stack : List<RjTree<A>>, xMin : Float, yMin : Float, xMax : Float, yMax : Float ) : Void {
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
	
	static inline function searchStep<A>( cache : List<A>, stack : List<RjTree<A>>, minCacheSize : Int, xMin : Float, yMin : Float, xMax : Float, yMax : Float ) : Void {
		while ( minCacheSize > cache.length && !stack.isEmpty() )
			searchNode( stack.pop(), cache, stack, xMin, yMin, xMax, yMax );
	}
	
	public function search( xMin : Float, yMin : Float, xMax : Float, yMax : Float ) : Iterator<T> {
		var cache = new List();
		var stack = new List();
		
		stack.add( this );
		searchStep( cache, stack, 1, xMin, yMin, xMax, yMax );
		
		return {
			hasNext : function() { return !cache.isEmpty(); },
			next : function() { searchStep( cache, stack, 2, xMin, yMin, xMax, yMax ); return cache.pop(); }
		};
	}
	
	static inline function iterateNode<A>( node : RjTree<A>, cache : List<A>, stack : List<RjTree<A>> ) : Void {
		for ( ent in node.entries )
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
	
	static inline function iteratorStep<A>( cache : List<A>, stack : List<RjTree<A>>, minCacheSize : Int ) : Void {
		while ( minCacheSize > cache.length && !stack.isEmpty() )
			iterateNode( stack.pop(), cache, stack );
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
	
	inline function chooseEntryToInsert( xMin : Float, yMin : Float, xMax : Float, yMax : Float ) : Entry<T> {
		var bestEntry = Empty;
		var bestdA = Math.POSITIVE_INFINITY;
		for ( ent in entries ) {
			var da = switch ( ent ) {
				case Node( entChild ) :
					rectangleArea(
						Math.min( xMin, entChild.xMin ),
						Math.min( yMin, entChild.yMin ),
						Math.max( xMax, entChild.xMax ),
						Math.max( yMax, entChild.yMax )
					) - entChild.area;
				case LeafPoint( entObject, entX, entY ) :
					rectangleArea(
						Math.min( xMin, entX ),
						Math.min( yMin, entY ),
						Math.max( xMax, entX ),
						Math.max( yMax, entY )
					);
				case LeafRectangle( entObject, entX, entY, entWidth, entHeight ) :
					rectangleArea(
						Math.min( xMin, entX ),
						Math.min( yMin, entY ),
						Math.max( xMax, entX + entWidth ),
						Math.max( yMax, entY + entHeight )
					);
				default : throw 'Unexpected ' + ent;
			};
			if ( da < bestdA ) {
				bestdA = da;
				bestEntry = ent;
			}
		}
		return bestEntry;
	}
	
	function insertOnOverflow( ent : Entry<T>, reinsert : Bool ) : Void {
		var p = switch ( ent ) {
			case LeafPoint( entObject, entX, entY ) : chooseEntryToInsert( entX, entY, entX, entY ); 
			case LeafRectangle( entObject, entX, entY, entWidth, entHeight ) : chooseEntryToInsert( entX, entY, entX + entWidth, entY + entHeight );
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
				entries.remove( p );
				entries.push( Node( newChild ) );
				// insert the new leaf
				newChild.entries.push( ent );
				// insert the original leaf
				if ( reinsert )
					insertOnOverflow( p, false );
				else
					newChild.entries.push( p );
				newChild.computeBoundingBox();
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
			for ( ent in entries )
				switch ( ent ) {
					case Node( entChild ) : 
						removed += entChild.removePoint( x, y, object );
					case LeafPoint( entObject, entX, entY ) : 
						if ( entX == x && entY == y && ( null == object || entObject == object ) ) {
							entries.remove( ent );
							removed++;
							computeBoundingBox();
						}
					case LeafRectangle( entObject, entX, entY, entWidth, entHeight ) : // nothing to do
					default : throw 'Unexpected ' + ent;
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
			for ( ent in entries )
				switch ( ent ) {
					case Node( entChild ) : 
						removed += entChild.removeRectangle( x, y, width, height, object );
					case LeafRectangle( entObject, entX, entY, entWidth, entHeight ) : 
						if ( entX == x && entY == y && entWidth == width && height == height && ( null == object || entObject == object ) ) {
							entries.remove( ent );
							removed++;
							computeBoundingBox();
						}
					case LeafPoint( entObject, entX, entY ) : // nothing to do
					default : throw 'Unexpected ' + ent;
				}
		length -= removed;
		return removed;
	}
	
	public function removeObject( object : T ) : Int {
		var removed = 0;
		if ( entries.length > 0 )
			for ( ent in entries )
				switch ( ent ) {
					case Node( entChild ) : 
						removed += entChild.removeObject( object );
					case LeafPoint( entObject, entX, entY ) : 
						if ( entObject == object ) {
							entries.remove( ent );
							removed++;
							computeBoundingBox();
						}
					case LeafRectangle( entObject, entX, entY, entWidth, entHeight ) : 
						if ( entObject == object ) {
							entries.remove( ent );
							removed++;
							computeBoundingBox();
						}
					default : throw 'Unexpected ' + ent;
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
	
}

private enum Entry<T> {
	Node( child : RjTree<T> );
	LeafPoint( object : T, x : Float, y : Float );
	LeafRectangle( object : T, x : Float, y : Float, width : Float, height : Float );
	Empty;
}

private typedef EntryContainer<T> = Array<Entry<T>>;
