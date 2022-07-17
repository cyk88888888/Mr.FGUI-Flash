package modules.mapEditor
{
	import framework.ui.UIScene;

	public class MapEditorScene extends UIScene
	{
		protected override function ctor():void
		{
			mainClassLayer = MapEditorLayer;
			var classList:Array = [];
			for each (var item:Class in classList)
			{
				subLayerMgr.register(item);
			}
		}
		
	}
}