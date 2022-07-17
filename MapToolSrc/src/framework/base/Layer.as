package framework.base
{

	public class Layer extends Emiter
	{
		protected static var _model:ModelFacade;
		public function Layer()
		{
			super();
			_model = Global.model;
			cCreated();
			onEnter_b();
			onEnter();
			onEnter_a();
		}
		
		protected function cCreated():void{
			
		}
		
		protected function onEnter_b():void{
			
		}
		
		protected function onEnter():void{
			
		}
		
		protected function onEnter_a():void{
			
		}
		
	
	}
}