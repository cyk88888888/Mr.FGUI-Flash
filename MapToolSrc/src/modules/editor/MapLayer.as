package modules.editor
{
	import framework.base.Global;
	import framework.base.Layer;
	import framework.base.NtfyName;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import fairygui.GComponent;
	import fairygui.GLoader;
	import fairygui.GRoot;
	import fairygui.UIPackage;
	import fairygui.event.GTouchEvent;
	
	import modules.editor.info.DrawSceneData;
	import modules.editor.model.EditorConst;
	
	/**
	 * 
	 * @author CYK
	 * 
	 */	
	public class MapLayer extends Layer
	{
		private var _view:GComponent;
		private var _mapBg:GLoader;
		private var _lineSprite:LineSprite;
		private var _gridContainer:Sprite;//格子线和填充格子颜色的容器
		
		public function MapLayer()
		{
		}
		
		override protected function cCreated():void{
			_view = UIPackage.createObject("Editor", "MapLayer").asCom;
			GRoot.inst.addChild(_view);
			_gridContainer = new Sprite();
			_view.displayListContainer.addChild(_gridContainer);
			_mapBg = _view.getChild("imgBg").asLoader;
			_mapBg.icon = UIPackage.getItemURL("Editor",EditorConst.BgRes[0][2]);
			_mapBg.addSizeChangeCallback(onImgBgSizeChange);
			_view.addClickListener(onViewClick);
			_view.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, rightDown);
			_view.addEventListener(MouseEvent.RIGHT_MOUSE_UP, rightUp);
			_view.addEventListener(MouseEvent.MOUSE_MOVE,mouseMove);
		}
		
		override protected function onEnter():void {
			onEmitter(NtfyName.UpdateBgRes,function(data:Object):void{//点击默认地图列表
				var res:String = EditorConst.BgRes[data.body.clickIdx][2];
				_mapBg.icon = UIPackage.getItemURL("Editor",res);
				//选其他地图时清空数据
				_model.editor.gridPathFillDic = new Dictionary();
				_model.editor.gridDataFillDic = new Dictionary();
				_model.editor.gridDispFillDic = new Dictionary();
				_model.editor.gridAnmFillDic = new Dictionary();
				_model.editor.gridData = new Dictionary();
				_model.editor.curDrawSceneData=null;
				_model.editor.anmEndIdx = 0;
				_model.editor.startIdx = 0;
				_mapBg.setSize(4000,4000);
				if(_mapBg.width == _model.editor.mapSize.x && _mapBg.height == _model.editor.mapSize.y){
					setGrid(_model.editor.gridSize);
				}
			});
			
			onEmitter(NtfyName.UpdateGridStatus,function(data:Object):void{//线条和填充格子的显隐
				_gridContainer.visible = data.body.isShow;
			});
			
			onEmitter(NtfyName.UpdateResetGrid,function(data:Object):void{//重设格子大小
				setGrid(data.body.size);
			});
			
			onEmitter(NtfyName.DrawMapScene,function():void{//绘制导入json地图
				drawScene();
			});
			
			onEmitter(NtfyName.SetStartPoint,function():void{//设置起点
				drawStartGrid();
			})
			
			onEmitter(NtfyName.AddDataFillGrid,function():void{//保存格子数据时绘制填充方块
				var curClickGridIdx:int = _model.editor.curClickGridIdx;
				drawDataGrid(curClickGridIdx);
			});
			
			onEmitter(NtfyName.SetAnmStartPoint,function():void{//绘制神兽跟随起始点
				drawAnmStartGrid();
			});
		}
		
		//大地图宽高变更
		private function onImgBgSizeChange():void{
			_mapBg.setSize(4000,4000);
			if(!_model.editor.mapSize || (_model.editor.mapSize && _model.editor.mapSize.x!=_mapBg.width&& _model.editor.mapSize.y!=_mapBg.height)){
				setGrid();	
			}
		}
		
		
		/** 设置格子**/
		private function setGrid(size:int = EditorConst.GridSize):void{
			_model.editor.mapSize = new Point(4000,4000);
			_model.editor.gridPathFillDic = new Dictionary();
			_model.editor.gridDataFillDic = new Dictionary();
			_model.editor.gridDispFillDic = new Dictionary();
			_model.editor.gridAnmFillDic = new Dictionary();
			_model.editor.startIdx = 0;
			_model.editor.anmEndIdx = 0;
			if(_lineSprite){
				_lineSprite.parent.removeChild(_lineSprite);
			}
			_model.editor.gridSize = size;
			_lineSprite = new LineSprite(_mapBg.width,_mapBg.height,size);
			_gridContainer.addChild(_lineSprite);
			setGridData();
		}
		
		private var _isRightDown:Boolean;
		protected function rightDown(evt:Event):void
		{
			_isRightDown = true;
		}		
		
		protected function rightUp(event:Event):void
		{
			_isRightDown = false;
		}
		
		
		protected function mouseMove(evt:Event):void
		{
			if(_isRightDown){
				var mouseX:Number = Global.stage.mouseX;
				var mouseY:Number = Global.stage.mouseY;
				var girdInfo:Array = getGridInfo(mouseX,mouseY);
				var gridDic:Dictionary = _model.editor.gridPathFillDic;
				if(gridDic[girdInfo[0]]){//该格子已有填充颜色的格子
					return;
				}
				addOrRmGrid(mouseX,mouseY);
			}
		}
		
		/**
		 * 点击地图 
		 * @param evt
		 */		
		private function onViewClick(evt:GTouchEvent):void
		{
			if(_view.scrollPane.isDragged) return;
			var girdInfo:Array = getGridInfo(evt.stageX,evt.stageY);
			var idx:int = girdInfo[0];
			if(!_model.editor.gridData[idx] || !_model.editor.gridPathFillDic[idx]){//该格子没有数据 || 该格子没有可行走填充格子
				addOrRmGrid(evt.stageX,evt.stageY);
			}
		
			_lineSprite.drawSelectGraph(girdInfo[1], girdInfo[2]);//显示选中框
			emit(NtfyName.ClickGrid,{idx:idx});
			_model.editor.curClickGridIdx = idx;
		}
		
		/** 添加||删除填充颜色格子**/
		private function addOrRmGrid(mouseX:Number,mouseY:Number):void{
			var girdInfo:Array = getGridInfo(mouseX,mouseY);
			var girdIdx: int = girdInfo[0];
			var gridDic:Dictionary = _model.editor.gridPathFillDic;
			if(!gridDic[girdIdx]){
				var fillGrid:FillColorGrid = new FillColorGrid(girdInfo[1], girdInfo[2], _model.editor.gridSize);
				_lineSprite.gridPathCotainer.addChild(fillGrid);
				gridDic[girdIdx] = fillGrid;
			}else{
				_lineSprite.gridPathCotainer.removeChild(gridDic[girdIdx]);
				delete gridDic[girdIdx];
			}
		}
		
		/**
		 * [格子id索引，填充颜色格子的x，填充颜色格子的y,格子大小] 
		 * @param mouseX
		 * @param mouseY
		 * @return 
		 */		
		private function getGridInfo(mouseX:Number,mouseY:Number):Array{
			var size:int =_model.editor.gridSize;
			var scollH:Number = Math.abs(_view.displayListContainer.x);
			var scollV:Number = Math.abs(_view.displayListContainer.y);
			var totCol:int = Math.ceil(_mapBg.width/size);//总列数
			var pos:Array = getClickGridPos(mouseX + scollH,mouseY + scollV);
			var girdIdx:int = (pos[0]-1)*totCol + pos[1];
			return [girdIdx,(pos[1]-1)*size,(pos[0]-1)*size,size];
		}
		
		/**
		 * 根据点击位置获取点击的是哪个格子 
		 * @param x 点击地图的x
		 * @param y 点击地图的y
		 * @return [line,col] 
		 */		
		private function getClickGridPos(x:Number,y:Number):Array{
			var size:int =_model.editor.gridSize;
			var line:int = Math.ceil(y/size);//第几行
			var col:int = Math.ceil(x/size);//第几列
			return [line,col];
		}
		
		private function drawScene():void{
			var curDrawSceneData:DrawSceneData = _model.editor.curDrawSceneData;
			_mapBg.icon = UIPackage.getItemURL("Editor",curDrawSceneData.mapName);
			_model.editor.mapName =  curDrawSceneData.mapName;
			_model.editor.jsonName = curDrawSceneData.jsonName;
			if(_mapBg.width == curDrawSceneData.mapWid && _mapBg.height == curDrawSceneData.mapHei){//宽高一样的背景图不会触发onImgBgSizeChange
				setGrid(curDrawSceneData.gridSize);
			}
		}
		
		private function setGridData():void{
			var curDrawSceneData:DrawSceneData = _model.editor.curDrawSceneData;
			if(curDrawSceneData){
				var size:int;
				size = _model.editor.gridSize = curDrawSceneData.gridSize;
				var gridDic:Dictionary = _model.editor.gridPathFillDic;
				for(var idx:int in curDrawSceneData.gridPath){
					var posArr:Array = _model.editor.getGridXYByIdx(idx);
					var fillGrid:FillColorGrid = new FillColorGrid((posArr[1]-1)*size,(posArr[0]-1)*size,size);
					_lineSprite.gridPathCotainer.addChild(fillGrid);
					gridDic[idx] = fillGrid;
				}
			
				_model.editor.startIdx = curDrawSceneData.startIdx;
				_model.editor.gridData = curDrawSceneData.gridData;
				_model.editor.anmEndIdx = curDrawSceneData.anmEndIdx;
				drawStartGrid();
				drawAnmStartGrid();
				for(idx in curDrawSceneData.gridData){
					drawDataGrid(idx);
				}
			}
		}
		
		/** 绘制格子数据和形象显示位置的填充格子**/
		private function drawDataGrid(idx:int):void{
			var size:int = _model.editor.gridSize;
			var gridDataFillDic:Dictionary = _model.editor.gridDataFillDic;
			var gridDispFillDic:Dictionary = _model.editor.gridDispFillDic;
			var gridData:Dictionary = _model.editor.gridData;
			if(gridData[idx]){
				if(!gridDataFillDic[idx]){//显示格子数据的标识
					var gridInfo:Array = _model.editor.getGridXYByIdx(idx);
					var fillGrid:FillColorGrid = new FillColorGrid((gridInfo[1]-1)*size + (size - size/2)/2+1,(gridInfo[0]-1)*size+(size-size/2)/2+1, size/2,0x000000);
					_lineSprite.gridDataCotainer.addChild(fillGrid);
					gridDataFillDic[idx] = fillGrid;
				}
				if(!gridDispFillDic[idx]){//形象显示位置的标识
					var gridInfo1:Array = _model.editor.getGridXYByIdx(gridData[idx].dispIdx);
					var fillGrid11:FillColorGrid = new FillColorGrid((gridInfo1[1]-1)*size+1,(gridInfo1[0]-1)*size+1, size/4,0x0000FF);
					_lineSprite.gridDataCotainer.addChild(fillGrid11);
					gridDispFillDic[idx] = fillGrid11;
				}
				
			}else{
				if(gridDataFillDic[idx]){
					_lineSprite.gridDataCotainer.removeChild(gridDataFillDic[idx]);
					delete gridDataFillDic[idx];
				}
				if(gridDispFillDic[idx]){
					_lineSprite.gridDataCotainer.removeChild(gridDispFillDic[idx]);
					delete gridDispFillDic[idx];
				}
			}
		}
		
		/** 绘制起始点的填充格子**/
		private function drawStartGrid():void{
			var size:int = _model.editor.gridSize;
			var startIdx:int = _model.editor.startIdx;
			if(startIdx>0){
				var start:Array =_model.editor.getGridXYByIdx(startIdx);
				_model.editor.startFillColorGrid = new FillColorGrid((start[1]-1)*size+(size - size/4)+1,(start[0]-1)*size+(size - size/4)+1,size/4,0xFF0000);
				_lineSprite.gridDataCotainer.addChild(_model.editor.startFillColorGrid);
			}else{
				if(_model.editor.startFillColorGrid && _lineSprite.gridDataCotainer.contains(_model.editor.startFillColorGrid)){
					_lineSprite.gridDataCotainer.removeChild(_model.editor.startFillColorGrid);
				}
			}
		}
		
		private function drawAnmStartGrid():void{
			var size:int = _model.editor.gridSize;
			var startIdx:int = _model.editor.anmEndIdx;
			if(startIdx>0){
				var start:Array =_model.editor.getGridXYByIdx(startIdx);
				_model.editor.anmstartFillColorGrid = new FillColorGrid((start[1]-1)*size+(size - size/4)+1,(start[0]-1)*size+1,size/4,0xFF00FF);
				_lineSprite.gridDataCotainer.addChild(_model.editor.anmstartFillColorGrid);
			}else{
				if(_model.editor.anmstartFillColorGrid && _lineSprite.gridDataCotainer.contains(_model.editor.anmstartFillColorGrid)){
					_lineSprite.gridDataCotainer.removeChild(_model.editor.anmstartFillColorGrid);
				}
			}
		}
		
		public function get width():Number{
			return _view.width;
		}
		
	}
}