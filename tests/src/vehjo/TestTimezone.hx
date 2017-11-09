package vehjo;

import vehjo.Timezone;
import vehjo.unit.TestCase;

class TestTimezone extends TestCase {
#if neko
	static var date_get_tz = neko.Lib.load("std","date_get_tz", 0);
	static var systemDelta = 1e3*date_get_tz();
#end

	public function test_fake()
	{
		trace('Current local offset (reference):  ${Timezone.offsetToString(systemDelta)}');
		trace('Current local offset (computed):   ${Timezone.offsetToString(Timezone.currentTimezone())}');
		trace('Standard local offset (computed):  ${Timezone.offsetToString(Timezone.localTimezone())}');
		assertTrue(true);
	}

	public function test_currentTimezone()
	{
		assertEquals(systemDelta, Timezone.currentTimezone(Date.now()));
	}

	public function test_offsetToString()
	{
		assertEquals("+0000", Timezone.offsetToString(0));
		assertEquals("+0400", Timezone.offsetToString(4*3600*1e3));
		assertEquals("-0400", Timezone.offsetToString(-4*3600*1e3));
		assertEquals("+0420", Timezone.offsetToString((4*3600+1200)*1e3));
		assertEquals("-0420", Timezone.offsetToString(-(4*3600+1200)*1e3));
	}

	public function test_internal_haxe_dates_around_dst_changes()
	{
		// new Date and Date.fromString differ considerably regarding DST:
		//  - new Date() does localtime_r(0); mktime(date); mktime(time) (without
		//    explicitly touching tm_isdst)
		//  - Date.fromString sets tm_isdst = -1 and does a single mktime
		// how does this impact the assumption that "all Haxe dates are in
		// (respective) local time?"?
		var day = 23, hours = 23, minutes = 42, seconds = 13;  // why not?
		for (year in 1970...2020) {
			for (month in 0...12) {
				var mm = StringTools.lpad('${month + 1}', "0", 2);
				var dateString = '$year-$mm-$day $hours:$minutes:$seconds';

				var d1 = new Date(year, month, day, hours, minutes, seconds);
				var d2 = Date.fromString(dateString);  // sets tm_isdt=-1 before calling mktime

				assertEquals(d2.getTime(), d1.getTime());
				assertEquals(d2.toString(), d1.toString());
				assertEquals(d2.toString(), dateString);
				assertEquals(Timezone.currentTimezone(d2), Timezone.currentTimezone(d1));
			}
		}
	}
}

