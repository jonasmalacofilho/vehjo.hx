package ;

#if neko
import neko.Lib;
#elseif cpp
import cpp.Lib;
#elseif js
import js.Lib;
#end

/*
 * jonas-haxe tests
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
		var t = new jonas.unit.TestRunner();
		//t.customTrace = function( v, ?p ) { };
		jonas.Base16Tests.add_tests( t );
		jonas.Base64TestSuite.add_tests( t );
		jonas.HMACTestSuite.add_tests( t ); // js: not suported for there is no Bytes implementation for Md5 or SHA-1 in the std
		jonas.MathExtensionTestSuite.add_tests( t );
		jonas.NumberPrinterTestSuite.add_tests( t );
		jonas.ds.DAryHeapTestSuite.add_tests( t );
		// jonas.ds.HashTableTestSuite.add_tests( t ); // js: slow
		jonas.ds.MultiHashesTestSuite.add_tests( t ); // js: bugs in tests
		jonas.ds.RjTreeTestSuite.add_tests( t );
		jonas.ds.queue.PriorityQueueTestSuite.add_tests( t );
		jonas.ds.queue.SimpleFIFOTestSuite.add_tests( t );
		jonas.graph.GraphTestSuite.add_tests( t );
		t.run();
	}
	
	static function main() {
		trace( 'Tests' );
		trace( 'Copyright (c) 2012 Jonas Malaco Filho' );
		trace( 'Powered by haXe (haxe.org) and neko (nekovm.org)' );
		new Tests();
	}
	
}