package framework.mgr
{
	import com.core.loader.LoadQueue;
	import com.core.loader.LoaderMgr;
	import com.core.loader.ResContent;
	
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import fairygui.GRoot;
	import fairygui.UIPackage;
	
	import framework.base.BaseUT;
	import framework.base.ModuleCfgInfo;
	import framework.ui.UIScene;
	
	public class SceneMgr
	{
		private static var _inst: SceneMgr;
		public static function get inst():SceneMgr
		{
			if(!_inst){
				_inst = new SceneMgr();
			}
			
			return _inst;
		}
		
		public function SceneMgr()
		{
			_popArr = new Vector.<UIScene>();
		}
		
		private var _popArr:Vector.<UIScene>;
		
		/**当前场景**/
		public var curScene: UIScene;
		public var curSceneName: String;
		private var _curOpenSceneData:Object;
		/**打开场景（替换模式）**/
		public function run(sceneName:String, data:* = null):void
		{
			showScene(sceneName, data);
		}
		
		/**
		 * 打开场景（入栈模式）
		 */
		public function push(sceneName:String, data:* = null):void
		{
			showScene(sceneName, data, true);
		}
		
		private function showScene(sceneName:String, data:* = null, toPush:Boolean = false):void
		{
			var self:SceneMgr = this;
			if (curScene != null && curScene.className == sceneName) return;//相同场景
			var moduleInfo:ModuleCfgInfo = ModuleMgr.inst.getModuleInfo(sceneName);
			if (moduleInfo == null)
			{
				throw new Error("未注册模块：" + sceneName);
			}
			curSceneName = sceneName;
			if (moduleInfo.preResList != null)
			{
				var loadQueue:LoadQueue = new LoadQueue(moduleInfo.preResList, null, null, function():void{
					onQueueLoaded.call(self, moduleInfo, data, toPush);
				});
				loadQueue.startLoad();
			}
			else
			{
				onUILoaded(moduleInfo, data, toPush);
			}
			
		}
		
		private function onQueueLoaded(moduleInfo: ModuleCfgInfo, data:*, toPush:Boolean):void{
			for each(var item:String in moduleInfo.preResList){
				var res:ResContent = LoaderMgr.getInstance().getResource(item);
				UIPackage.addPackage(ByteArray(res.content), null);
			}
			onUILoaded(moduleInfo, data, toPush);
		}
		
		private function onUILoaded(moduleInfo: ModuleCfgInfo, data:*, toPush:Boolean): void
		{
			if (toPush && curScene != null)
			{
				_popArr.push(curScene);
				curScene.removeSelf();
			}
			else
			{
				checkDestoryLastScene(!toPush);
			}
			
			curScene = new moduleInfo.targetClass();
			curScene.name = moduleInfo.name;
			var size:Point = BaseUT.setFitSize(curScene);
			curScene.setXY((GRoot.inst.width - size.x) / 2, (GRoot.inst.height - size.y) / 2);
			GRoot.inst.addChild(curScene);
			if (data != null) curScene.setData(data);
		}
		
		/**判断销毁上个场景并释放资源 */
		private function checkDestoryLastScene(destory:Boolean = false):void
		{
			if (curScene != null)
			{
				var lastModuleInfo:ModuleCfgInfo = ModuleMgr.inst.getModuleInfo(curScene.name);
				if (destory)
				{//销毁上个场景
					curScene.close();
					if (!lastModuleInfo.cacheEnabled && lastModuleInfo.preResList!=null)
					{
						for each (var item:String in lastModuleInfo.preResList)
						{
							UIPackage.removePackage(item);
						}
						
					}
				}
			}
		}
		
		/** 返回到上个场景*/
		public function pop():void
		{
			if (_popArr.length <= 0)
			{
				throw new Error("已经pop到底了！！！！！！！");
				return;
			}
			checkDestoryLastScene(true);
			
			curScene = _popArr.pop();
			curSceneName = curScene.name;
			curScene.addSelfToOldParent();
		}
		
	}
}