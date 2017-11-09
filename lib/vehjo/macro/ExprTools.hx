package vehjo.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import vehjo.Lam;

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
		return new haxe.macro.Printer().printExpr( e );
	}

	public static function ifNull( e : Expr, fallback : Expr ) : Expr {
		return Type.enumEq( e.expr, EConst( CIdent( 'null' ) ) ) ? fallback : e;
	}

	public static function transform( source: Null<Expr>, t: Expr -> Expr, ?pos: Position ): Expr {
		return haxe.macro.ExprTools.map(source, t);
	}

	public static function changePos( e: Expr, p: Position ): Expr {
		return transform( e, function ( x ) return { expr: x.expr, pos: p } );
	}

}
