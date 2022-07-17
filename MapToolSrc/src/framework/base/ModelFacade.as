package framework.base
{
	import flash.utils.Dictionary;
	
	import modules.editor.model.EditorModel;

	public class ModelFacade
	{
		private var _instanceMap:Dictionary;
		
		public function ModelFacade()
		{
			_instanceMap = new Dictionary();
		}
		public function getModelInstance(cls:Class):* {
			if (cls == null) {
				return null;
			}
			var instance:* = _instanceMap[cls];
			if (instance == null) {
				_instanceMap[cls] = instance = new cls();
			}
			return instance;
		}
		public function get editor():EditorModel {
			return getModelInstance(EditorModel);
		}
	}
}