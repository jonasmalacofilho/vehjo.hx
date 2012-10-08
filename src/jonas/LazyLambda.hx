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
	- support both Iterable<A> and Iterator<A> as arguments
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
	@:macro public static function array<A>( it: ExprOf<Iterator<A>> ): ExprOf<Array<A>> {
		var iterator = getIterator( it );
		return macro {
			var y = [];
			for ( x in $iterator )
				y.push( x );
			y;
		};
	}

	/**
		Concatenates two collections
	**/
	@:macro public static function concat<A>( it1: ExprOf<Iterator<A>>, it2: ExprOf<Iterator<A>> ): ExprOf<Iterator<A>> {
		var nxit = getIterator( it2 );
		var fsit = getIterator( it1 );
		return macro {
			var nxit = $nxit;
			var fsit = $fsit;
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
			}
		};
	}

	/**
		Counts the total number of elements in a collection
	**/
	@:macro public static function count<A>( it: ExprOf<Iterator<A>> ): ExprOf<Int> {
		var iterator = getIterator( it );
		return macro {
			var i = 0;
			for ( x in $iterator )
				i++;
			i;
		};
	}

	/**
		Tells if a collection does not contain any elements
	**/
	@:macro public static function empty<A>( it: ExprOf<Iterator<A>> ): ExprOf<Bool> {
		var iterator = getIterator( it );
		return macro {
			!$iterator.hasNext();
		};
	}

	/**
		Filters a collection using the supplied expression "filter" 
		Exposed variables: $x (element) and $i (element index)
	**/
	@:macro public static function filter<A>( it: ExprOf<Iterator<A>>, filter: ExprOf<Bool> ): ExprOf<Iterator<A>> {
		var iterator = getIterator( it );

		var inspect = inspectIdentifiers( filter );
		filter = inspect.uExpr;
		var exposedIndex = false;
		for ( x in inspect.found )
			switch ( x ) {
				case IINDEX: exposedIndex = true;
			}

		if ( exposedIndex )
			return macro {
				var it = $iterator;
				var nx = null;
				var __lazylambda__i = 0;
				{
					hasNext: function () {
						while ( it.hasNext() && nx == null ) {
							var __lazylambda__x = it.next();
							if ( $filter ) {
								nx = __lazylambda__x;
								__lazylambda__i++;
								return true;
							}
							__lazylambda__i++;
						}
						return false;
					},
					next: function () {
						var next = nx;
						nx = null;
						return next;
					}
				}
			};
		else
			return macro {
				var it = $iterator;
				var nx = null;
				{
					hasNext: function () {
						while ( it.hasNext() && nx == null ) {
							var __lazylambda__x = it.next();
							if ( $filter ) {
								nx = __lazylambda__x;
								return true;
							}
						}
						return false;
					},
					next: function () {
						var next = nx;
						nx = null;
						return next;
					}
				}
			};
	}

	/**
		Returns the first element in a collection that matches the expression "cond"
		Exposed variables: $x (element) and $i (element index)
	**/
	@:macro public static function find<A>( it: ExprOf<Iterator<A>>, cond: ExprOf<Bool> ): ExprOf<Null<Int>> {
		var iterator = getIterator( it );

		var inspect = inspectIdentifiers( cond );
		cond = inspect.uExpr;
		var exposedIndex = false;
		for ( x in inspect.found )
			switch ( x ) {
				case IINDEX: exposedIndex = true;
			}

		if ( exposedIndex )
			return macro {
				var __lazylambda__i = 0;
				var ret = null;
				for ( __lazylambda__x in $iterator ) {
					if ( $cond ) {
						ret = __lazylambda__x;
						break;
					}
					__lazylambda__i++;
				}
				ret;
			};
		else
			return macro {
				var ret = null;
				for ( __lazylambda__x in $iterator ) {
					if ( $cond ) {
						ret = __lazylambda__x;
						break;
					}
				}
				ret;
			};
	}

	/**
		Functional fold
		Exposed variables: $pre (previous return value), $x (element) and $i (element index)
	**/
	@:macro public static function fold<A,B>( it: ExprOf<Iterator<A>>, fold: ExprOf<B>, first: ExprOf<B> ): ExprOf<B> {
		var iterator = getIterator( it );

		var inspect = inspectIdentifiers( fold );
		fold = inspect.uExpr;
		var exposedIndex = false;
		for ( x in inspect.found )
			switch ( x ) {
				case IINDEX: exposedIndex = true;
			}

		if ( exposedIndex )
			return macro {
				var __lazylambda__pre = $first;
				var __lazylambda__i = 0;
				for ( __lazylambda__x in $iterator ) {
					__lazylambda__pre = $fold;
					__lazylambda__i++;
				}
				__lazylambda__pre;
			};
		else
			return macro {
				var __lazylambda__pre = $first;
				for ( __lazylambda__x in $iterator ) {
					__lazylambda__pre = $fold;
				}
				__lazylambda__pre;
			};
	}
	
	/**
		Tells if the expression "cond" evaluates to true for ALL elements in a collection
		Exposed variables: $x (element) and $i (element index)
	**/
	@:macro public static function holds<A>( it: ExprOf<Iterator<A>>, cond: ExprOf<Bool> ): ExprOf<Bool> {
		var iterator = getIterator( it );

		var inspect = inspectIdentifiers( cond );
		cond = inspect.uExpr;
		var exposedIndex = false;
		for ( x in inspect.found )
			switch ( x ) {
				case IINDEX: exposedIndex = true;
			}

		if ( exposedIndex )
			return macro {
				var ret = true;
				var __lazylambda__i = 0;
				for ( __lazylambda__x in $iterator ) {
					if ( !$cond ) {
						ret = false;
						break;
					}
					__lazylambda__i++;
				}
				ret;
			};
		else
			return macro {
				var ret = true;
				for ( __lazylambda__x in $iterator ) {
					if ( !$cond ) {
						ret = false;
						break;
					}
				}
				ret;
			};
	}

	/**
		Tells if the expression "cond" evaluates to true for AT LEAST ONE element in a collection
		Exposed variables: $x (element) and $i (element index)
	**/
	@:macro public static function holdsOnce<A>( it: ExprOf<Iterator<A>>, cond: ExprOf<Bool> ): ExprOf<Bool> {
		var iterator = getIterator( it );

		var inspect = inspectIdentifiers( cond );
		cond = inspect.uExpr;
		var exposedIndex = false;
		for ( x in inspect.found )
			switch ( x ) {
				case IINDEX: exposedIndex = true;
			}

		if ( exposedIndex )
			return macro {
				var ret = false;
				var __lazylambda__i = 0;
				for ( __lazylambda__x in $iterator ) {
					if ( $cond ) {
						ret = true;
						break;
					}
					__lazylambda__i++;
				}
				ret;
			};
		else
			return macro {
				var ret = false;
				for ( __lazylambda__x in $iterator ) {
					if ( $cond ) {
						ret = true;
						break;
					}
				}
				ret;
			};
	}

	/**
		Returns the index of the first element in a collection that matches the expression "cond"
		Exposed variables: $x (element) and $i (element index)
	**/
	@:macro public static function indexOf<A>( it: ExprOf<Iterator<A>>, cond: ExprOf<Bool> ): ExprOf<Int> {
		var iterator = getIterator( it );

		var inspect = inspectIdentifiers( cond );
		cond = inspect.uExpr;

		return macro {
			var __lazylambda__i = 0;
			var ret = -1;
			for ( __lazylambda__x in $iterator ) {
				if ( $cond ) {
					ret = __lazylambda__i;
					break;
				}
				__lazylambda__i++;
			}
			ret;
		};
	}

	/**
		Executes the expression "expr" for each element in a collection
		Exposed variables: $x (element) and $i (element index)
	**/
	@:macro public static function iter<A>( it: ExprOf<Iterator<A>>, expr ): ExprOf<Void> {
		var iterator = getIterator( it );

		var inspect = inspectIdentifiers( expr );
		expr = inspect.uExpr;
		var exposedIndex = false;
		for ( x in inspect.found )
			switch ( x ) {
				case IINDEX: exposedIndex = true;
			}

		if ( exposedIndex )
			return macro {
				var __lazylambda__i = 0;
				for ( __lazylambda__x in $iterator ) {
					$expr;
					__lazylambda__i++;
				}
				null;
			};
		else
			return macro {
				for ( __lazylambda__x in $iterator )
					$expr;
				null;
			};
	}

	/**
		Returns an iterable from an iterator
	**/
	@:macro public static function iterable<A>( it: ExprOf<Iterator<A>> ): ExprOf<Iterable<A>> {
		var iterator = getIterator( it );
		return macro {
			{ iterator: function () return $iterator };
		};
	}

	/**
		Creates a list from a collection
	**/
	@:macro public static function list<A>( it: ExprOf<Iterator<A>> ): ExprOf<List<A>> {
		var iterator = getIterator( it );
		return macro {
			var y = new List();
			for ( x in $iterator )
				y.add( x );
			y;
		};
	}

	/**
		Maps every element in a colletion into a new element, using the expression "map"
		Exposed variables: $x (element) and $i (element index)
	**/
	@:macro public static function map<A,B>( it: ExprOf<Iterator<A>>, map: ExprOf<B> ): ExprOf<Iterator<B>> {
		var iterator = getIterator( it );

		var inspect = inspectIdentifiers( map );
		map = inspect.uExpr;
		var exposedIndex = false;
		for ( x in inspect.found )
			switch ( x ) {
				case IINDEX: exposedIndex = true;
			}

		if ( exposedIndex )
			return macro {
				var it = $iterator;
				var __lazylambda__i = 0;
				{
					hasNext: it.hasNext,
					next: function () {
						var __lazylambda__x = it.next();
						var ret = $map;
						__lazylambda__i++;
						return ret;
					}
				}
			};
		else
			return macro {
				var it = $iterator;
				{
					hasNext: it.hasNext,
					next: function () {
						var __lazylambda__x = it.next();
						return $map;
					}
				}
			};
	}

#if macro

	static inline var IINDEX = '$i';
	static inline var IELEMENT = '$x';
	static inline var IPREVALUE = '$pre';

	static function getIterator<A>( x: Expr ): ExprOf<Iterator<A>> {
		return x;
	}

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
			}
		} );
		return { uExpr: uExpr, found: found };
	}

#end

}