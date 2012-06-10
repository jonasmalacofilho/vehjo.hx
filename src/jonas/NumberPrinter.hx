package jonas;

/**
 * Formatted number printing
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

/**
 * Formatted number printing
 */
class NumberPrinter
{
	
	static inline function _integer_part(str : EReg, buf : StringBuf) : Void
	{
		if (null != str.matched(5)) {
			var e = Std.parseInt(str.matched(6));
			if (0 <= e) {
				buf.add(str.matched(2));
				buf.add(StringTools.rpad(str.matched(4).substr(0, e), '0', e));
			}
			else
				buf.add('0');
		}
		else	
			buf.add(str.matched(2));
	}
	
	static inline function _decimal_places(str : EReg, buf : StringBuf, pre : Int) : Void
	{
		if (null != str.matched(4)) {
			if (null != str.matched(5)) {
				var e = Std.parseInt(str.matched(6));
				if (0 <= e)
					buf.add(str.matched(4).substr(e, pre));
				else
					buf.add((StringTools.rpad('', '0', - (e + 1)) + str.matched(2) + str.matched(4)).substr(0, pre));
			}
			else
				buf.add(str.matched(4).substr(0, pre));
		}
	}
	
	public static inline function printInteger(v : Float, ?min_width = 1, ?min_precision = 1)
	{
		var str = ~/([+-])?(\d+)(\.(\d+)(e([+-]\d+))?)?/;
		
		str.match(Std.string(v));
		var buf = new StringBuf();
		
		// integer part
		_integer_part(str, buf);
		
		if (null != str.matched(1))
			return StringTools.lpad(str.matched(1) + StringTools.lpad(buf.toString(), '0', min_precision), ' ', min_width);
		else
			return StringTools.lpad(StringTools.lpad(buf.toString(), '0', min_precision), ' ', min_width);
	}
	
	public static inline function printDecimal(v : Float, ?min_width = 1, ?precision = 1) : String
	{
		return printTruncatedDecimal(MathExtension.round(v, precision), min_width, precision);
	}
	
	// works by truncating... (v >= 0) ? Math.floor(v) : Math.ceil(v)
	// therefore, please, please, consider the last digit as incertain and always print with an extra precision digit
	public static inline function printTruncatedDecimal(v : Float, ?min_width = 1, ?precision = 1) : String
	{
		var str = ~/([+-])?(\d+)(\.(\d+)(e([+-]\d+))?)?/;
		
		str.match(Std.string(v));
		var buf = new StringBuf();
		
		// integer part
		_integer_part(str, buf);
		
		// decimal places
		var le = buf.toString().length + precision;
		if (0 < precision) {
			le++;
			buf.add('.');
			_decimal_places(str, buf, precision);
		}
		
		var r = StringTools.rpad(buf.toString(), '0', le);
		return StringTools.lpad( (null != str.matched(1)) ? str.matched(1) + r : r, ' ', min_width);
	}

}