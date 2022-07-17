package modules.base
{
	import framework.mgr.ModuleMgr;
	
	import modules.common.JuHuaDlg;
	import modules.common.MsgBoxDlg;
	import modules.mapEditor.MapComp;
	import modules.mapEditor.MapEditorLayer;
	import modules.mapEditor.MapEditorScene;
	
	/**
	 *初始化模块信息 
	 * @author cyk
	 * 
	 */
	public class InitModule
	{
		public static function init():void{
			registerModule();
			registerLayer();
		}
		
		/** 注册模块scene**/
		private static function registerModule(): void{
			ModuleMgr.registerModule(MapEditorScene,["assets/MapEditor.zip"]);
		}
		
		/** 注册页面（所有显示界面和组件都必须在这里注册）**/
		private static function registerLayer():void{
			var allLayerArr:Array = [
				MapEditorLayer,
				MapComp,
				JuHuaDlg,
				MsgBoxDlg,
			]
				
			for(var i:int = 0;i<allLayerArr.length;i++){
				ModuleMgr.registerLayer(allLayerArr[i]);
			}
		}
	}
}