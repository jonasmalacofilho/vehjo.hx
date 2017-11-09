package vehjo;

import vehjo.unit.TestCase;
typedef M = vehjo.MathExtension;

class TestGeneric extends TestCase {

	public function testHaxeModulo() {
		// assertEquals( 0, 0%0, pos_infos( '0%0 == 0' ) );
			// fails on Haxe 2.10
		assertEquals( 0, 4%2, pos_infos( '4%2 == 0' ) );
		assertEquals( 1, 4%3, pos_infos( '4%3 == 1' ) );
		assertEquals( -1, (-4)%3, pos_infos( '(-4)%3 == -1' ) );
		// assertEquals( -1, 4%(-3), pos_infos( '(4)%(-3)%0 == -1' ) );
			// fails on Haxe 2.10
	}

	public function testHaxeModuloFrom210() {
		var v: Dynamic = 'Exception';
		try { v = 0%0; } catch ( e: Dynamic ) { }
		assertEquals( 'Exception', v, pos_infos( '0%0 == Exception' ) );
		assertEquals( 1, 4%(-3), pos_infos( '(4)%(-3)%0 == -1' ) );
	}

	public function testHaxeFloat() {
		assertDifferent( Math.NaN, Math.NaN, pos_infos( 'NaN != NaN' ) );
		assertFalse( Math.NaN < Math.NaN, pos_infos( 'NaN !< NaN' ) );
		// assertFalse( Math.NaN > Math.NaN
			// , pos_infos( 'NaN !> NaN' )
		// ); // fails on Haxe 2.10
		assertEquals( Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY
			, pos_infos( '+oo == +oo' )
		);
		assertEquals( Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY
			, pos_infos( '-oo == -oo' )
		);
		assertFalse( Math.isNaN( Math.POSITIVE_INFINITY )
			, pos_infos( '+oo not NaN' )
		);
		assertFalse( Math.isNaN( Math.NEGATIVE_INFINITY )
			, pos_infos( '-oo not NaN' )
		);
		// assertFalse( Math.isFinite( Math.NaN )
			// , pos_infos( 'NaN not finite' )
		// ); // fails on Haxe 2.10
		assertTrue( Math.isNaN( Math.sqrt( -1 ) )
			, pos_infos( 'sqrt( - 1) is NaN' )
		);
		assertEquals( Math.POSITIVE_INFINITY, 1/0
			, pos_infos( '1/0 == +oo' )
		);
		assertEquals( Math.NEGATIVE_INFINITY, (-1)/0
			, pos_infos( '-1/0 == -oo' )
		);
	}

#if (haxe_ver < "4.0.0")
	public function testHaxeFloatFrom210() {
		assertTrue( Math.NaN > Math.NaN
			, pos_infos( 'used to fail: NaN !> NaN' )
		);
		assertTrue( Math.isFinite( Math.NaN )
			, pos_infos( 'used to fail: NaN not finite' )
		);
	}
#end

	public function testGeoidMath() {
		// Earth radius estimate
		assertEquals( 6378, Math.round( 1e-3*M.earth_radius( 0 ) )
			, pos_infos( 'equatorial radius' )
		);
		assertEquals( 6357, Math.round( 1e-3*M.earth_radius( 90 ) )
			, pos_infos( 'polar radius (N)' )
		);
		assertEquals( 6357, Math.round( 1e-3*M.earth_radius( -90 ) )
			, pos_infos( 'polar radius (S)' )
		);
		assertEquals( Math.round( 1e-3*M.earth_radius( 30 ) )
			, Math.round( 1e-3*M.earth_radius( -150 ) )
			, pos_infos( 'simetry' )
		);

		// Distances on the Geoid
		// Expected values come from Google Earth
		// Maximum allowed tolerance is 0.5%
		assertTolerable( 33818.65
			, M.earth_distance_haversine(
				-23.57226253442925, -46.78499448477063
				, -23.49020350767767, -46.46600064768076
			)
			, .005
		);
		assertTolerable( 114.35
			, M.earth_distance_haversine(
				-23.54879910856591, -46.63942480068102
				, -23.54938140167628, -46.63849993846976
			)
			, .005
		);
		assertTolerable( 1060.99
			, M.earth_distance_haversine(
				-23.54595750519953, -46.63425418110865
				, -23.54994352371944, -46.64370324273774
			)
			, .005
		);
		assertTolerable( 12713677.97
			, M.earth_distance_haversine(
				-32.57839497737505, -35.51678404413713
				, 61.82392710554233, -116.9091947980278
			)
			, .005
		);
	}

}
