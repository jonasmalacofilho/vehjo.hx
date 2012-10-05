package jonas.macro;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * Expr tools
 * 
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */

class ExprTools {

	public static function trce( x : Expr ) : Expr {
		return make( ECall( make( EConst( CIdent( 'trace' ) ) ), [ x ] ) );
	}

	public static function make( e : ExprDef, ?p : Position ) : Expr {
		if ( p == null )
			p = Context.currentPos();
		return { expr : e, pos : p };
	}

	public static function makeEmpty() : Expr {
		return make( EBlock( [] ) );
	}

	public static function toString( e : Expr ) : String {
		#if tink_macros
		return tink.macro.tools.ExprTools.toString( e );
		#else
		Context.warning( "Can't stringfy expr without the tink_macros lib", e.pos );
		return '';
		#end
	}

	public static function ifNull( e : Expr, fallback : Expr ) : Expr {
		#if tink_macros
		return tink.macro.tools.ExprTools.ifNull( e, fallback );
		#else
		#error "Can't stringfy expr without the tink_macros lib"
		return '';
		#end
	}

	public static function transform( source: Expr, transformer: Expr -> Expr, ?pos: Position ): Expr {
		#if tink_macros
		return tink.macro.tools.ExprTools.transform( source, transformer, pos );
		#else
		#error "Can't transform expressions without the tink_macros lib"
		return '';
		#end
	}

}

#end