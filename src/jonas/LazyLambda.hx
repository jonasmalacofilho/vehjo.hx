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

	TODO:
	- first: ExprOf<Iterator<A>> -> ExprOf<A>
	- pair: ExprOf<Iterator<A>> -> ExprOF<Iterator<B>> -> ExprOf<Iterator<C>>

	Copyright 2012 Jonas Malaco Filho. Licensed under the MIT License. 
**/
class LazyLambda {

	/**
		Creates an array from a collection
	**/
	public static inline function array<A>( it: Iterable<A> ): Array<A> {
		return fold( it, { $pre.push( $x ); $pre; }, [] );
	}

	/**
		Concatenates two collections
	**/
	@:macro public static function concat<A>( it1: ExprOf<Iterable<A>>, it2: ExprOf<Iterable<A>> ): ExprOf<Iterable<A>> {
		var itr2 = getIterator( it2 );
		var itr1 = getIterator( it1 );
		return buildIterable( macro {
			var __lazy_lambda__nxit = $itr2;
			var __lazy_lambda__fsit = $itr1;
			{
				hasNext: function () {
					if ( __lazy_lambda__fsit.hasNext() )
						return true;
					else if ( __lazy_lambda__nxit != null ) {
						__lazy_lambda__fsit = __lazy_lambda__nxit;
						__lazy_lambda__nxit = null;
						return __lazy_lambda__fsit.hasNext();
					}
					else
						return false;
				},
				next: function () return __lazy_lambda__fsit.next()
			};
		} ).changePos( it1.pos );
	}

	/**
		Force a lazy concat of an Array with some other Iterable when using "using"
	**/
	public static inline function lazyConcat<A>( a1: Array<A>, a2: Iterable<A> ): Iterable<A> {
		return concat( a1, a2 );
	}

	/**
		Counts the total number of elements in a collection
	**/
	public static inline function count<A>( it: Iterable<A> ): Int {
		return fold( it, $pre + 1, 0 );
	}

	/**
		Tells if a collection does not contain any elements
	**/
	public static inline function empty<A>( it: Iterable<A> ): Bool {
		return it.iterator().hasNext();
	}

	/**
		Filters a collection using the supplied expression "filter" 
		Exposed variables: $x (element) and $i (element index)
	**/
	@:macro public static function filter<A>( it: ExprOf<Iterable<A>>, filter: ExprOf<Bool> ): ExprOf<Iterable<A>> {
		var inspect = inspectIdentifiers( filter );
		filter = inspect.uExpr;
		var exposedIndex = false;
		for ( x in inspect.found )
			switch ( x ) {
				case IINDEX: exposedIndex = true;
			}
		var itr = getIterator( it );
		if ( exposedIndex )
			return buildIterable( macro {
				var __lazy_lambda__it = $itr;
				var __lazy_lambda__nx = null;
				var __lazy_lambda__i = 0;
				{
					hasNext: function () {
						while ( __lazy_lambda__nx == null && __lazy_lambda__it.hasNext() ) {
							var __lazy_lambda__x = __lazy_lambda__it.next();
							if ( $filter ) {
								__lazy_lambda__nx = __lazy_lambda__x;
								__lazy_lambda__i++;
								return true;
							}
							__lazy_lambda__i++;
						}
						return __lazy_lambda__nx != null;
					},
					next: function () {
						var next = __lazy_lambda__nx;
						__lazy_lambda__nx = null;
						return next;
					}
				};
			} ).changePos( it.pos );
		else
			return buildIterable( macro {
				var __lazy_lambda__it = $itr;
				var __lazy_lambda__nx = null;
				{
					hasNext: function () {
						while ( __lazy_lambda__nx == null && __lazy_lambda__it.hasNext() ) {
							var __lazy_lambda__x = __lazy_lambda__it.next();
							if ( $filter ) {
								__lazy_lambda__nx = __lazy_lambda__x;
								return true;
							}
						}
						return __lazy_lambda__nx != null;
					},
					next: function () {
						var next = __lazy_lambda__nx;
						__lazy_lambda__nx = null;
						return next;
					}
				};
			} ).changePos( it.pos );
	}

	/**
		Returns the first element in a collection that matches the expression "cond"
		Exposed variables: $x (element) and $i (element index)
	**/
	@:macro public static function find<A>( it: ExprOf<Iterable<A>>, cond: ExprOf<Bool> ): ExprOf<Null<Int>> {
		var inspect = inspectIdentifiers( cond );
		cond = inspect.uExpr;
		var exposedIndex = false;
		for ( x in inspect.found )
			switch ( x ) {
				case IINDEX: exposedIndex = true;
			}

		if ( exposedIndex )
			return fixThis( macro {
				var __lazy_lambda__i = 0;
				var __lazy_lambda__ret = null;
				for ( __lazy_lambda__x in $it.iterator() ) {
					if ( $cond ) {
						__lazy_lambda__ret = __lazy_lambda__x;
						break;
					}
					__lazy_lambda__i++;
				}
				__lazy_lambda__ret;
			} ).changePos( it.pos );
		else
			return fixThis( macro {
				var __lazy_lambda__ret = null;
				for ( __lazy_lambda__x in $it.iterator() ) {
					if ( $cond ) {
						__lazy_lambda__ret = __lazy_lambda__x;
						break;
					}
				}
				__lazy_lambda__ret;
			} ).changePos( it.pos );
	}

	/**
		Functional fold
		Exposed variables: $pre (previous return value), $x (element) and $i (element index)
	**/
	@:macro public static function fold<A,B>( it: ExprOf<Iterable<A>>, fold: ExprOf<B>, first: ExprOf<B> ): ExprOf<B> {
		var inspect = inspectIdentifiers( fold );
		fold = inspect.uExpr;
		var exposedIndex = false;
		for ( x in inspect.found )
			switch ( x ) {
				case IINDEX: exposedIndex = true;
			}

		if ( exposedIndex )
			return fixThis( macro {
				var __lazy_lambda__pre = $first;
				var __lazy_lambda__i = 0;
				for ( __lazy_lambda__x in $it.iterator() ) {
					__lazy_lambda__pre = $fold;
					__lazy_lambda__i++;
				}
				__lazy_lambda__pre;
			} ).changePos( it.pos );
		else
			return fixThis( macro {
				var __lazy_lambda__pre = $first;
				for ( __lazy_lambda__x in $it.iterator() ) {
					__lazy_lambda__pre = $fold;
				}
				__lazy_lambda__pre;
			} ).changePos( it.pos );
	}
	
	@:macro public static function hash<A>( it: ExprOf<Iterable<A>>, key: ExprOf<String> ): ExprOf<Hash<A>> {
		var inspect = inspectIdentifiers( key );
		key = inspect.uExpr;
		var exposedIndex = false;
		for ( x in inspect.found )
			switch ( x ) {
				case IINDEX: exposedIndex = true;
			}

		if ( exposedIndex )
			return fixThis( macro {
				var __lazy_lambda__ret = new Hash();
				var __lazy_lambda__i = 0;
				for ( __lazy_lambda__x in $it.iterator() ) {
					__lazy_lambda__ret.set( $key, __lazy_lambda__x );
					__lazy_lambda__i++;
				}
				__lazy_lambda__ret;
			} ).changePos( it.pos );
		else
			return fixThis( macro {
				var __lazy_lambda__ret = new Hash();
				for ( __lazy_lambda__x in $it.iterator() ) {
					__lazy_lambda__ret.set( $key, __lazy_lambda__x );
				}
				__lazy_lambda__ret;
			} ).changePos( it.pos );
	}

	@:macro public static function intHash<A>( it: ExprOf<Iterable<A>>, key: ExprOf<Int> ): ExprOf<IntHash<A>> {
		var inspect = inspectIdentifiers( key );
		key = inspect.uExpr;
		var exposedIndex = false;
		for ( x in inspect.found )
			switch ( x ) {
				case IINDEX: exposedIndex = true;
			}

		if ( exposedIndex )
			return fixThis( macro {
				var __lazy_lambda__ret = new IntHash();
				var __lazy_lambda__i = 0;
				for ( __lazy_lambda__x in $it.iterator() ) {
					__lazy_lambda__ret.set( $key, __lazy_lambda__x );
					__lazy_lambda__i++;
				}
				__lazy_lambda__ret;
			} ).changePos( it.pos );
		else
			return fixThis( macro {
				var __lazy_lambda__ret = new IntHash();
				for ( __lazy_lambda__x in $it.iterator() ) {
					__lazy_lambda__ret.set( $key, __lazy_lambda__x );
				}
				__lazy_lambda__ret;
			} ).changePos( it.pos );
	}

	/**
		Tells if the expression "cond" evaluates to true for ALL elements in a collection
		Exposed variables: $x (element) and $i (element index)
	**/
	@:macro public static function holds<A>( it: ExprOf<Iterable<A>>, cond: ExprOf<Bool> ): ExprOf<Bool> {
		var inspect = inspectIdentifiers( cond );
		cond = inspect.uExpr;
		var exposedIndex = false;
		for ( x in inspect.found )
			switch ( x ) {
				case IINDEX: exposedIndex = true;
			}

		if ( exposedIndex )
			return fixThis( macro {
				var __lazy_lambda__ret = true;
				var __lazy_lambda__i = 0;
				for ( __lazy_lambda__x in $it.iterator() ) {
					if ( !$cond ) {
						__lazy_lambda__ret = false;
						break;
					}
					__lazy_lambda__i++;
				}
				__lazy_lambda__ret;
			} ).changePos( it.pos );
		else
			return fixThis( macro {
				var __lazy_lambda__ret = true;
				for ( __lazy_lambda__x in $it.iterator() ) {
					if ( !$cond ) {
						__lazy_lambda__ret = false;
						break;
					}
				}
				__lazy_lambda__ret;
			} ).changePos( it.pos );
	}

	/**
		Tells if the expression "cond" evaluates to true for AT LEAST ONE element in a collection
		Exposed variables: $x (element) and $i (element index)
	**/
	@:macro public static function holdsOnce<A>( it: ExprOf<Iterable<A>>, cond: ExprOf<Bool> ): ExprOf<Bool> {
		var inspect = inspectIdentifiers( cond );
		cond = inspect.uExpr;
		var exposedIndex = false;
		for ( x in inspect.found )
			switch ( x ) {
				case IINDEX: exposedIndex = true;
			}

		if ( exposedIndex )
			return fixThis( macro {
				var __lazy_lambda__ret = false;
				var __lazy_lambda__i = 0;
				for ( __lazy_lambda__x in $it.iterator() ) {
					if ( $cond ) {
						__lazy_lambda__ret = true;
						break;
					}
					__lazy_lambda__i++;
				}
				__lazy_lambda__ret;
			} ).changePos( it.pos );
		else
			return fixThis( macro {
				var __lazy_lambda__ret = false;
				for ( __lazy_lambda__x in $it.iterator() ) {
					if ( $cond ) {
						__lazy_lambda__ret = true;
						break;
					}
				}
				__lazy_lambda__ret;
			} ).changePos( it.pos );
	}

	/**
		Returns the index of the first element in a collection that matches the expression "cond"
		Exposed variables: $x (element) and $i (element index)
	**/
	@:macro public static function indexOf<A>( it: ExprOf<Iterable<A>>, cond: ExprOf<Bool> ): ExprOf<Int> {
		var inspect = inspectIdentifiers( cond );
		cond = inspect.uExpr;

		return fixThis( macro {
			var __lazy_lambda__i = 0;
			var __lazy_lambda__ret = -1;
			for ( __lazy_lambda__x in $it.iterator() ) {
				if ( $cond ) {
					__lazy_lambda__ret = __lazy_lambda__i;
					break;
				}
				__lazy_lambda__i++;
			}
			__lazy_lambda__ret;
		} ).changePos( it.pos );
	}

	/**
		Executes the expression "expr" for each element in a collection
		Exposed variables: $x (element) and $i (element index)
	**/
	@:macro public static function iter<A>( it: ExprOf<Iterable<A>>, expr ): ExprOf<Void> {
		var inspect = inspectIdentifiers( expr );
		expr = inspect.uExpr;
		var exposedIndex = false;
		for ( x in inspect.found )
			switch ( x ) {
				case IINDEX: exposedIndex = true;
			}

		if ( exposedIndex )
			return fixThis( macro {
				var __lazy_lambda__i = 0;
				for ( __lazy_lambda__x in $it.iterator() ) {
					$expr;
					__lazy_lambda__i++;
				}
				null;
			} ).changePos( it.pos );
		else
			return fixThis( macro {
				for ( __lazy_lambda__x in $it.iterator() )
					$expr;
				null;
			} ).changePos( it.pos );
	}

	/**
		Transforms an iterator into a lazy iterable
		Behare of side-effects on the expression "it"
	**/
	@:macro public static function lazy<A>( it: ExprOf<Iterator<A>> ): ExprOf<Iterable<A>> {
		return fixThis( macro {
			{ iterator: function () return $it };
		} ).changePos( it.pos );
	}

	/**
		Creates a list from a collection
	**/
	public static inline function list<A>( it: Iterable<A> ): List<A> {
		return fold( it, { $pre.add( $x ); $pre; }, new List<A>() );
	}

	/**
		Maps every element in a colletion into a new element, using the expression "map"
		Exposed variables: $x (element) and $i (element index)
	**/
	@:macro public static function map<A,B>( it: ExprOf<Iterable<A>>, map: ExprOf<B> ): ExprOf<Iterable<B>> {
		var inspect = inspectIdentifiers( map );
		map = inspect.uExpr;
		var exposedIndex = false;
		for ( x in inspect.found )
			switch ( x ) {
				case IINDEX: exposedIndex = true;
			}
		var itr = getIterator( it );
		if ( exposedIndex )
			return buildIterable( macro {
				var __lazy_lambda__it = $itr;
				var __lazy_lambda__i = 0;
				{
					hasNext: __lazy_lambda__it.hasNext,
					next: function () {
						var __lazy_lambda__x = __lazy_lambda__it.next();
						var __lazy_lambda__ret = $map;
						__lazy_lambda__i++;
						return __lazy_lambda__ret;
					}
				};
			} ).changePos( it.pos );
		else
			return buildIterable( macro {
				var __lazy_lambda__it = $itr;
				{
					hasNext: __lazy_lambda__it.hasNext,
					next: function () {
						var __lazy_lambda__x = __lazy_lambda__it.next();
						return $map;
					}
				};
			} ).changePos( it.pos );
	}

#if macro

	static inline var IINDEX = '$i';
	static inline var IELEMENT = '$x';
	static inline var IPREVALUE = '$pre';

	static function inspectIdentifiers( expr: Expr ): { uExpr: Expr, found: Array<String> } {
		var found = [];
		var uExpr = expr.transform( function ( x ) {
			return switch ( x.expr ) {
				case EConst( c ):
					switch ( c ) {
						case CIdent( s ):
							switch ( s ) {
								case IINDEX, IELEMENT, IPREVALUE:
									found.remove( s );
									found.push( s );
									EConst( CIdent( '__lazy_lambda__' + s.substr( 1 ) ) ).make();
								default:
									x;
							};
						default: x;
					};
				default: x;
			};
		} );
		return { uExpr: uExpr, found: found };
	}

	static function buildIterable<A>( x: ExprOf<Iterator<A>> ): ExprOf<Iterable<A>> {
		return fixThis( macro { iterator: function () return $x } );
	}

	static function fixThis( x: Expr ): Expr {
		trace( x.pos );
		trace( x.toString() );
		return ExprTools.transform( x, function ( x ) {
			return switch ( x.expr ) {
				case EConst( c ):
					switch ( c ) {
						case CIdent( s ):
							if ( s=='`' ) {
								EConst( CIdent( 'this' ) ).make();
							}
							else {
								x;
							}
						default: x;
					};
				default: x;
			};
		} );
	}

	static function getIterator<A>( x: ExprOf<Iterable<A>> ): ExprOf<Iterator<A>> {
		return ECall( EField( x, 'iterator' ).make(), [] ).make();
	}

#end

}