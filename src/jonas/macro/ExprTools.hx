package jonas.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import jonas.Lam;

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
		if ( source == null )
			return null;
		if ( pos == null  )
			pos = source.pos;
		return t( make( switch ( source.expr ) {
			case EArray( e1, e2 ): EArray( transform( e1, t, e1.pos ), transform( e2, t ) );
			case EBinop( op, e1, e2 ): EBinop( op, transform( e1, t, e1.pos ), transform( e2, t ) );
			case EField( e, field ): EField( transform( e, t ), field );
			case EParenthesis( e ): EParenthesis( transform( e, t ) );
			case EObjectDecl( fields ): EObjectDecl( Lam.map( fields, function ( x ) return { field: x.field, expr: transform( x.expr, t ) } ) );
			case EArrayDecl( values ): EArrayDecl( Lam.map( values, function ( x ) return transform( x, t ) ) );
			case ECall( e, params ): ECall( transform( e, t ), Lam.map( params, function ( x ) return transform( x, t ) ) );
			case ENew( type, params ): ENew( type, Lam.map( params, function ( x ) return transform( x, t ) ) );
			case EUnop( op, postFix, e ): EUnop( op, postFix, transform( e, t ) );
			case EVars( vars ): EVars( Lam.map( vars, function ( x ) return { name: x.name, type: x.type, expr: transform( x.expr, t ) } ) );
			case EFunction( name, f ): EFunction( name, {
					args: Lam.map( f.args, function ( x ) return { name: x.name, opt: x.opt, type: x.type, value: transform( x.value, t ) } ),
					ret: f.ret,
					expr: transform( f.expr, t ),
					params: f.params
			} );
			case EBlock( es ): EBlock( Lam.map( es, function ( x ) return transform( x, t ) ) );
			case EFor( it, expr ): EFor( transform( it, t ), transform( expr, t ) );
			case EIn( e1, e2 ): EIn( transform( e1, t ), transform( e2, t ) );
			case EIf( econd, eif, eelse ): EIf( transform( econd, t ), transform( eif, t ), transform( eelse, t ) );
			case EWhile( econd, e, normalWhile ): EWhile( transform( econd, t ), transform( e, t ), normalWhile );
			case ESwitch( e, cases, edef ): ESwitch(
				transform( e, t ),
				Lam.map( cases, function ( x ) return cast {
					values: Lam.map( x.values, function ( x ) return transform( x, t ) ),
					expr: transform( x.expr, t )
				} ),
				transform( edef, t )
			);
			case ETry( e, catches ): ETry( transform( e, t ),
				Lam.map( catches, function ( x ) return { name: x.name, type: x.type, expr: transform( x.expr, t ) } )
			);
			case EReturn( e ): EReturn( transform( e, t ) );
			case EUntyped( e ): EUntyped( transform( e, t ) );
			case EThrow( e ): EThrow( transform( e, t ) );
			case ECast( e, type ): ECast( transform( e, t ), type );
			case EDisplay( e, isCall ): EDisplay( transform( e, t ), isCall );
			case ETernary( econd, eif, eelse ): ETernary( transform( econd, t ), transform( eif, t ), transform( eelse, t ) );
			case ECheckType( e, type ): ECheckType( transform( e, t ), type );
			#if !haxe3
			case EType( e, field ): EType( transform( e, t ), field );
			#end
			// EConst, EBreak, EContinue, EDisplayNew
			default: source.expr;
		}, pos ) );
	}

	public static function changePos( e: Expr, p: Position ): Expr {
		return transform( e, function ( x ) return { expr: x.expr, pos: p } );
	}

}