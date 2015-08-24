package vehjo.unit;

import haxe.PosInfos;

class TestCase extends haxe.unit.TestCase {
	
	public var _configs:Map<String,Dynamic>;
	public var _config_current : String;
	public var _config_default : String;
	
	public function new() {
		_config_current = null;
		_config_default = 'default';
		if ( null == _configs )
			_configs = new Map<String,Dynamic>();
		super();
	}

	public function set_configuration( name : Null<String>, data : Dynamic ) : Void {
		_configs.set( ( null != name ? name : _config_default ), data );
	}
	
	function pos_infos( ?p : PosInfos, data : Dynamic ) : PosInfos {
		if ( null != p.customParams )
			p.customParams.push( data );
		else
			p.customParams = [ data ];
		return p;
	}
	
	function starting_checks() : Void { }
	
	function finishing_cheks() : Void { }
	
	override public function setup() : Void {
		if ( null == _config_current )
			_config_current = _config_default;
		configure( _config_current );
	}
	
	function configure( name : String ) : Void {
		var configuration = _configs.get( name );
		if ( null == configuration && name != _config_default)
			configuration = _configs.get( _config_default );
		if ( null != configuration )
			for ( f in Reflect.fields( configuration ) ) {
				Reflect.setField( this, f, Reflect.field( configuration, f ) );
			}
			
	}
	
	override function assertTrue( b:Bool, ?c : PosInfos ) : Void {
		currentTest.done = true;
		if (b == false){
			currentTest.success = false;
			currentTest.error = "expected true but was false" + ' (config=\'' + _config_current + '\')';
			currentTest.posInfos = c;
			throw currentTest;
		}
	}

	override function assertFalse( b:Bool, ?c : PosInfos ) : Void {
		currentTest.done = true;
		if (b == true){
			currentTest.success = false;
			currentTest.error = "expected false but was true" + ' (config=\'' + _config_current + '\')';
			currentTest.posInfos = c;
			throw currentTest;
		}
	}

	override function assertEquals<T>( expected: T , actual: T,  ?c : PosInfos ) : Void {
		currentTest.done = true;
		if (actual != expected){
			currentTest.success = false;
			currentTest.error = "expected '" + expected + "' but was '" + actual + "'" + ' (config=\'' + _config_current + '\')';
			currentTest.posInfos = c;
			throw currentTest;
		}
	}
	
	function assertDifferent<T>( expected: T , actual: T,  ?c : PosInfos ) : Void 	{
		currentTest.done = true;
		if (actual == expected){
			currentTest.success = false;
			currentTest.error = "did not expected '" + expected + "'" + ' (config=\'' + _config_current + '\')';
			currentTest.posInfos = c;
			throw currentTest;
		}
	}

	function assertTolerable( exp: Float, val: Float, maxError: Float
		, ?c : PosInfos ) {
		currentTest.done = true;
		var error = ( val - exp ) / exp;
		if ( Math.abs( error ) > maxError ) {
			currentTest.success = false;
			currentTest.error = 'value ' + val
				+ ' outside of allowed tolerance of ' + ( maxError*100 )
				+ '% from expected value ' + exp
				+ ' (config=\'' + _config_current + '\')';
			currentTest.posInfos = c;
			throw currentTest;
		}
	}

	
}