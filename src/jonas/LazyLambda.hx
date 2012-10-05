package jonas;

#if macro
import haxe.macro.Expr;
using jonas.macro.ExprTools;
#end

/**
	Lazy version of the Lambda class
	- lazy evaluation: receives and returns iterators, not iterables
	- receives expressions (more compact), not functions

	Functions that return a single value (and not a collection of values) are just
	macro equivalents to the ones in the original Lambda class.

	TODO: support both Iterable<A> and Iterator<A> as arguments

	Copyright 2012 Jonas Malaco Filho. Licensed under the MIT License. 
**/
class LazyLambda {

	/**
		Creates an array from a collection
	**/
	@:macro public static function array<A>( it: ExprOf<Iterator<A>> ): ExprOf<Array<A>> {
		return macro {
			var y = [];
			for ( x in $it )
				y.push( x );
			y;
		};
	}

	/**
		Concatenates both collections
	**/
	@:macro public static function concat<A>( it1: ExprOf<Iterator<A>>, it2: ExprOf<Iterator<A>> ): ExprOf<Iterator<A>> {
		return macro {
			var nxit = $it2;
			var it = $it1;
			{
				hasNext: function () {
					if ( it.hasNext() )
						return true;
					else if ( nxit != null ) {
						it = nxit;
						nxit = null;
						return it.hasNext();
					}
					else
						return false;
				},
				next: function () return it.next()
			}
		};
	}

	/**
		Counts the total number of elements in a collection
	**/
	@:macro public static function count<A>( it: ExprOf<Iterator<A>> ): ExprOf<Int> {
		return macro {
			var i = 0;
			for ( x in $it )
				i++;
			i;
		};
	}

	/**
		Tells if a collection does not contain any elements
	**/
	@:macro public static function empty<A>( it: ExprOf<Iterator<A>> ): ExprOf<Bool> {
		return macro {
			!$it.hasNext();
		};
	}

	/**
		Tells if at least one element in a collection matches the expression "cond"
		$x: A      element of it
	**/
	@:macro public static function exists<A>( it: ExprOf<Iterator<A>>, cond: ExprOf<Bool> ): ExprOf<Bool> {
		var filterExpr = cond.transform( function ( x ) {
			return switch ( x.expr ) {
				case EConst( c ):
					switch ( c ) {
						case CIdent( s ):
							switch ( s ) {
								case '$x': EConst( CIdent( 'x' ) ).make();
								default: x;
							}
						default: x;
					};
				default: x;
			}
		} ); 
		return macro {
			var ret = false;
			for ( x in $it )
				if ( $filterExpr ) {
					ret = true;
					break;
				}
			ret;
		};
	}

	/**
		Filters a collection using the supplied expression "filter" 
		$x: A      element of it
	**/
	@:macro public static function filter<A>( it: ExprOf<Iterator<A>>, filter: ExprOf<Bool> ): ExprOf<Iterator<A>> {
		var filterExpr = filter.transform( function ( x ) {
			return switch ( x.expr ) {
				case EConst( c ):
					switch ( c ) {
						case CIdent( s ):
							switch ( s ) {
								case '$x': EConst( CIdent( 'next' ) ).make();
								default: x;
							}
						default: x;
					};
				default: x;
			}
		} ); 
		return macro {
			var it = $it;
			var nx = null;
			{
				hasNext: function () {
					var next = null;
					while ( it.hasNext() && next == null ) {
						var next = it.next();
						if ( $filterExpr ) {
							nx = next;
							return true;
						}
					}
					return false;
				},
				next: function () return nx
			}
		};
	}

	/**
		Functional fold
		$x: A      element of it
		$pre:    previous value
	**/
	@:macro public static function fold<A,B>( it: ExprOf<Iterator<A>>, fold: ExprOf<B>, first: ExprOf<B> ): ExprOf<B> {
		var foldExpr = fold.transform( function ( x ) {
			return switch ( x.expr ) {
				case EConst( c ):
					switch ( c ) {
						case CIdent( s ):
							switch ( s ) {
								case '$x': EConst( CIdent( 'x' ) ).make();
								case '$pre' : EConst( CIdent( 'pre' ) ).make();
								default: x;
							}
						default: x;
					};
				default: x;
			}
		} ); 
		return macro {
			var pre = $first;
			for ( x in $it )
				pre = $foldExpr;
			pre;
		};
	}
	
	/**
		Tells if at all elements in a collection match the expression "cond"
		$x: A      element of it
	**/
	@:macro public static function foreach<A>( it: ExprOf<Iterator<A>>, cond: ExprOf<Bool> ): ExprOf<Bool> {
		var filterExpr = cond.transform( function ( x ) {
			return switch ( x.expr ) {
				case EConst( c ):
					switch ( c ) {
						case CIdent( s ):
							switch ( s ) {
								case '$x': EConst( CIdent( 'x' ) ).make();
								default: x;
							}
						default: x;
					};
				default: x;
			}
		} ); 
		return macro {
			var ret = true;
			for ( x in $it )
				if ( !$filterExpr ) {
					ret = false;
					break;
				}
			ret;
		};
	}

	/**
		Returns the index of the first element in a collection that matches the expression "cond"
		$x: A      element of it
	**/
	@:macro public static function indexOf<A>( it: ExprOf<Iterator<A>>, cond: ExprOf<Bool> ): ExprOf<Int> {
		var filterExpr = cond.transform( function ( x ) {
			return switch ( x.expr ) {
				case EConst( c ):
					switch ( c ) {
						case CIdent( s ):
							switch ( s ) {
								case '$x': EConst( CIdent( 'x' ) ).make();
								default: x;
							}
						default: x;
					};
				default: x;
			}
		} ); 
		return macro {
			var i = -1;
			var ret = i;
			for ( x in $it ) {
				i++;
				if ( $filterExpr ) {
					ret = i;
					break;
				}
			}
			ret;
		};
	}

	/**
		Executes the expression "expr" for each element in a collection
		$x: A      element of it
	**/
	@:macro public static function iter<A>( it: ExprOf<Iterator<A>>, expr: ExprOf<Bool> ): ExprOf<Int> {
		var execExpr = expr.transform( function ( x ) {
			return switch ( x.expr ) {
				case EConst( c ):
					switch ( c ) {
						case CIdent( s ):
							switch ( s ) {
								case '$x': EConst( CIdent( 'x' ) ).make();
								default: x;
							}
						default: x;
					};
				default: x;
			}
		} ); 
		return macro {
			for ( x in $it )
				$execExpr;
		};
	}

	/**
		Creates a list from a collection
	**/
	@:macro public static function list<A>( it: ExprOf<Iterator<A>> ): ExprOf<List<A>> {
		return macro {
			var y = new List();
			for ( x in $it )
				y.add( x );
			y;
		};
	}

	/**
		Maps every element in a colletion into a new element, using the function "map"
		$x: A      element of it
	**/
	@:macro public static function map<A,B>( it: ExprOf<Iterator<A>>, map: ExprOf<B> ): ExprOf<Iterator<B>> {
		var mapExpr = map.transform( function ( x ) {
			return switch ( x.expr ) {
				case EConst( c ):
					switch ( c ) {
						case CIdent( s ):
							switch ( s ) {
								case '$x': EConst( CIdent( 'next' ) ).make();
								default: x;
							}
						default: x;
					};
				default: x;
			}
		} ); 
		return macro {
			var it = $it;
			{
				hasNext: it.hasNext,
				next: function () {
					var next = it.next();
					return $mapExpr;
				}
			}
		};
	}

	/**
		Maps every element in a colletion into a new element, using the function "map"
		The difference between mapi and map is that mapi also exposes the element index (0 based)
		$x: A      element of it
		$i: Int    index for element $x
	**/
	@:macro public static function mapi<A,B>( it: ExprOf<Iterator<A>>, map: ExprOf<B> ): ExprOf<Iterator<B>> {
		var mapExpr = map.transform( function ( x ) {
			return switch ( x.expr ) {
				case EConst( c ):
					switch ( c ) {
						case CIdent( s ):
							switch ( s ) {
								case '$x': EConst( CIdent( 'next' ) ).make();
								case '$i' : EConst( CIdent( 'i' ) ).make();
								default: x;
							}
						default: x;
					};
				default: x;
			}
		} ); 
		return macro {
			var it = $it;
			var i = 0;
			{
				hasNext: it.hasNext,
				next: function () {
					var next = it.next();
					var ret = $mapExpr;
					i++;
					return ret;
				}
			}
		};
	}

}