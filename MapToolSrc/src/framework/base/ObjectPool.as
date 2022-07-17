package framework.base
{
	/**
	 * 对象池 
	 * @author cyk
	 * 
	 */	
	public class ObjectPool
	{
		private var buffer: Array;
		private var createFunc:Function;
		private var releaseFunc:Function;
		
		private var capacity:int;
		public function get count():int { return buffer.length}
		public function ObjectPool(_createFunc:Function, _releaseFunc:Function,_capacity:int = -1)
		{
			createFunc = _createFunc;
			releaseFunc = _releaseFunc;
			capacity = _capacity;
			buffer = [];
		}
		
		public function getObject():Object
		{
			if(buffer.length == 0)
			{
				return createFunc();
			}
			else
			{
				return buffer.shift();
			}
		}
		
		public function releaseObject(obj:Object):void
		{
			if (capacity != -1 && count >= capacity) return;//达到上限
			if(releaseFunc) releaseFunc.call(this, obj);
			buffer.push(obj);
		}

	}
}