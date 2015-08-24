package jonas.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using jonas.macro.ExprTools;
#end

/**
 * Exception rasing and handling facilities
 * Requires tink_macros for expression stringfication
 * 
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */

class Error {

	public macro static function throwIf( cond : ExprOf<Bool>, ?expr : Expr ) {
		expr = ExprTools.ifNull( expr, Context.makeExpr( '"' + cond.toString() + '" raised', cond.pos ) );
		return ExprTools.make( EIf( cond, ExprTools.make( EThrow( expr ) ), ExprTools.makeEmpty() ) );
	}

}
