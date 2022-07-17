package framework.ui
{
	import fairygui.GComponent;
	import framework.mgr.SceneMgr;
	/**
	 * 界面基类 
	 * @author cyk
	 * 
	 */	
	public class UILayer extends UIComp
	{
		/**关闭页面回调**/
		public var onCloseCb:Function;
		public function getParent():GComponent
		{
			return SceneMgr.inst.curScene.layer;
		}
		
		public function onAddToLayer():void { }
		
		/**打开页面时的动画 */
		protected function OnOpenAnimation():void { }
		/**关闭页面时的动画 */
		protected function onCloseAnimation(callback:Function):void
		{
			if (callback != null) callback.call(this);;
		}
		
		public function close():void
		{
			onCloseAnimation(function():void{
				doClose();
				if(onCloseCb) onCloseCb.call(this);
				__dispose();
				destory();
			});
		}
		
		protected function doClose():void{}
		
	}
}