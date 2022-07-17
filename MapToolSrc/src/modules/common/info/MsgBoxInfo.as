package modules.common.info
{
	public class MsgBoxInfo
	{
		public var msg:String;
		public var onOk:Function;
		public var onCancel:Function;
		public function MsgBoxInfo(_msg: String, _onOk:Function = null, _onCancel:Function = null)
		{
			msg = _msg;
			onOk = _onOk;
			onCancel = _onCancel;
		}
	}
}