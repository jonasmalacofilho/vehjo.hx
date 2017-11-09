package vehjo.ds;

#if (haxe_ver >= "4.0.0")
import haxe.ds.List;
#end

/**
	MultiHash with integer keys
**/
class IntMultiHash<T> {
	var _hash:Map<Int,List<T>>;

	public function new() 
	{
		_hash = new Map();
	}
	
	public function count() : Int {
		var cnt = 0;
		for ( x in _hash )
			cnt += x.length;
		return cnt;
	}
	
	inline public function exists(key : Int) : Bool
	{
		return _hash.exists(key);
	}
	
	public function get(key : Int) : List<T>
	{
		if (exists(key))
			return _hash.get(key);
		else
			return new List();
	}
	
	inline public function iterator() : Iterator<List<T>>
	{
		return _hash.iterator();
	}
	
	inline public function keys() : Iterator<Int>
	{
		return _hash.keys();
	}
	
	public function values() : Iterator<T>
	{
		var hash_iterator = _hash.iterator();
		if (hash_iterator.hasNext())
		{
			var hash_next = hash_iterator.next();
			var list_iterator = hash_next.iterator();
			return {
				hasNext : function()
				{
					return list_iterator.hasNext() || hash_iterator.hasNext();
				},
				next : function()
				{
					if (list_iterator.hasNext())
						return list_iterator.next();
					else if (hash_iterator.hasNext())
					{
						hash_next = hash_iterator.next();
						list_iterator = hash_next.iterator();
						return list_iterator.next();
					}
					else
						return null;
				}
			};
		}
		else
		{
			return {
				hasNext : function()
				{
					return false;
				},
				next : function()
				{
					return null;
				}
			};
		}	
	}
	
	inline public function remove(key : Int) : Bool
	{
		return _hash.remove(key);
	}
	
	public function add( key : Int, value : T ) : Void {
		if (exists(key))
			_hash.get(key).add(value);
		else
		{
			var p = new List();
			p.add(value);
			_hash.set(key, p);
		}
	}
	
	public function push(key : Int, value : T) : Void
	{
		if (exists(key))
			_hash.get(key).push(value);
		else
		{
			var p = new List();
			p.push(value);
			_hash.set(key, p);
		}
	}
	
	public function pop(key : Int) : Null<T>
	{
		if (exists(key))
			return _hash.get(key).pop();
		else
			return null;
	}
	
	public function remove_specific(key : Int, maintain : T -> Bool) : Bool
	{
		if (exists(key))
		{
			var old_list = _hash.get(key);
			var new_list = Lambda.filter(old_list, maintain);
			_hash.set(key, new_list);
			return new_list.length != old_list.length;
		}
		else
			return false;
	}
	
	inline public function toString()
		return Std.string( _hash );
	
	// Version of groupByHash from http://haxe.org/doc/snip/groupbyhash
	public static function groupByHash<T2>(it : Iterable<T2>, ?transformer : T2 -> Int) : IntMultiHash<T2>
	{
		if (transformer == null)
			transformer = function(x) { return Std.int(cast(x, Float)); }
		
		var r = new IntMultiHash();
		for (i in it){ // go through the Iterable and add elements to Hash entries based on their transform
			var t = transformer(i);
			r.push(t, i);
		}
		
		return r;
	}
	
}
