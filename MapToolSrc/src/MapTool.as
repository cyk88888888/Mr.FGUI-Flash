package
{
	import com.common.util.KeyMgr;
	import com.core.loader.LoadQueue;
	import com.core.loader.LoaderMgr;
	import com.core.loader.ResContent;
	import com.simpvmc.NotifierBase;
	import com.simpvmc.SyncEventDispatcher;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import fairygui.GLoader;
	import fairygui.GRoot;
	import fairygui.UIConfig;
	import fairygui.UIObjectFactory;
	import fairygui.UIPackage;
	
	import framework.base.BaseUT;
	import framework.base.Emiter;
	import framework.base.Global;
	import framework.base.ScaleMode;
	import framework.mgr.SceneMgr;
	import modules.base.InitModule;
	/**
	 * 主入口
	 * @author CYK
	 * 
	 */
	[SWF(width=1550,height=910)]
	public class MapTool extends Sprite
	{
		private var _preResList:Array = ["assets/Common.zip"];//预载资源列表
		public function MapTool()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, this.oAddtoStage);
		}
		
		protected function oAddtoStage(event:Event):void
		{
			Global.stage=stage;
			NotifierBase.stage4ntfy = new SyncEventDispatcher();
			Global.emmiter = new Emiter();
			BaseUT.scaleMode = new ScaleMode(1550, 910, 910, 910);
			InitModule.init();
			stage.color = 0;
			stage.frameRate = 60;
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			var loadQueue:LoadQueue = new LoadQueue(_preResList, null, null, onQueueComplete);
			loadQueue.startLoad();
			KeyMgr.getInstance().init(stage);
		}
		
		private function onQueueComplete():void
		{
			for each(var item:String in _preResList){
				var res:ResContent = LoaderMgr.getInstance().getResource(item);
				UIPackage.addPackage(ByteArray(res.content), null);
			}
			//Register custom loader class
			UIObjectFactory.setLoaderExtension(GLoader);
			UIConfig.defaultScrollBounceEffect = true;
			UIConfig.defaultScrollTouchEffect = true;
			//等待图片资源全部解码，也可以选择不等待，这样图片会在用到的时候才解码
			UIPackage.waitToLoadCompleted(continueInit);
		
		}
		
		private function continueInit():void {
			stage.addChild(GRoot.inst.displayObject);
			SceneMgr.inst.run("MapEditorScene");
		}
		
	}
	
	
}