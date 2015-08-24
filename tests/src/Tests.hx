package ;

#if neko
import neko.Lib;
#elseif cpp
import cpp.Lib;
#elseif js
import js.Lib;
#end

/*
 * vehjo-haxe tests
 * Copyright (c) 2012 Jonas Malaco Filho
 * Licensed under the MIT license. Check LICENSE.txt for more information.
 */

/**
 * Full testing
 */
class Tests {
	
	public function new() {
		run_all_tests();
	}
	
	static function run_all_tests() {
		var t = new vehjo.unit.TestRunner();
		//t.customTrace = function( v, ?p ) { };
		t.add( new vehjo.TestGeneric() );
		vehjo.Base16Tests.add_tests( t );
		vehjo.Base64TestSuite.add_tests( t );
		vehjo.HMACTestSuite.add_tests( t ); // js: not suported for there is no Bytes implementation for Md5 or SHA-1 in the std
		vehjo.MathExtensionTestSuite.add_tests( t );
		vehjo.NumberPrinterTestSuite.add_tests( t );
		vehjo.ds.DAryHeapTestSuite.add_tests( t );
		// vehjo.ds.HashTableTestSuite.add_tests( t ); // js: slow
		vehjo.ds.MultiHashesTestSuite.add_tests( t ); // js: bugs in tests
		vehjo.ds.RjTreeTestSuite.add_tests( t );
		vehjo.ds.queue.PriorityQueueTestSuite.add_tests( t );
		vehjo.ds.queue.SimpleFIFOTestSuite.add_tests( t );
		vehjo.graph.GraphTestSuite.add_tests( t );
		t.add( new vehjo.format.TestCSV() );
		t.run();
	}
	
	static function main() {
		trace( 'Tests' );
		trace( 'Copyright (c) 2012 Jonas Malaco Filho' );
		trace( 'Powered by haXe (haxe.org) and neko (nekovm.org)' );
		new Tests();
	}
	
}