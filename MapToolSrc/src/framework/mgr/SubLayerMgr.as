package framework.mgr
{
	import flash.utils.Dictionary;
	
	import framework.base.BaseUT;
	import framework.ui.UILayer;

	/**
	 * 子界面管理器 
	 * @author cyk
	 * 
	 */	
	public class SubLayerMgr
	{
		private var _classMap:Dictionary;
		private var _scriptMap: Dictionary;
		public var curLayer: UILayer;
		private var _popArr:Vector.<UILayer>;
		public function SubLayerMgr()
		{
			_classMap = new Dictionary();
			_scriptMap = new Dictionary();
			_popArr = new Vector.<UILayer>();
		}
		
		/**
		 * 注册子页面
		 * @param layerName 
		 */
		public function register(targetClass:Class, opt:* = null):void
		{
			_classMap[BaseUT.getClassNameByObj(targetClass)] = targetClass;
		}
		
		/**显示指定页面（替换模式）*/
		public function run(targetClass:Class, data:* = null):void
		{
			_show(targetClass, data);
		}
		
		/**显示指定界面（入栈模式） */
		public function push(targetClass:Class, data:* = null):void
		{
			_show(targetClass, data, true);
		}
		
		private function _show(targetClass:Class, data:*, toPush:Boolean = false):void
		{
			var layerName: String = BaseUT.getClassNameByObj(targetClass);
			if (curLayer != null && curLayer.className == layerName) return;//打开同个界面
			
			var registerLayer:* = _classMap[targetClass];
			var needDestory:Boolean = registerLayer == null && !toPush;//未注册 && 非入栈模式
			
			checkDestoryLastLayer(needDestory);
			
			if (curLayer != null)
			{
				if (toPush) _popArr.push(curLayer);
				if (toPush || !needDestory)
				{
					curLayer.removeSelf();
				}
			}
			
			if (_scriptMap[layerName])
			{
				curLayer = _scriptMap[layerName];
				curLayer.addSelfToOldParent();
				return;
			}
			
			curLayer = ModuleMgr.inst.showLayer(targetClass,data);
			if (_classMap[layerName] != null)
			{
				_scriptMap[layerName] = curLayer;
			}
		}
		
		/**判断销毁上个界面并释放资源*/
		private function checkDestoryLastLayer(destory:Boolean = false):void
		{
			if (destory && curLayer != null && !curLayer.hasDestory)
			{
				curLayer.close();
			}
		}
		
		/** layer出栈*/
		public function pop():void
		{
			if (_popArr.length <= 0)
			{
				throw new Error("已经pop到底了！！！");
				return;
			}
			checkDestoryLastLayer(true);
			curLayer = _popArr.pop();
			curLayer.addSelfToOldParent();
		}
		
		/**清楚所有注册的layer */
		public function ReleaseAllLayer():void
		{
			checkDestoryLastLayer(true);
			for each (var item:UILayer in _popArr)
			{
				if (!item.hasDestory) item.close();
			}
			
			for each (item in _scriptMap)
			{
				if (!item.hasDestory)
				{
					item.close();
				}
			}
			
			_popArr = new Vector.<UILayer>();
		}
		
		public function dispose():void
		{
			ReleaseAllLayer();
			_classMap = null;
			_popArr = null;
		}
	}
}