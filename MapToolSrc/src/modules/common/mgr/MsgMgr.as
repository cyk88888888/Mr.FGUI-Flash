package modules.common.mgr
{
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Ease;
	import com.greensock.easing.Elastic;
	
	import fairygui.GComponent;
	import fairygui.GTextField;
	import fairygui.UIPackage;
	import fairygui.tween.EaseType;
	import fairygui.tween.GTween;
	
	import framework.mgr.ModuleMgr;
	import framework.mgr.SceneMgr;
	
	import modules.base.Enum;
	import modules.common.MsgBoxDlg;
	import modules.common.info.MsgBoxInfo;

	public class MsgMgr
	{
		public function MsgMgr()
		{
		}
		
		public static function ShowMsg(msg: String, msgType: String = Enum.Msg_Normal, onOk:Function = null, onCancel:Function = null):void
		{
			if (msgType == Enum.Msg_Normal)
			{
				var msgTip:GComponent = UIPackage.createObject("Common", "MsgTip").asCom;
				var txt_msg:GTextField = msgTip.getChild("txt_msg").asTextField;
				txt_msg.text = msg;
				if (txt_msg.textWidth > 300) msgTip.width = txt_msg.textWidth + 20;
				SceneMgr.inst.curScene.msg.addChild(msgTip);
				msgTip.setXY((msgTip.parent.width - msgTip.width) / 2, (msgTip.parent.height - msgTip.height) / 2 - 200);
				
				TweenMax.to(msgTip, 0.3, {y:msgTip.y - 100,delay: 0.5,onComplete: function():void{
					msgTip.dispose();
				}});
			}
			else if (msgType == Enum.Msg_MsgBox)
			{
				ModuleMgr.inst.showLayer(MsgBoxDlg, new MsgBoxInfo(msg, onOk, onCancel));
			}
		}
	}
}