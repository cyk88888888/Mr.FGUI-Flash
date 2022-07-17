package framework.mgr
{
	import flash.utils.Dictionary;
	
	import framework.base.BaseUT;
	import framework.base.ModuleCfgInfo;
	import framework.ui.UILayer;
	
	public class ModuleMgr
	{
		private static var _inst: ModuleMgr;
		public static function get inst():ModuleMgr
		{
			if(!_inst){
				_inst = new ModuleMgr();
			}
			
			return _inst;
		}
		public function ModuleMgr(){};
		
		public static var moduleInfoMap: Dictionary;
		/**
		 * 注册模块
		 */
		public static function registerModule(targetClass:Class, preResList:Array,cacheEnabled:Boolean = false):void{
			if(!moduleInfoMap) moduleInfoMap = new Dictionary();
			var moduleCfgInfo:ModuleCfgInfo = new ModuleCfgInfo(targetClass,preResList,cacheEnabled);
			var targetClassName:String = BaseUT.getClassNameByObj(targetClass);
			moduleInfoMap[targetClassName] = moduleCfgInfo;
		}
		
		/**所有页面信息**/
		public static var allLayerMap:Dictionary;
		/**注册页面**/
		public static function registerLayer(targetClass:Class):void
		{
			if(!allLayerMap) allLayerMap = new Dictionary();
			allLayerMap[BaseUT.getClassNameByObj(targetClass)] = targetClass;
		}
		
		/**
		 * 获取指定模块信息
		 */
		public function getModuleInfo(moduleName: String):ModuleCfgInfo{
			return moduleInfoMap ? moduleInfoMap[moduleName] : null;
		}
		
		/**显示指定页面**/
		public function showLayer(targetClass:Class,data:* = null):UILayer{
			var layer: UILayer = BaseUT.createClassByName(targetClass) as UILayer;
			layer.name = BaseUT.getClassNameByObj(targetClass) + "_script";
			BaseUT.setFitSize(layer);
			if (data != null) layer.setData(data);
			layer.getParent().addChild(layer);
			BaseUT.setFitSize(layer.view);
			layer.onAddToLayer();
			return layer;
		}
		
	}
}
