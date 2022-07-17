package modules.mapEditor
{
	import com.greensock.TweenMax;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import fairygui.GComponent;
	import fairygui.GGraph;
	import fairygui.GLoader;
	import fairygui.ScrollPane;
	
	import framework.base.Global;
	import framework.base.ObjectPool;
	import framework.mgr.ModuleMgr;
	import framework.ui.UIComp;
	
	import modules.base.Enum;
	import modules.base.GameEvent;
	import modules.common.JuHuaDlg;
	import modules.common.mgr.MsgMgr;
	import modules.mapEditor.conctoller.MapMgr;

	public class MapComp extends UIComp
	{
		private var grp_setSize:GComponent;
		private var grp_container:GComponent;
		private var lineContainer:GComponent;
		private var gridContainer:GComponent;
		private var graph_remind:GGraph;
		private var pet:GLoader;
		private var bg:GGraph;
		private var center:GGraph;
		private var _cellSize:int;
		private var _gridType:String = Enum.None;//格子类型
		private var _gridCompPool:ObjectPool;
		private var lineShape:Shape;//线条shape
		private var gridSprite: Sprite;//格子容器
		private var speed:int = 3;//角色移动速度
		private var _isRightDown:Boolean;
		private var curScale:Number = 1;
		private var scaleDelta:Number = 0.03;
		protected override function onFirstEnter():void
		{
			grp_setSize = view.getChild("grp_setSize").asCom;
			grp_container = view.getChild("grp_container").asCom;
			graph_remind = grp_container.getChild("graph_remind").asGraph;
			lineContainer = grp_container.getChild("lineContainer").asCom;
			gridContainer = grp_container.getChild("gridContainer").asCom;
			bg = grp_container.getChild("bg").asGraph;
			pet = grp_container.getChild("pet").asLoader;
			center = grp_container.getChild("center").asGraph;
			_gridCompPool = new ObjectPool(
				function():Shape{ 
					return new Shape();
				},
				function(obj: Shape):void { obj.parent.removeChild(obj); }
			);
			view.addEventListener(MouseEvent.CLICK, onClick);
			view.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightDown);
			view.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onRightUp);
			view.addEventListener(MouseEvent.MOUSE_MOVE,mouseMove);
			view.addEventListener(MouseEvent.MOUSE_WHEEL,onMouseWheel);
			_cellSize = MapMgr.inst.cellSize;
			lineShape = new Shape();
			lineContainer.displayListContainer.addChild(lineShape);
			gridSprite = new Sprite();
			gridContainer.displayListContainer.addChild(gridSprite);
			init();
		}
		
		protected override function onEnter():void{
			onEmitter(GameEvent.ChangeGridType, onChangeGridType);
			onEmitter(GameEvent.ClearGridType, onClearGridType);
			onEmitter(GameEvent.ImportMapJson, onImportMapJson);
			onEmitter(GameEvent.ResizeGrid, onResizeGrid);
			onEmitter(GameEvent.ResizeMap, onResizeMap);
			onEmitter(GameEvent.RunDemo, onRunDemo);
			onEmitter(GameEvent.CloseDemo, onCloseDemo);
			onEmitter(GameEvent.ToCenter, onToCenter);
			onEmitter(GameEvent.ToOriginalScale, onToOriginalScale);
			onEmitter(GameEvent.ClearAllData, onClearAllData);
		}
		
		private function init(isResizeMap:Boolean = false):void{
			var mapWidth:int = MapMgr.inst.mapWidth;
			var mapHeight:int = MapMgr.inst.mapHeight;
			var numCols:int = Math.ceil(mapWidth / _cellSize);
			var numRows:int = Math.ceil(mapHeight / _cellSize);
			trace("行：" + numRows + "列：" + numCols);
			if(!isResizeMap){
				onToOriginalScale(null);
				removeAllGrid();
			}
			center.setXY((MapMgr.inst.mapWidth - center.width) / 2, (MapMgr.inst.mapHeight - center.height) / 2);
			bg.setSize(mapWidth, mapHeight);
			
			lineShape.graphics.clear();
			lineShape.graphics.lineStyle(1,0x000000);
		
			//画横线
			for(var i:int = 0; i < numRows; i++){
				lineShape.graphics.moveTo(0, i * _cellSize);
				lineShape.graphics.lineTo(mapWidth, i * _cellSize);
			}
			
			//画列线
			for(var j:int = 0; j < numCols; j++){
				lineShape.graphics.moveTo(j * _cellSize, 0);
				lineShape.graphics.lineTo(j * _cellSize, mapHeight);
			}
		}
		
		/** 清除所有格子**/
		private function removeAllGrid():void
		{
			while(gridSprite.numChildren > 0){
				_gridCompPool.releaseObject(gridSprite.getChildAt(0));
			}
			MapMgr.inst.gridTypeDic = new Dictionary();
		}
		/** 格子大小变化**/
		private function onResizeGrid(data:Object): void
		{
			var cellSize:int = data.body[0];
			if (cellSize == MapMgr.inst.cellSize)
			{
				MsgMgr.ShowMsg("格子大小没有变化！！！");
				return;
			}
			_cellSize = cellSize;
			MapMgr.inst.cellSize = cellSize;
			init();
		}
		
		private function onChangeGridType(data:Object): void
		{
			var gridType:String = data.body[0];
			_gridType = gridType;
		}
		
		private function onRightDown(evt:MouseEvent): void
		{
			if (_gridType == Enum.None)
			{
				MsgMgr.ShowMsg("请先选择格子类型!!!");
				return;
			}
			_isRightDown = true;
		}
		
		protected function onRightUp(event:MouseEvent):void
		{
			_isRightDown = false;
		}
		private var _oldGridKey: String;
		protected function mouseMove(evt:MouseEvent):void
		{
			
			if(_isRightDown){
				if (_gridType == Enum.None) return;
				var gridPosX:int = Math.floor((Global.stage.mouseX + view.scrollPane.posX) / (_cellSize * curScale));//格子所在的列
				var gridPosY:int =  Math.floor((Global.stage.mouseY + view.scrollPane.posY) / (_cellSize * curScale))//格子所在的行
				var gridKey:String = gridPosX + "_" + gridPosY;
				if (_oldGridKey == gridKey) return;//在同一个格子
				_oldGridKey = gridKey;
				addOrRmGrid();
			}
		}
		
		private var oldClickPos:Point;
		private function onClick(evt:MouseEvent):void
		{
			if (_gridType == Enum.None)
			{
				MsgMgr.ShowMsg("请先选择格子类型!!!");
				return;
			}
			
			addOrRmGrid();
		}
		
		private function addOrRmGrid():void
		{
			if (_gridType == Enum.None) return;
			var gridPosX:int = Math.floor((Global.stage.mouseX + view.scrollPane.posX) / (_cellSize * curScale));//格子所在的列
			var gridPosY:int =  Math.floor((Global.stage.mouseY + view.scrollPane.posY) / (_cellSize * curScale))//格子所在的行
			var gridX:int = gridPosX * _cellSize;//绘制颜色格子的坐标X
			var gridY:int = gridPosY * _cellSize;//绘制颜色格子的坐标Y
			if (gridX >= MapMgr.inst.mapWidth || gridY >= MapMgr.inst.mapHeight) return;
			getGrid(_gridType, gridPosX, gridPosY, gridX, gridY);
		}
		
		private function getGrid(gridType:String, gridPosX:int,gridPosY:int, gridX:int, gridY:int):void
		{
			if(!MapMgr.inst.gridTypeDic[gridType]) MapMgr.inst.gridTypeDic[gridType] = new Dictionary();
			var curGridTypeDic:Dictionary = MapMgr.inst.gridTypeDic[gridType];
			var gridKey:String = gridPosX + "_" + gridPosY;
			var gridComp:Shape;
			if (curGridTypeDic[gridKey])
			{
				_gridCompPool.releaseObject(curGridTypeDic[gridKey]);
				delete curGridTypeDic[gridKey];
				return;
			}
			var color:Number = MapMgr.inst.getColorByType(gridType);
			gridComp = _gridCompPool.getObject() as Shape;
			gridComp.graphics.clear();
			gridComp.graphics.beginFill(color,0.5);
			if(gridType == Enum.BlockVerts){
				gridComp.graphics.drawCircle(gridX + _cellSize/2,gridY +_cellSize/2,_cellSize/2);
			}else{
				gridComp.graphics.drawRect(gridX + 0.5,gridY + 0.5,_cellSize,_cellSize);
			}
			gridComp.graphics.endFill();
			gridSprite.addChild(gridComp);
			curGridTypeDic[gridKey] = gridComp;
		}
		
		private function onClearGridType(data:Object):void
		{
			var gridType:String = data.body[0];
			if(!MapMgr.inst.gridTypeDic[gridType]) return;
			var curGridTypeDic:Dictionary = MapMgr.inst.gridTypeDic[gridType];
			for (var key: String in curGridTypeDic)
			{
				_gridCompPool.releaseObject(curGridTypeDic[key]);
				delete MapMgr.inst.gridTypeDic[gridType];
			}
		}
		/**导入地图json数据**/
		private function onImportMapJson(data:Object):void
		{
			var juahua:JuHuaDlg = ModuleMgr.inst.showLayer(JuHuaDlg) as JuHuaDlg;
			var mapInfo:Object = data.body[0];
			_cellSize = mapInfo.cellSize;
			init();
			/** 设置可行走节点**/
			for (var i:int = 0; i < mapInfo.walkList.length; i++)
			{
				var lineList: Array = mapInfo.walkList[i];
				for (var j:int = 0; j < lineList.length; j++)
				{
					if (lineList[j] == 1)
					{
						var gridPosX: int = j;//所在格子位置x
						var gridPosY: int = i;//所在格子位置y
						var gridX:int = gridPosX * _cellSize;//绘制颜色格子的坐标X
						var gridY:int = gridPosY * _cellSize;//绘制颜色格子的坐标Y
						getGrid(Enum.Walk, gridPosX, gridPosY, gridX, gridY);
					}
				}
			}
			
			/** 设置障碍物节点**/
			AddBlockByType(Enum.Block);
			AddBlockByType(Enum.BlockVerts);
			AddBlockByType(Enum.Water);
			function AddBlockByType(gridType: String):void
			{
				var blockList:Array = [];
				if (gridType == Enum.Block) blockList = mapInfo.blockList;
				else if (gridType == Enum.BlockVerts) blockList = mapInfo.blockVertList;
				else if (gridType == Enum.Water) blockList = mapInfo.waterList;
				for each (var item:Object in blockList)
				{
					var gridPosX: int//所在格子位置x
					var gridPosY: int//所在格子位置y
					if(item is Array){
					 	gridPosX = item[0];
						gridPosY = item[1];
					}else{
						var xy:Array = MapMgr.inst.getGridXYByIdx(int(item));
						gridPosX = xy[0];
						gridPosY = xy[1];
					}
					
					var gridX:int = gridPosX * _cellSize;//绘制颜色格子的坐标X
					var gridY:int = gridPosY * _cellSize;//绘制颜色格子的坐标Y
					getGrid(gridType, gridPosX, gridPosY, gridX, gridY);
				}
			}
			juahua.close();
		}
		
		private function onToCenter(data:Object):void
		{
			var scrollPane: ScrollPane = view.scrollPane;
			scrollPane.setPosX(center.x * curScale - scrollPane.viewWidth / 2 + center.width / 2 * curScale, true);
			scrollPane.setPosY(center.y * curScale - scrollPane.viewHeight / 2 + center.height / 2 * curScale, true);
		}
		
		private function onMouseWheel(evt:MouseEvent):void
		{
			var scrollPane:ScrollPane = view.scrollPane;
			if (evt.delta < 0)//缩小
			{
				if (Math.floor(grp_setSize.width) <= view.viewWidth && Math.floor(grp_setSize.height) <= view.viewHeight) return; ;//已全部可见
				curScale -= scaleDelta;
			}
			else
			{
				if (Math.floor(grp_setSize.width) >= MapMgr.inst.mapWidth && Math.floor(grp_setSize.height) >= MapMgr.inst.mapHeight) return;//已达到原大小
				curScale += scaleDelta;
			}
			updateContainerSizeXY();
			
			scrollPane.setPosX(scrollPane.scrollingPosX * curScale, false);
			scrollPane.setPosY(scrollPane.scrollingPosY * curScale, false);
		}
		
		private function updateContainerSizeXY():void
		{
			grp_container.setScale(curScale, curScale);
			grp_setSize.setSize(curScale * MapMgr.inst.mapWidth, curScale * MapMgr.inst.mapHeight);
		}
		
		private function onToOriginalScale(data:Object):void
		{
			curScale = 1;
			grp_container.setScale(curScale, curScale);
			grp_setSize.setSize(curScale * MapMgr.inst.mapWidth, curScale * MapMgr.inst.mapHeight);
		}
		
		private function onClearAllData(data:Object):void
		{
			var existData:Boolean = false;
			for(var key:String in MapMgr.inst.gridTypeDic){
				for(var subKey: String in MapMgr.inst.gridTypeDic[key]){
					existData = true;
					break;
				}
				if(existData) break;
			}
			MsgMgr.ShowMsg("数据已全部清除！！！");
			if(existData) init();
		}
		
		private function onCloseDemo(data:Object):void
		{
			pet.visible = false;
		}
		
		private function onRunDemo(data:Object):void
		{
			pet.visible = true;
		}
		
		/** 重置地图大小**/
		private function onResizeMap(data: Object):void
		{
			var mapWidth:int = data.body[0];
			var mapHeight:int = data.body[1];
			if (mapWidth == MapMgr.inst.mapWidth && mapHeight == MapMgr.inst.mapHeight)
			{
				MsgMgr.ShowMsg("地图大小未发生变化！！！");
				return;
			}
			
			var isReduce:Boolean = false;//是否减小地图
			if (mapWidth < MapMgr.inst.mapWidth || mapHeight < MapMgr.inst.mapHeight)//地图变小时，需要检测减小部分是否有已画格子数据，有的话不让改地图大小
			{
				isReduce = true;
				var isCanResizeMap:Boolean = true;//是否可减小地图
				for each(var item:Dictionary in MapMgr.inst.gridTypeDic)
				{
					var isExistGrid:Boolean = false;
					for each (var subItem:Shape in item)
					{
						if (subItem.x >= mapWidth || subItem.y >= mapHeight)
						{
							isExistGrid = true;
							break;
						}
					}
					if (isExistGrid)
					{
						isCanResizeMap = false;
						break;
					}
				}
				
				if (!isCanResizeMap)
				{
					MsgMgr.ShowMsg("地图减少部分包含已画格子数据，请检查！！！");
				
					TweenMax.killTweensOf(graph_remind);
					graph_remind.alpha = 1;
					graph_remind.visible = true;
					graph_remind.setSize(mapWidth, mapHeight);
					TweenMax.to(graph_remind,0.3,{alpha: 0.4,onComplete:function():void{
						graph_remind.visible = false;
						graph_remind.setSize(0, 0);
					}});
					return;
				}
			}
			MapMgr.inst.mapWidth = mapWidth;
			MapMgr.inst.mapHeight = mapHeight;
			init(true);
		}
	}
}