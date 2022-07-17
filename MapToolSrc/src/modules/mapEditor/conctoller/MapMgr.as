package modules.mapEditor.conctoller
{
	import flash.utils.Dictionary;
	
	import framework.base.FileUT;
	import framework.base.Global;
	
	import modules.base.Enum;
	import modules.base.GameEvent;
	import modules.common.mgr.MsgMgr;

	public class MapMgr
	{
		private static var _inst: MapMgr;
		public static function get inst():MapMgr
		{
			if(!_inst){
				_inst = new MapMgr();
			}
			return _inst;
		}
		
		public var mapWidth:int = 4000;//地图宽
		public var mapHeight:int = 4000;//地图高
		public var cellSize:int = 40;//格子大小
		public const extensionJson:String = ".json";//保存数据后缀
		public var gridTypeDic:Dictionary;//格子数据
		
		/**根据格子类型获取颜色**/
		public function getColorByType(type:String):Number
		{
			var color:Number = 0xFFFFFF;
			switch (type)
			{
				case Enum.Walk:
					color = 0x00FF00;
					break;
				case Enum.Block:
					color = 0x000000;
					break;
				case Enum.BlockVerts:
					color = 0xFF0000;
					break;
				case Enum.Water:
					color = 0x00FFFF;
					break;
			}
			return color;
		}
		
		/**
		 * 根据格子idx获取格子所在的行列 
		 * @param idx
		 * @return 
		 * 
		 */		
		public function getGridXYByIdx(idx:Number):Array{
			var size:int = cellSize;
			var totLine:int = Math.ceil(mapHeight/size);//总行数
			var totCol:int = Math.ceil(mapWidth/size);//总列数
			var line:int =Math.floor(idx/totLine);
			var col:int = idx % totLine;;
			return [col,line];
		}
		
		/**
		 * 根据格子列行获取格子所在的idx 
		 * @param x 列
		 * @param y 行
		 * @return 
		 * 
		 */			
		public function getGridIdxByXY(x:int,y:int):int{
			var size:int = cellSize;
			var totLine:int = Math.ceil(mapHeight/size);//总行数
			var totCol:int = Math.ceil(mapWidth/size);//总列数
			var idx:int = y * totCol + x;
			return idx;
		}
		
		/** 导入json地图数据**/
		public function importJsonData():void{
			FileUT.inst.openFileBrowerAndReturn( "*.json", function(content:String):void{
				var mapInfo:Object = JSON.parse(content);
				mapWidth = mapInfo.mapWidth;
				mapHeight = mapInfo.mapHeight;
				cellSize = mapInfo.cellSize;
				Global.emmiter.emit(GameEvent.ImportMapJson, [mapInfo]);
			});
		}
		
		/** 导出json地图数据**/
		public function exportJsonData():void{
			FileUT.inst.saveFileBrower(function(path:String):void{
				var splitPath:Array = path.split(".");
				if(splitPath.length == 1 || splitPath[splitPath.length - 1]!="json"){
					MsgMgr.ShowMsg("请保存文件名后缀为.json！！！");
					return;
				}
				var fullPath:String = path;//保存的json文件数据完整地址
				var mapInfo:MapJsonInfo = new MapJsonInfo();
				mapInfo.mapWidth = mapWidth;
				mapInfo.mapHeight = mapHeight;
				mapInfo.cellSize = cellSize;
				/** 设置行走区域**/
				var numCols:int = Math.ceil(mapWidth / cellSize);//列
				var numRows:int = Math.ceil(mapHeight / cellSize);//行
				
				mapInfo.totRow = numRows;
				mapInfo.totCol = numCols;
				for (var i:int = 0; i < numRows; i++)
				{
					var linewalkList:Array = [];//每一行
					mapInfo.walkList.push(linewalkList);
					for (var j:int = 0; j < numCols; j++)
					{
						var walkGridDic:Dictionary = gridTypeDic[Enum.Walk];
						if (!walkGridDic)
						{
							linewalkList.push(0);
						}
						else
						{
							var gridItem:Object = walkGridDic[j + "_" + i];
							linewalkList.push(gridItem != null ? 1 : 0);
						}
					}
				}
				
				/** 设置障碍物**/
				AddBlockByType(Enum.Block);
				AddBlockByType(Enum.BlockVerts);
				AddBlockByType(Enum.Water);
				function AddBlockByType(gridType: String):void
				{
					var blockGridDic:Dictionary = gridTypeDic[gridType];
					if (blockGridDic != null)
					{
						for (var key:String in blockGridDic)
						{
							var newList:Array = [];
							if (gridType == Enum.Block) newList = mapInfo.blockList;
							else if(gridType == Enum.BlockVerts) newList = mapInfo.blockVertList;
							else if (gridType == Enum.Water) newList = mapInfo.waterList;
							var splitArr:Array = key.split("_");
							newList.push(getGridIdxByXY(int(splitArr[0]), int(splitArr[1])));
						}
					}
				}
				
				FileUT.inst.writeAllText(path, JSON.stringify(mapInfo), function():void{
					MsgMgr.ShowMsg("导出成功!!!");
				})
				
			})
		}
		
	}
}