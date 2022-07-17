package framework.ui
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import fairygui.GComponent;
	import fairygui.GObject;
	import fairygui.UIPackage;
	
	import framework.base.BaseUT;
	import framework.base.Global;
	import framework.mgr.ModuleMgr;
	/**
	 * 组件基类
	 * @author cyk
	 * 
	 */
	public class UIComp extends GComponent
	{
		public var view: GComponent;
		private var _oldParent:GComponent;
		public var __data:Object = null;
		private var isFirstEnter:Boolean = true;
		public var hasDestory:Boolean = false;
		private var needCreateView:Boolean = true;
		private var childCompDic: Dictionary;
		private var _msgHandler:Object = {};
		public function UIComp()
		{
			ctor_b();
			ctor();
			ctor_a();
			this.addEventListener(Event.ADDED_TO_STAGE, oAddtoStage);
		}
		
		/** 包名**/
		protected function get pkgName():String
		{
			return "";
		}
		
		protected function ctor_b():void { }
		protected function ctor():void  { }
		protected function ctor_a():void  { }
		
		protected function onEnter_b():void  { }
		protected function onEnter():void  { }
		protected function onFirstEnter():void  { }
		protected function onEnter_a():void  { }
		
		protected function dchg():void  { }
		
		protected function onExit_b():void  { }
		protected function onExit():void  { }
		protected function onExit_a():void  { }
		
		private function oAddtoStage(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, oAddtoStage);
			if (!needCreateView) return;
			_oldParent = parent;
			if (pkgName == "")
			{
				throw new Error("请先在对应界面重写pkgName和compName字段！！！");
			}
			var compSkin: GComponent = UIPackage.createObject(pkgName, className).asCom;
			addChild(compSkin);
			setView(compSkin);
		}
		
		public function setView(_view: GComponent):void
		{
			view = _view;
			setSize(view.viewWidth, view.viewHeight);
			__doEnter();
		}
		
		public function __doEnter():void
		{
			trace("进入" + className);
			onEnter_b();
			onEnter();
			if (isFirstEnter)
			{
				isFirstEnter = false;
				onFirstEnter();
			}
			onEnter_a();
			InitProperty();
		}
		
		protected function InitProperty():void
		{
			var children:Vector.<GObject> = view.children;
			if (childCompDic == null) childCompDic = new Dictionary();
			for (var i:int = 0; i < children.length; i++)
			{
				var item: GObject = children[i];
				if (item is GComponent && item.packageItem)
				{
					var itemName:String = item.name;
					var typeClss:* = ModuleMgr.allLayerMap[item.packageItem.name];
					if (typeClss != null)
					{
						var childComp_Script: UIComp;
						if (!childCompDic[item.name])
						{
							childComp_Script = BaseUT.createClassByName(typeClss);
							childComp_Script.name = itemName + "_script";
							childComp_Script.needCreateView = false;
							childCompDic[item.name] = childComp_Script;
						}
						childComp_Script.setView(item as GComponent);
					}
				}
			}
		}
		
		public function get className():String
		{
			return 	BaseUT.getClassNameByObj(this);
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
		
		public function setData(_data:*):void
		{
			if (_data == data) return;
			__data = _data;
			dchg();
		}
		
		/**
		 * 添加到指定父级
		 */
		public function setParent(parent: GComponent): void
		{
			_oldParent = parent;
			parent.addChild(this);
		}
		
		/** 添加到旧父级（用于界面回退管理，开发者请勿调用）**/
		public function addSelfToOldParent(): void
		{
			__doEnter();
			setParent(_oldParent);
		}
		
		/** 从父级移除（用于界面回退管理，开发者请勿调用）**/
		public function removeSelf(): void
		{
			__dispose();
			removeFromParent();
		}
		
		public function __dispose(): void
		{
			
			trace("退出: " + className);
			if (childCompDic != null)
			{
				for each(var item: UIComp in childCompDic){
					item.__dispose();
				}
				
			}
			unAll();
			
			onExit_b();
			onExit();
			onExit_a();
		}
		
		/** 销毁*/
		protected function destory(): void
		{
			if (hasDestory) return;
			hasDestory = true;
			
			for each (var item: UIComp in childCompDic)
			{
				item.destory();
			}
			
			trace("onDestroy: " + className);
			view.dispose();
			dispose();
		}
		
	}
}