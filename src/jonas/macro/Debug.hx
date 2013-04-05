package jonas.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using jonas.macro.ExprTools;
#end

/**
	In-code debugging tools
	Only enabled in debug mode (-debug)
	Requires tink_macros for expression stringfication
**/
class Debug {

	/* Traces "false" if v==false */
	public static macro function assertTrue( v : ExprOf<Bool> ) {
		#if debug
		var str = Context.makeExpr( 'Assert "' + v.toString() + '": false', v.pos );
		return ExprTools.make( EIf( ExprTools.make( EUnop( OpNot, false, v ) ), ExprTools.trce( str ), null ) );
		#else
		return ExprTools.makeEmpty();
		#end
	}

	/* Traces v if cond==true */
	public static macro function assertIf( cond : ExprOf<Bool>, v : Expr ) {
		#if debug
		var str = Context.makeExpr( '"' + cond.toString() + '"==true triggered assert "' + v.toString() + '": ', v.pos );
		return ExprTools.make( EIf( cond, ExprTools.trce( ExprTools.make( EBinop( OpAdd, str, v ) ) ), null ) );
		#else
		return ExprTools.makeEmpty();
		#end
	}

	/* Traces v */
	public static macro function assert( v : Expr ) {
		#if debug
		var str = Context.makeExpr( 'Assert "' + v.toString() + '": ', Context.currentPos() );
		return ExprTools.trce( ExprTools.make( EBinop( OpAdd, str, v ) ) );
		#else
		return ExprTools.makeEmpty();
		#end
	}

}