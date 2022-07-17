package framework.ui
{
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	import fairygui.GComponent;
	import fairygui.GRoot;
	
	import framework.base.BaseUT;
	import framework.base.Global;
	import framework.mgr.SceneMgr;
	import framework.mgr.SubLayerMgr;
	/**
	 * 场景基类
	 * @author cyk
	 * 
	 */
	public class UIScene extends GComponent
	{
		protected var subLayerMgr: SubLayerMgr;
		public var layer: GComponent;
		public var dlg: GComponent;
		public var msg: GComponent;
		public var menuLayer: GComponent;
		protected var mainClassLayer: Class;
		private var _isFirstEnter:Boolean = true;
		protected var _moduleParam: *;
		private var _msgHandler:Object = {};
		public function UIScene()
		{
			subLayerMgr = new SubLayerMgr();
			ctor_b();
			ctor();
			ctor_a();
			registerModuleClass();
			this.addEventListener(Event.ADDED_TO_STAGE, oAddtoStage);
		}
		
		protected function registerModuleClass():void { }
		protected function ctor_b():void { }
		protected function ctor():void  { }
		protected function ctor_a():void  { }
		
		protected function onEnter_b():void  { }
		protected function onEnter():void  { }
		protected function onFirstEnter():void  { }
		protected function onEnter_a():void  { }
		
		protected function onExit_b():void  { }
		protected function onExit():void  { }
		protected function onExit_a():void  { }
		
		private function oAddtoStage(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, oAddtoStage);
			initLayer();
			if (mainClassLayer != null)
			{
				subLayerMgr.register(mainClassLayer);
				push(mainClassLayer);
			}
		}
		
		private function initLayer():void
		{
			layer = addGCom2GRoot("UILayer");
			menuLayer = addGCom2GRoot("UIMenuLayer");
			dlg = addGCom2GRoot("UIDlg");
			msg = addGCom2GRoot("UIMsg");
			__doEnter();
		}
		
		private function addGCom2GRoot(name:String):GComponent
		{
			var newNode:GComponent = new GComponent();
			newNode.name = name;
			SceneMgr.inst.curScene.addChild(newNode);
			BaseUT.setFitSize(newNode);
			return newNode;
		}
		
		private function __doEnter():void
		{
			trace("进入" + className);
			onEnter_b();
			onEnter();
			if (_isFirstEnter)
			{
				_isFirstEnter = false;
				onFirstEnter();
			}
			onEnter_a();
		}
		
		public function setData(data:*):void
		{
			_moduleParam = data;
		}
		
		protected function emit(event:String,data:Object = null):void{
			Global.emmiter.emit(event,data);
		}
		
		protected function onEmitter(ntfyName:String, proc:Function):void {
			_msgHandler[ntfyName] = proc;
			Global.emmiter.onEmitter(ntfyName,proc);
		}
		
		protected function unEmitter(ntfName:String):void {
			delete _msgHandler[ntfName];
			Global.emmiter.un(ntfName);
		}
		
		private function unAll():void {
			for (var ntfName:String in _msgHandler) {
				delete _msgHandler[ntfName];
				unEmitter(ntfName);
			}
		}
		
		public function get className():String
		{
			return 	BaseUT.getClassNameByObj(this);
		}
		
		/**重置到主界面 */
		public function resetToMain():void
		{
			releaseAllLayer();
			push(mainClassLayer, null);
		}
		
		/**显示指定页面（替换模式）*/
		public function run(targetClass:Class, data:* = null):void
		{
			subLayerMgr.run(targetClass, data);
		}
		
		/**显示指定界面（入栈模式） */
		public function push(targetClass:Class, data:* = null):void
		{
			subLayerMgr.push(targetClass, data);
		}
		
		/**layer出栈*/
		public function pop():void
		{
			subLayerMgr.pop();
		}
		
		/** 添加到旧父级（用于界面回退管理，开发者请勿调用）**/
		public function addSelfToOldParent():void
		{
			for each (var item:GComponent in children)
			{
				eachChildByParent(item as GComponent, true);
			}
			__doEnter();
			GRoot.inst.addChild(SceneMgr.inst.curScene);
		}
		/** 从父级移除（用于界面回退管理，开发者请勿调用）**/
		public function removeSelf():void
		{
			for each (var item:GComponent in children)
			{
				eachChildByParent(item as GComponent);
			}
			_dispose();
			SceneMgr.inst.curScene.removeFromParent();
		}
		
		/**�������layer */
		private function releaseAllLayer():void
		{
			subLayerMgr.ReleaseAllLayer();
		}
		
		private function _dispose():void
		{
			unAll();
			trace("退出" + className);
			onExit_b();
			onExit();
			onExit_a();
		}
		
		private function eachChildByParent(_parent:GComponent, isEnter:Boolean = false):void
		{
			for each (var item:UIComp in _parent.children)
			{
				if (isEnter)
				{
					(item as UIComp).__doEnter();
				}
				else
				{
					(item as UIComp).__dispose();
				}
			}
		}
		
		private function destory():void
		{
			subLayerMgr.dispose();
			subLayerMgr = null;
			trace("onDestroy: " + className);
			dispose();
		}
		
		public function close():void
		{
			_dispose();
			destory();
		}

		
		
	}
}