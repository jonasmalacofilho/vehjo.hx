package vehjo.ds;

/**
 * List tools
 */
class ListTools 
{
	
	public static function reverse<A>(li : List<A>)
	{
		var t = new List();
		for (e in li)
			t.push(e);
		return t;
	}
	
}
