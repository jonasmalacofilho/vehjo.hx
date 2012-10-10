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
	- hash: ? -> ExprOf<Hash<A>>
	- intHash: ? -> ExprOf<IntHash<A>>
	- pair: ExprOf<Iterator<A>> -> ExprOF<Iterator<B>> -> ExprOf<Iterator<C>>

	Copyright 2012 Jonas Malaco Filho. Licensed under the MIT License. 
**/
class LazyLambda {

	/**
		Creates an array from a collection
	**/
	public static function array<A>( it: Iterable<A> ): Array<A> {
		return fold( it, { $pre.push( $x ); $pre; }, [] );
	}

	/**
		Concatenates two collections
	**/
	@:macro public static function concat<A>( it1: ExprOf<Iterable<A>>, it2: ExprOf<Iterable<A>> ): ExprOf<Iterable<A>> {
		return buildIterable( macro {
			var nxit = $it2.iterator();
			var fsit = $it1.iterator();
			{
				hasNext: function () {
					if ( fsit.hasNext() )
						return true;
					else if ( nxit != null ) {
						fsit = nxit;
						nxit = null;
						return fsit.hasNext();
					}
					else
						return false;
				},
				next: function () return fsit.next()
			};
		} );
	}

	/**
		Counts the total number of elements in a collection
	**/
	public static function count<A>( it: Iterable<A> ): Int {
		return fold( it, $pre + 1, 0 );
	}

	/**
		Tells if a collection does not contain any elements
	**/
	public static function empty<A>( it: Iterable<A> ): Bool {
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

		if ( exposedIndex )
			return buildIterable( macro {
				var it = $it.iterator();
				var nx = null;
				var __lazylambda__i = 0;
				{
					hasNext: function () {
						while ( nx == null && it.hasNext() ) {
							var __lazylambda__x = it.next();
							if ( $filter ) {
								nx = __lazylambda__x;
								__lazylambda__i++;
								return true;
							}
							__lazylambda__i++;
						}
						return nx != null;
					},
					next: function () {
						var next = nx;
						nx = null;
						return next;
					}
				};
			} );
		else
			return buildIterable( macro {
				var it = $it.iterator();
				var nx = null;
				{
					hasNext: function () {
						while ( nx == null && it.hasNext() ) {
							var __lazylambda__x = it.next();
							if ( $filter ) {
								nx = __lazylambda__x;
								return true;
							}
						}
						return nx != null;
					},
					next: function () {
						var next = nx;
						nx = null;
						return next;
					}
				};
			} );
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
				var __lazylambda__i = 0;
				var ret = null;
				for ( __lazylambda__x in $it ) {
					if ( $cond ) {
						ret = __lazylambda__x;
						break;
					}
					__lazylambda__i++;
				}
				ret;
			} );
		else
			return fixThis( macro {
				var ret = null;
				for ( __lazylambda__x in $it ) {
					if ( $cond ) {
						ret = __lazylambda__x;
						break;
					}
				}
				ret;
			} );
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
				var __lazylambda__pre = $first;
				var __lazylambda__i = 0;
				for ( __lazylambda__x in $it ) {
					__lazylambda__pre = $fold;
					__lazylambda__i++;
				}
				__lazylambda__pre;
			} );
		else
			return fixThis( macro {
				var __lazylambda__pre = $first;
				for ( __lazylambda__x in $it ) {
					__lazylambda__pre = $fold;
				}
				__lazylambda__pre;
			} );
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
				var ret = true;
				var __lazylambda__i = 0;
				for ( __lazylambda__x in $it ) {
					if ( !$cond ) {
						ret = false;
						break;
					}
					__lazylambda__i++;
				}
				ret;
			} );
		else
			return fixThis( macro {
				var ret = true;
				for ( __lazylambda__x in $it ) {
					if ( !$cond ) {
						ret = false;
						break;
					}
				}
				ret;
			} );
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
				var ret = false;
				var __lazylambda__i = 0;
				for ( __lazylambda__x in $it ) {
					if ( $cond ) {
						ret = true;
						break;
					}
					__lazylambda__i++;
				}
				ret;
			} );
		else
			return fixThis( macro {
				var ret = false;
				for ( __lazylambda__x in $it ) {
					if ( $cond ) {
						ret = true;
						break;
					}
				}
				ret;
			} );
	}

	/**
		Returns the index of the first element in a collection that matches the expression "cond"
		Exposed variables: $x (element) and $i (element index)
	**/
	@:macro public static function indexOf<A>( it: ExprOf<Iterable<A>>, cond: ExprOf<Bool> ): ExprOf<Int> {
		var inspect = inspectIdentifiers( cond );
		cond = inspect.uExpr;

		return fixThis( macro {
			var __lazylambda__i = 0;
			var ret = -1;
			for ( __lazylambda__x in $it ) {
				if ( $cond ) {
					ret = __lazylambda__i;
					break;
				}
				__lazylambda__i++;
			}
			ret;
		} );
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
				var __lazylambda__i = 0;
				for ( __lazylambda__x in $it ) {
					$expr;
					__lazylambda__i++;
				}
				null;
			} );
		else
			return fixThis( macro {
				for ( __lazylambda__x in $it )
					$expr;
				null;
			} );
	}

	/**
		Transforms an iterator into a lazy iterable
		Behare of side-effects on the expression "it"
	**/
	@:macro public static function lazy<A>( it: ExprOf<Iterator<A>> ): ExprOf<Iterable<A>> {
		return fixThis( macro {
			{ iterator: function () return $it };
		} );
	}

	/**
		Creates a list from a collection
	**/
	public static function list<A>( it: Iterable<A> ): List<A> {
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
		// trace(
		// 	buildIterable( macro {
		// 		var it = $itr;
		// 		{
		// 			hasNext: it.hasNext,
		// 			next: function () {
		// 				var __lazylambda__x = it.next();
		// 				return $map;
		// 			}
		// 		};
		// 	} ).toString()
		// );
		if ( exposedIndex )
			return buildIterable( macro {
				var it = $itr;
				var __lazylambda__i = 0;
				{
					hasNext: it.hasNext,
					next: function () {
						var __lazylambda__x = it.next();
						var ret = $map;
						__lazylambda__i++;
						return ret;
					}
				};
			} );
		else
			return buildIterable( macro {
				var it = $itr;
				{
					hasNext: it.hasNext,
					next: function () {
						var __lazylambda__x = it.next();
						return $map;
					}
				};
			} );
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
							if ( s.length>=1 && s.charAt( 0 )=='$' ) {
								found.remove( s );
								found.push( s );
								EConst( CIdent( '__lazylambda__' + s.substr( 1 ) ) ).make();
							}
							else {
								x;
							}
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
		// trace( x.pos );
		// trace( x.toString() );
		return ECall( EField( x, 'iterator' ).make(), [] ).make();
	}

#end

}