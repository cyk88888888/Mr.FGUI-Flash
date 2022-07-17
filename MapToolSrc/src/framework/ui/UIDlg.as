package framework.ui
{
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import fairygui.GButton;
	import fairygui.GComponent;
	import fairygui.GRoot;
	import framework.mgr.SceneMgr;
	
	/**
	 * 弹窗基类
	 * @author cyk
	 * 
	 */
	public class UIDlg extends UILayer
	{
		/** 灰色背景是否可点击**/
		protected var isBgMaskClick:Boolean = true;
		/** 打开页面时是否需要动画**/
		protected var needOpenAnimation:Boolean = true;
		private var bgMask:Sprite; 
		/** 点击弹窗关闭按钮方法回调**/
		public var onClickBtnClose:Function;
		public override function getParent():GComponent
		{
			return SceneMgr.inst.curScene.dlg;
		}
		
		public override function onAddToLayer():void
		{
			bgMask = new Sprite();
			bgMask.graphics.beginFill(0x000000,0.4);
			bgMask.graphics.drawRect(0,0,GRoot.inst.width, GRoot.inst.height);
			bgMask.graphics.endFill();
			if(isBgMaskClick) bgMask.addEventListener(MouseEvent.CLICK, onBgMaskClick);
			this.displayListContainer.addChildAt(bgMask, 0);
			var frame:GComponent = view.getChild("frame") ? view.getChild("frame").asCom : null;
			var btn_close:GButton = frame ? frame.getChild("closeButton").asButton : null;
			if(btn_close){
				btn_close.addClickListener(function():void{
					if(onClickBtnClose) onClickBtnClose.call(this);
					close();
				});
			}
			
			if(needOpenAnimation) OnOpenAnimation();
		}
		
		private function onBgMaskClick(evt:MouseEvent):void{
			close();
		}
		
		protected override function doClose():void{
			if(isBgMaskClick) bgMask.removeEventListener(MouseEvent.CLICK,onBgMaskClick);
		}
		
		protected override function OnOpenAnimation():void
		{
			view.setPivot(0.5, 0.5);
			var timeline:TimelineLite = new TimelineLite();
			timeline.append(new TweenLite(view, 0.15, {scaleX: 1.1,scaleY:1.1}));
			timeline.append(new TweenLite(view, 0.15, {scaleX: 1,scaleY:1}));
			timeline.play();
		}
	}
}