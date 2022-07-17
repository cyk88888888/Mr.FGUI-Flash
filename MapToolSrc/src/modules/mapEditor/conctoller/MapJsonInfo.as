package modules.mapEditor.conctoller
{
	public class MapJsonInfo
	{
		public var mapWidth:int;//地图宽
		public var mapHeight:int;//地图高
		public var totRow:int;//总行数
		public var totCol:int;//总列数
		public var cellSize:int;//格子大小
		public var walkList: Array;//可行走和不可行走列表，1为可行走，0为不可行走
		public var blockList :Array;//墙壁格子列表
		public var blockVertList:Array;//墙壁顶点格子列表
		public var waterList:Array;//水域格子列表
		public function MapJsonInfo()
		{
			walkList = [];
			blockList = [];
			blockVertList = [];
			waterList = [];
		}
	}
}