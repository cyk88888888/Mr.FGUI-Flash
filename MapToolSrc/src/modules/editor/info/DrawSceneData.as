package modules.editor.info
{
	import flash.utils.Dictionary;

	/**
	 * 绘制地图的数据 
	 * @author Administrator
	 * 
	 */	
	public class DrawSceneData
	{
		
		public var gridPath:Dictionary;
		public var totLine:int;
		public var totCol:int;
		public var gridSize:int;
		public var jsonName:String;
		public var mapName:String;
		public var mapWid:Number;
		public var mapHei:Number;
		public var gridData:Dictionary;
		public var startIdx:int;
		public var anmEndIdx:int;
		public function DrawSceneData()
		{
			gridPath = new Dictionary();
			gridData = new Dictionary();	
		}
	}
}