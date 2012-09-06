package jonas.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

#if debug
import tink.macro.tools.ExprTools;
#end

/**
 * In-code debugging tools
 * Only enabled in debug mode (-debug)
 * Requires tink_macros (for tink.macro.tools.ExprTools.toString)
 * 
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */

class Debug {

	/* Traces "false" if v==false */
	@:macro public static function assertTrue( v : ExprOf<Bool> ) {
		#if debug
		var str = Context.makeExpr( 'Assert "' +
			ExprTools.toString( v ) +
			'": false', v.pos );
		return make( EIf( make( EUnop( OpNot, false, v ) ), trce( str ), null ) );
		#else
		return makeEmpty();
		#end
	}

	/* Traces v if cond==true */
	@:macro public static function assertIf( cond : ExprOf<Bool>, v : Expr ) {
		#if debug
		var str = Context.makeExpr( 'Assert "' +
			tink.macro.tools.ExprTools.toString( v ) +
			'": ', v.pos );
		return make( EIf( cond, trce( make( EBinop( OpAdd, str, v ) ) ), null ) );
		#else
		return makeEmpty();
		#end
	}

	/* Traces v */
	@:macro public static function assert( v : Expr ) {
		#if debug
		var str = Context.makeExpr( 'Assert "' +
			tink.macro.tools.ExprTools.toString( v ) +
			'": ', Context.currentPos() );
		return trce( make( EBinop( OpAdd, str, v ) ) );
		#else
		return makeEmpty();
		#end
	}

#if macro

	static function trce( x : Expr ) : Expr {
		return make( ECall( make( EConst( CIdent( 'trace' ) ) ), [ x ] ) );
	}

	static function make( e : ExprDef, ?p : Position ) : Expr {
		if ( p == null )
			p = Context.currentPos();
		return { expr : e, pos : p };
	}

	static function makeEmpty() : Expr {
		return make( EBlock( [] ) );
	}

#end

}