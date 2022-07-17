package framework.base
{
	import com.simpvmc.Notification;
	import com.simpvmc.NotifierBase;
	
	import flash.utils.Dictionary;

	/**
	 * 消息发射器 
	 * @author CYK
	 * 
	 */	
	public class Emiter extends NotifierBase
	{
		private var _msgHandler:Dictionary = new Dictionary();

		public function Emiter()
		{
		}
		
		protected function registerN():void {
			
		}
		
		public function emit(event:String,data:Object = null):void{
			NotifierBase.globalNotify(event,data);
		}
		
		public function onEmitter(ntfyName:String, proc:Function):void {
			if(!_msgHandler[ntfyName]){
				_msgHandler[ntfyName] = [];
			}
			_msgHandler[ntfyName].push(proc);
			stage4ntfy.addEventListener(/*Notification.MvC_ + */ntfyName, onMvCMessage);
		}
		
		public function un(ntfName:String):void {
			delete _msgHandler[ntfName];
			stage4ntfy.removeEventListener(/*Notification.MvC_ + */ntfName, onMvCMessage);
		}
		
		public function unAll():void {
			for (var ntfName:String in _msgHandler) {
				delete _msgHandler[ntfName];
				stage4ntfy.removeEventListener(/*Notification.MvC_ + */ntfName, onMvCMessage);
			}
		}
		
		public function onMvCMessage(ntfy:Notification):void {
			var msgHandlers:Array = _msgHandler[ntfy.name];
			if (msgHandlers != null) {
				for(var i: int= 0;i<msgHandlers.length;i++){
					msgHandlers[i](ntfy);
				}
			}
		}
	}
}