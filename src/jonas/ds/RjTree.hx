package jonas.ds;

import jonas.Maybe;

using Lambda;

/*
 * R-Tree variant 'j'.
 * Changes from the original R-Tree:
	 * - nodes may have simultaneously both node and object entries
	 * - no node splitting algorithm
	 * - forced 1-level reinsertion on node overflow (from R*-Tree)
 * 
 * Copyright (c) 2012 Jonas Malaco Filho
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

private typedef EntryContainer<A> = List<A>;
 
/**
 * RjTree node
 */
class RjTree<T> {
	
	// Tree size
	public var size(default, null) : Int;
	
	// If not root, parent tree
	var _parent : RjTree<T>;
	
	// Tree entries (up to maximum)
	var _entries : EntryContainer<RjEntry<T>>;

	// Maximum tree entries
	var _bucket_size : Int;
	static inline var DEFAULT_BUCKET_SIZE = 7;
	
	// Bounding-box
	var _xmin : Float;
	var _ymin : Float;
	var _xmax : Float;
	var _ymax : Float;
	var _area : Float;

	// Constructor
	// _parent should not be used outside of the class
	public function new( bucket_size = DEFAULT_BUCKET_SIZE, ?_parent : RjTree<T> ) {
		this._bucket_size = bucket_size;
		this._parent = _parent;
		_entries = new EntryContainer<RjEntry<T>>();
		_xmin = Math.POSITIVE_INFINITY;
		_ymin = Math.POSITIVE_INFINITY;
		_xmax = Math.NEGATIVE_INFINITY;
		_ymax = Math.NEGATIVE_INFINITY;
		_area = 0.;
		size = 0;
	}
	
	// Checks for overlapping point
	static inline function _overlapping_point( x : Float, y : Float, xmin : Float, ymin : Float, xmax : Float, ymax : Float ) : Bool {
		return x >= xmin && x <= xmax && y >= ymin && y <= ymax;
	}
	
	// Returns the area of a given bounding box
	static inline function _bounding_box_area( ax : Float, ay : Float, bx : Float, by : Float ) : Float {
		return ( bx - ax ) * ( by - ay );
	} // _bounding_box_area
	
	// Checks for overlapping rectangle
	inline function _overlapping_rectangle( xmin : Float, ymin : Float, xmax : Float, ymax : Float ) : Bool {
		return xmax >= _xmin && _xmax >= xmin && ymax >= _ymin && _ymax >= ymin;
	}
	
	// Internal rectangle search function
	// Uses the insertion function to produce the resultant Iterable
	// The insertion function is responsable for the side effects that
	// assemble the answer.
	function _search_rectangle( xmin : Float, ymin : Float, xmax : Float, ymax : Float, insertion : T -> Void ) : Void {
		if ( 0 < _entries.length && _overlapping_rectangle( xmin, ymin, xmax, ymax ) )
			_entries.iter( function( e : RjEntry<T> ) {
				switch ( e ) {
					case RjTreeNode( child ):
						child._search_rectangle( xmin, ymin, xmax, ymax, insertion );
					case RjLeafNode( element, x, y ):
						if ( _overlapping_point( x, y, xmin, ymin, xmax, ymax ) )
							insertion( element );
					default:
						throw "Unkown node type";
					}
			} );
	}
	
	// Default search for a rectangle, returns a List
	public function search_rectangle( xmin : Float, ymin : Float, xmax : Float, ymax : Float ) : List<T> {
		var ans = new List();
		_search_rectangle( xmin, ymin, xmax, ymax, function( elem : T ) {
			ans.add(elem);
		} );
		return ans;
	}
	
	// Flexible search for a rectangle
	// Answer is produced as a side-effect of the insertion function
	public function search_rectangleF( xmin : Float, ymin : Float, xmax : Float, ymax : Float, insertion : T -> Void ) : Void {
		_search_rectangle( xmin, ymin, xmax, ymax, insertion );
	}
	
	// Shrink boundaries
	function _shrink_boundaries() : Void {
		var xmin = Math.POSITIVE_INFINITY;
		var ymin = Math.POSITIVE_INFINITY;
		var xmax = Math.NEGATIVE_INFINITY;
		var ymax = Math.NEGATIVE_INFINITY;
		_entries.iter( function( e : RjEntry<T> ) {
			switch ( e ) {
				case RjTreeNode( child ):
					xmin = Math.min( xmin, child._xmin );
					ymin = Math.min( ymin, child._ymin );
					xmax = Math.max( xmax, child._xmax );
					ymax = Math.max( ymax, child._ymax );
				case RjLeafNode( element, x, y ):
					xmin = Math.min( xmin, x );
					ymin = Math.min( ymin, y );
					xmax = Math.max( xmax, x );
					ymax = Math.max( ymax, y );
				default:
					throw "Unkown node type";
			}
		} );
		var updated = false;
		var update = function( s, d ) {
			if ( d != s ) {
				d = s;
				updated = true;
			}
		};
		update( xmin, _xmin );
		update( ymin, _ymin );
		update( xmax, _xmax );
		update( ymax, _ymax );
		if ( null != _parent && updated )
			_parent._shrink_boundaries();
	}
	
	// Removes all objects that match the given (x, y)
	public function remove( x : Float, y : Float, ?elem : Null<T> ) : Void {
		if ( 0 < _entries.length && _overlapping_point( x, y, _xmin, _ymin, _xmax, _ymax ) ) {
			var e;
			for ( e in _entries ) {
				switch ( e )  {
					case RjTreeNode( child ):
						child.remove( x, y, elem );
					case RjLeafNode( element, ex, ey ):
						if ( ( null == elem && ex == x && ey == y ) || ( null != elem && element == elem ) ) {
							_entries.remove( e );
							_shrink_boundaries();
						}
					default:
						throw "Unkown node type";
				}
			}
		}
	}
	
	// Check for existance 
	public function exists( x : Float, y : Float ) : Bool {
		var e;
		if ( 0 < _entries.length && _overlapping_point( x, y, _xmin, _ymin, _xmax, _ymax ) ) {
			for ( e in _entries ) {
				switch ( e )  {
					case RjTreeNode( child ):
						if ( child.exists( x, y ) )
							return true;
					case RjLeafNode( element, ex, ey ):
						if ( ex == x && ey == y )
							return true;
					default:
						throw "Unkown node type";
				}
			}
		}
		return false;
	}
	
	// Search for exact element
	// If multiple matches exists, will return anyone of them
	public function search_element( x : Float, y : Float ) : Maybe<T> {
		var e;
		if ( 0 < _entries.length && _overlapping_point( x, y, _xmin, _ymin, _xmax, _ymax ) ) {
			for ( e in _entries ) {
				switch ( e ) {
					case RjTreeNode( child ):
						var c = child.search_element( x, y );
						if ( empty != c )
							return c;
					case RjLeafNode( element, ex, ey ):
						if ( ex == x && ey == y )
							return just( element );
					default:
						throw "Unkown node type";
				}
			}
		}
		return empty;
	}
	
	public function all() : List<T> {
		var a = new List();
		search_rectangleF( _xmin, _ymin, _xmax, _ymax, function( o : T ) { a.add( o ); } );
		return a;
	}
	
	// Expand boundaries to accommodate a given bounding box
	function _expand_boundaries( xmin : Float, ymin : Float, xmax : Float, ymax : Float ) : Void {
		var updated = false;
		if ( xmin <= _xmin ) {
			_xmin = xmin;
			updated = true;
		}
		if ( ymin <= _ymin ) {
			_ymin = ymin;
			updated = true;
		}
		if ( xmax >= _xmax ) {
			_xmax = xmax;
			updated = true;
		}
		if ( ymax >= _ymax ) {
			_ymax = ymax;
			updated = true;
		}
		_area = _bounding_box_area( _xmin, _ymin, _xmax, _ymax );
		if ( null != _parent && updated )
			_parent._expand_boundaries( _xmin, _ymin, _xmax, _ymax );
	}

	// Choose where to insert an object
	function _choose_RjEntry( x : Float, y : Float ) : RjEntry<T> {
		var best_RjEntry = RjEmptyNode;
		var best_da = Math.POSITIVE_INFINITY;
		_entries.iter( function( e : RjEntry<T> ) {
			var da = Math.POSITIVE_INFINITY; // area increment
			switch ( e ) {
				
				case RjTreeNode( child ):
					da = _bounding_box_area( Math.min( x, child._xmin ), Math.min( y, child._ymin ), Math.max( x, child._xmax ), Math.max( y, child._ymax ) ) - child._area;
				
				case RjLeafNode(element, ex, ey):
					da = _bounding_box_area( Math.min( x, ex ), Math.min( y, ey ), Math.max( x, ex ), Math.max( y, ey ) );
				
				default:
					throw "Unkown node type";
				
			}
			if ( da < best_da ) {
				best_da = da;
				best_RjEntry = e;
			}
		} );
		return best_RjEntry;
	}
	
	// Insertion when node overflows
	function _inserting_on_overflow( element : T, x : Float, y : Float, reinsert : Bool ) : Void {
		var p = _choose_RjEntry( x, y ); // best entry
		switch ( p ) {
			
			case RjTreeNode( child ):
				child.insert( element, x, y ); // propagate...
			
			case RjLeafNode( elem, ex, ey ): // will split it...
				var new_child = new RjTree( _bucket_size, this );
				new_child._entries.push( RjLeafNode( element, x, y ) ); // new node first; simple insertion minus _expand_boundaries
				_entries.remove( p );
				_entries.push( RjTreeNode( new_child ) );
				// now the splited node
				if ( reinsert )
					_inserting_on_overflow( elem, ex, ey, false ); // splited node
				else
					new_child._entries.push( RjLeafNode( elem, ex, ey ) ); // splited node
				new_child._expand_boundaries( Math.min( x, ex ), Math.min( y, ey ), Math.max( x, ex ), Math.max( y, ey ) );
			
			default:
				throw "Unkown node type";
			
		}
	}
	
	// Object insertion
	public function insert( element : T, x : Float, y : Float ) : Void {
		if ( _bucket_size > _entries.length ) {
			// pushing an RjEntry
			_entries.push( RjLeafNode( element, x, y ) );
			_expand_boundaries( x, y, x, y );
		}
		else {
			// maximum number of entries per node reached
			// spliting an RjEntry
			_inserting_on_overflow( element, x, y, true );
		}
		size++;
	}
	
	// Clears all references to allow the garbage collector to work properly
	public function destroy() {
		_entries.iter( function( e : RjEntry<T> ) {
			switch ( e ) {
			  case RjTreeNode( child ):
				  child.destroy();
			  default:
				  //just ignore
			}
		} );
		_parent = null;
		_entries = null;
	}
	
	// Returns the maximum depth of the tree
	public function analysis_maximum_depth() : Int {
		var max_depth = 0;
		_entries.iter( function( e : RjEntry<T> ) {
			switch ( e ) {
				case RjTreeNode( child ):
					var depth = child.analysis_maximum_depth() + 1;
					max_depth = ( depth > max_depth ) ? depth : max_depth;
				default:
					//just ignore
			}
		} );
		return max_depth;
	}
	
	// Returns the number of non RjLeafNode nodes
	public function analysis_count_non_leaf() : Int {
		var cnt = 0;
		_entries.iter( function( e : RjEntry<T> ) {
			switch ( e ) {
				case RjTreeNode(child):
					cnt += child.analysis_count_non_leaf() + 1;
				default:
					//just ignore
			}
		} );
		return cnt;
	}
	
	// Returns the load factor, ie, size to avaliable entries ratio
	public function analysis_load_factor() : Float {
		//return size / Math.pow(_bucket_size, analysis_maximum_depth() + 1);
		return size / analysis_count_non_leaf() / _bucket_size ;
	}
	
#if debug
	
	// Verify tree consistency
	public function verify() : Bool {
		for (e in _entries) {
			switch ( e )  {
			  case RjTreeNode( child ):
				  if ( !child.verify() || child._xmin < _xmin || child._xmax > _xmax || child._ymin < _ymin || child._ymax > _ymax )
					return false;
			  case RjLeafNode( element, x, y ):
				  if ( x < _xmin || x > _xmax || y < _ymin || y > _ymax )
					return false;
			  default:
				  throw "Unkown node type";
			}
	    }
		return true;
	}
	
#end
	
}

// RjEntry enumeration
enum RjEntry<T> {
	RjTreeNode( child : RjTree<T> );
	RjLeafNode( element : T, x : Float, y : Float );
	RjEmptyNode;
}