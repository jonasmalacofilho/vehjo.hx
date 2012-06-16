package ;

import jonas.graph.GraphTestSuite;
import jonas.unit.TestRunner;

import haxe.Timer;
import neko.Lib;

class Test {
	
	function new() {
		Timer.measure( testGraph );
		Timer.measure( testGraph2 );
	}
	
	static function testGraph() {
		var t = new TestRunner();
		GraphTestSuite.add_tests( t );
		t.add( new jonas.graph.DigraphStructuralTest() );
		t.add( new jonas.graph.DigraphTest() );
		
		t.add( new jonas.graph.GraphStructuralTest() );
		t.add( new jonas.graph.GraphTest() );
		
		t.add( new jonas.graph.ArcClassificationTest() );
		t.add( new jonas.graph.DFSColoringTest() );
		t.add( new jonas.graph.SPDijkstraTest() );
		t.add( new jonas.graph.SPAStarTest() );
		t.run();
	}
	
	static function testGraph2() {
		//var t = new TestRunner();
		//jonas.graph2.GraphTestSuite.add_tests( t );
		//t.add( new jonas.graph2.DigraphStructuralTest() );
		//t.add( new jonas.graph2.DigraphTest() );
		//
		//t.add( new jonas.graph2.GraphStructuralTest() );
		//t.add( new jonas.graph2.GraphTest() );
		//
		//t.add( new jonas.graph2.ArcClassificationTest() );
		//t.add( new jonas.graph2.DFSColoringTest() );
		//t.add( new jonas.graph2.SPDijkstraTest() );
		//t.add( new jonas.graph2.SPAStarTest() );
		//t.run();
	}
	
	static function main() {
		new Test();
	}
	
}