package framework.base
{
	import flash.display.Stage;

	public class Global
	{
		public static var stage:Stage;
		public static var emmiter:Emiter;
		private static var _model:ModelFacade;
		public static function get model():ModelFacade{
			if(_model==null){
				_model = new ModelFacade();
			}
			return _model;
		}
	}
}