package jonas.unit;

import haxe.rtti.Meta;
import haxe.unit.TestCase;
import haxe.unit.TestStatus;
import jonas.unit.TestResult;

/*
 * Test runner extension
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */


class TestRunner extends haxe.unit.TestRunner {
	
	var test_number : Int;
	public var traces : Array<String>;
	
	public function new() {
		super();
		result = new TestResult();
	}
	
	override public function run() : Bool {
		print( 'Running ' + cases.length + ' test case' + ( cases.length != 1 ? 's' : '' ) + '\n\n' );
		result = new TestResult();
		test_number = 0;
		for ( c in cases ){
			runCase(c);
		}
		println( result.toString() );
		return result.success;
	}

	public dynamic function print( v : Dynamic ) : Void {
		haxe.unit.TestRunner.print( v );
	}
	
	public dynamic function customTrace( v, ?p : haxe.PosInfos ) : Void {
		traces.push( p.fileName + ':' + p.lineNumber + ': ' + v );
	}
	
	public dynamic function println( v : Dynamic ) : Void {
		print( v + '\n' );
	}
	
	override function runCase( t:TestCase ) : Void {
		var old = haxe.Log.trace;
		traces = [];
		haxe.Log.trace = customTrace;

		var cl = Type.getClass(t);
		println( 'Case ' + ( ++test_number ) + '/' + cases.length + ': ' + Type.getClassName( cl ) );
		var cm = Meta.getType( cl );
		for ( x in Reflect.fields( cm ) )
			println( '@' + x + ': ' + Reflect.field( cm, x ).join( ', ' ) );
		
		print( 'Running: ' );
		var t2 : jonas.unit.TestCase = Std.is( t, jonas.unit.TestCase ) ? cast t : null;
		var fields = Type.getInstanceFields(cl);
		//var msg = '';
		var configs = null != t2 ? t2._configs : new Hash();
		if ( 0 == Lambda.count( configs ) )
			configs.set( '', null );
		var cnames = Lambda.array( { iterator : configs.keys } );
		cnames.sort( Reflect.compare );
		for ( cname in cnames ) {
			if ( null != t2 )
				t2._config_current = cname;
			
			for ( f in fields ){
				var fname = f;
				var field = Reflect.field(t, f);
				if ( StringTools.startsWith(fname,"test") && Reflect.isFunction(field) ){
					t.currentTest = new TestStatus();
					t.currentTest.classname = Type.getClassName(cl);
					t.currentTest.method = fname;
					t.setup();
					try {
						
						var starting_checks = Reflect.field( t, 'starting_checks' );
						if ( null != starting_checks && Reflect.isFunction( starting_checks ) )
							Reflect.callMethod( t, starting_checks, [] );
							
						Reflect.callMethod(t, field, new Array());
						
						var finishing_cheks = Reflect.field( t, 'finishing_cheks' );
						if ( null != finishing_cheks && Reflect.isFunction( finishing_cheks ) )
							Reflect.callMethod( t, finishing_cheks, [] );
						
						if( t.currentTest.done ){
							t.currentTest.success = true;
							//msg += '.';
							print( '.' );
						}else{
							t.currentTest.success = false;
							t.currentTest.error = "(warning) no assert";
							//msg += 'W';
							print( 'W' );
						}
					}catch ( e : TestStatus ){
						//msg += 'F';
						print( 'F' );
						t.currentTest.backtrace = haxe.Stack.toString(haxe.Stack.exceptionStack());
					}catch ( e : Dynamic ){
						print( 'E' );
						#if js
						if( e.message != null ){
							t.currentTest.error = "exception thrown : "+e+" ["+e.message+"]";
						}else{
							t.currentTest.error = "exception thrown : "+e;
						}
						#else
						t.currentTest.error = "exception thrown : "+e;
						#end
						t.currentTest.backtrace = haxe.Stack.toString(haxe.Stack.exceptionStack());
					}
					result.add(t.currentTest);
					t.tearDown();
				}
			}
		}
		//println( msg );
		print( '\n' );
		haxe.Log.trace = old;
		if ( 0 < traces.length )
			println( traces.join( '\n' ) );
		print( '\n' );
	}
	
}