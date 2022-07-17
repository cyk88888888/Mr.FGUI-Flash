package framework.base
{

	public class ModuleCfgInfo
	{
		public var targetClass:Class;
		public var cacheEnabled:Boolean;
		public var preResList:Array;
		public var name: String;
		
		public function ModuleCfgInfo(_targetClass:Class, _preResList:Array,_cacheEnabled:Boolean)
		{
			targetClass = _targetClass;
			name = BaseUT.getClassNameByObj(_targetClass);
			cacheEnabled = _cacheEnabled;
			preResList = _preResList;
		}
	}
}