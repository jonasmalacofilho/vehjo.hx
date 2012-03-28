package jonas.unit;

import haxe.PosInfos;

/*
 * 
 * Copyright (c) 2012 Jonas Malaco Filho
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */


class TestCase extends haxe.unit.TestCase {
	
	public var _configs : Hash<Dynamic>;
	public var _config_current : String;
	public var _config_default : String;
	
	public function new() {
		_config_current = null;
		_config_default = 'default';
		if ( null == _configs )
			_configs = new Hash();
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
	
}