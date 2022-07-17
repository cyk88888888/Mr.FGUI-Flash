package modules.common
{
	import fairygui.GButton;
	import fairygui.GTextField;
	import framework.ui.UIDlg;
	import modules.common.info.MsgBoxInfo;
	/**
	 * 消息提示弹窗
	 * @author cyk
	 * 
	 */
	public class MsgBoxDlg extends UIDlg
	{
		protected override function get pkgName():String
		{
			return "Common";
		}
		protected override function ctor():void
		{
			isBgMaskClick = false;
		}
		
		protected override function onEnter():void
		{
			var info:MsgBoxInfo = __data as MsgBoxInfo;
			var txt_msg:GTextField = view.getChild("txt_msg").asTextField;
			var btn_ok:GButton = view.getChild("btn_ok").asButton;
			btn_ok.addClickListener(function():void{
				if(info.onOk) info.onOk.call(this);
				close();
			});
			var btn_cancel:GButton = view.getChild("btn_cancel").asButton;
			btn_cancel.addClickListener(function():void{
				if(info.onCancel) info.onCancel.call(this);
				close();
			});
			onClickBtnClose = function():void{
				if(info.onCancel) info.onCancel.call(this);
			}
			txt_msg.text = info.msg;
			btn_ok.visible = info.onOk != null;
			btn_cancel.visible = info.onCancel != null;
		}
	}
}
