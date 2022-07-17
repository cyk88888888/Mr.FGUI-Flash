package modules.editor.info
{
	public class ExportDataInfo
	{
		public var gridPath:Array;
		public var totLine:int;
		public var totCol:int;
		public var gridSize:int;
		public var jsonName:String;
		public var mapName:String;
		public var mapWid:Number;
		public var mapHei:Number;
		public var startIdx:int;
		public var anmEndIdx:int;
		public var gridData:Vector.<GridDataInfo>;
		
		public function ExportDataInfo()
		{
			gridPath = [];
			gridData = new Vector.<GridDataInfo>();
		}
	}
	
}