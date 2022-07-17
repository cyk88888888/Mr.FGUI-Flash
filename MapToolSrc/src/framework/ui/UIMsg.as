package framework.ui
{
	import fairygui.GComponent;
	
	import framework.mgr.SceneMgr;

	public class UIMsg extends UILayer
	{
		public override function getParent():GComponent
		{
			return SceneMgr.inst.curScene.msg;
		}
	}
}