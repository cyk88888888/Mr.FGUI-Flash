package framework.ui
{
	import fairygui.GComponent;
	
	import framework.mgr.SceneMgr;

	public class UIMenu extends UILayer
	{
		public override function getParent():GComponent
		{
			return SceneMgr.inst.curScene.menuLayer;
		}
	}
}