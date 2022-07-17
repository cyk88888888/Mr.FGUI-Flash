package modules.editor.model
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import modules.editor.FillColorGrid;
	import modules.editor.info.DrawSceneData;
	import modules.editor.info.ExportDataInfo;
	import modules.editor.info.GridData;
	import modules.editor.info.GridDataInfo;
	import modules.message.Message;
	
	public class EditorModel
	{
		public var curFilterJsonNameArr:Array;
		
		public var savePath:String;
		private var _openfile:File;
		public function EditorModel()
		{
			gridData = new Dictionary();
		}
		/** [idx: FillColorGrid]当前可行走区域填充颜色的格子map**/
		public var gridPathFillDic:Dictionary;
		/** [idx: FillColorGrid]当前有配置格子数据填充颜色的格子map**/
		public var gridDataFillDic:Dictionary;
		/** [idx: FillColorGrid]当前形象显示填充颜色的格子map**/
		public var gridDispFillDic:Dictionary;
		/** [idx: FillColorGrid]当前神兽跟随填充颜色的格子map**/
		public var gridAnmFillDic:Dictionary;
		/** [idx: GridData]格子数据 **/
		public var gridData:Dictionary;
		public var startIdx:int;//当前地图起始位置
		public var anmEndIdx:int;//当前神兽跟随起始点idx数组
		public var startFillColorGrid:FillColorGrid;
		public var anmstartFillColorGrid:FillColorGrid;
		public var gridSize:int;//当前格子规格小（默认25x25）
		public var mapSize:Point = new Point();//当前地图大小(x表示宽，y表示高)
		public var jsonName:String;//json文件名称
		public var mapName:String;//当前地图名称
		public var curClickGridIdx:int;//当前点击的地图格子idx
		public var curInportJsonArr:Array;
		/**导出地图json数据**/
		public function exportMapJson():void{
			if(savePath==null){
				_openfile=new File();
				_openfile.addEventListener(Event.SELECT,SelectOpenFileFun);
				_openfile.addEventListener(Event.CANCEL,SelectOpenFileFun);
				_openfile.browseForDirectory("请选择保存路径");
			}else{
				analyzeGridDataToJson();
			}
			
		}
		
		/**写入json数据**/
		private function analyzeGridDataToJson():void{
			var exportData:ExportDataInfo = new ExportDataInfo();
			var totLine:int = Math.ceil(mapSize.y/gridSize);//总行数
			var totCol:int = Math.ceil(mapSize.x/gridSize);//总列数
			
			for(var i:int = 0; i < totLine; i++){
				var tempArr:Array = [];
				for(var j:int = 0;j < totCol; j++){
					var idx:int = i*totCol + (j+1);	
					if(gridPathFillDic[idx]){
						tempArr.push(1);
					}else{
						tempArr.push(1);
					}
				}
				exportData.gridPath.push(tempArr);
			}
			
			exportData.totLine = totLine;
			exportData.totCol = totCol;
			exportData.gridSize = gridSize;
			exportData.mapName = mapName;
			exportData.jsonName = jsonName;
			exportData.mapWid = mapSize.x;
			exportData.mapHei = mapSize.y;
			exportData.startIdx = startIdx;
			exportData.anmEndIdx = anmEndIdx;
			for(var key:int in gridData){
				var info:GridDataInfo = new GridDataInfo();
				info.idx = key;
				info.dispIdx = gridData[key].dispIdx;
				info.chapterId_eventId = gridData[key].chapterIdStrs.split(",");
				exportData.gridData.push(info);
			}
			
			var json:String = JSON.stringify(exportData);
			var _toSaveFullPath:String=savePath+"/"+jsonName+".json";
			var file:File = new File(_toSaveFullPath);
			var fs:FileStream = new FileStream();
			fs.open(file,FileMode.WRITE);
			fs.writeUTFBytes(json);
			fs.close();	
			Message.show("导出成功");
		}
		
		private function SelectOpenFileFun(evt:Event):void
		{
			if(evt.type==Event.SELECT)
			{
				savePath=evt.currentTarget.nativePath;
				analyzeGridDataToJson();
			}
		}
		
		/**保存格子数据**/
		public function saveGridData(dispIdxStrs:String,chapterIdStrs:String):void{
			if(!curClickGridIdx){
				Message.show("请先选择要设置数据的格子");
				return;
			}
			var obj:GridData;
			if(chapterIdStrs!=""){
				obj = new GridData();
				obj.chapterIdStrs = chapterIdStrs;
				var dispIdx:int = curClickGridIdx;
				if(dispIdxStrs != ""){
					if(dispIdxStrs.indexOf(",") == -1){
						Message.show("请输入正确格式的形象显示行列");
						return;
					}
					var dispIdxArr:Array = dispIdxStrs.split(",");
					dispIdx = getGridIdxByXY([int(dispIdxArr[0]),int(dispIdxArr[1])]);
				}
				
				obj.dispIdx = dispIdx;
			}
			if(obj){
				gridData[curClickGridIdx] = obj;
			}else{
				if(gridData[curClickGridIdx]) delete gridData[curClickGridIdx];
			}
			Message.show("保存格子数据成功");
		}
		
		/**
		 * 根据格子idx获取格子所在的行列 
		 * @param idx
		 * @return 
		 */		
		public function getGridXYByIdx(idx:Number):Array{
			var size:int =gridSize;
			var totLine:int = Math.ceil(mapSize.y/size);//总行数
			var totCol:int = Math.ceil(mapSize.x/size);//总列数
			var line:int = Math.ceil(idx/totCol);
			var col:int = line == 1 ? idx : idx - (line - 1)*totCol;
			return [line,col];
		}
		
		/**
		 * 根据格子行列获取格子所在的idx 
		 * @param idx
		 * @return 
		 */		
		public function getGridIdxByXY(xy:Array):int{
			var size:int =gridSize;
			var x:int = xy[0],y:int = xy[1];
			var totLine:int = Math.ceil(mapSize.y/size);//总行数
			var totCol:int = Math.ceil(mapSize.x/size);//总列数
			var idx:int = (x-1)*totCol + y;
			return idx;
		}
		
		
		public var curDrawSceneData:DrawSceneData;
		/**解析json数据**/
		public function analyzeJson(content:Object):Object{ 
			var resultArr:Array=[];
			curDrawSceneData = new DrawSceneData();
			var objArr:Object = JSON.parse(String(content));
			var gridPath:Array = objArr.gridPath;
			var count:int = 0,i:int,j:int;
			for(i = 0;i<gridPath.length;i++){
				for(j =0;j<gridPath[i].length;j++){
					count++;
					if(gridPath[i][j]==1){
						curDrawSceneData.gridPath[count] = 1;
					}
				}
			}
			curDrawSceneData.totLine = objArr.totLine;
			curDrawSceneData.totCol = objArr.totCol;
			curDrawSceneData.gridSize = objArr.gridSize;
			curDrawSceneData.mapName = objArr.mapName;
			curDrawSceneData.jsonName = objArr.jsonName?objArr.jsonName:objArr.mapName;
			curDrawSceneData.mapWid = objArr.mapWid;
			curDrawSceneData.mapHei = objArr.mapHei;
			curDrawSceneData.startIdx = objArr.startIdx;
			curDrawSceneData.anmEndIdx = objArr.anmEndIdx;
			for(i = 0;i<objArr.gridData.length;i++){
				var gridData:Object = objArr.gridData[i];
				var obj:GridData = new GridData(); 
				obj.dispIdx = gridData.dispIdx ? gridData.dispIdx : gridData.idx;
				for(j = 0;j<gridData.chapterId_eventId.length;j++){
					var needBr:String = (j +1) == gridData.chapterId_eventId.length ? "":",";
					obj.chapterIdStrs += gridData.chapterId_eventId[j] + needBr;
				}
				
				curDrawSceneData.gridData[gridData.idx] = obj;
			}
			
			return objArr;
		}
		
	}
}