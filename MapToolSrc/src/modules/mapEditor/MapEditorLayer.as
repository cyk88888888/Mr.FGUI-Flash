package modules.mapEditor
{
	import fairygui.GButton;
	import fairygui.GTextInput;
	import fairygui.event.GTouchEvent;
	
	import framework.ui.UILayer;
	
	import modules.base.Enum;
	import modules.base.GameEvent;
	import modules.mapEditor.conctoller.MapMgr;
	

	public class MapEditorLayer extends UILayer
	{
		protected override function get pkgName():String
		{
			return "MapEditor";
		}
		
		private var txt_cellSize:GTextInput;
		private var txt_mapWidth:GTextInput;
		private var txt_mapHeight:GTextInput;
		
		protected override function onEnter():void{
			txt_cellSize = view.getChild("txt_cellSize").asTextInput;
			txt_cellSize.text = MapMgr.inst.cellSize.toString();
			
			txt_mapWidth = view.getChild("txt_mapWidth").asTextInput;
			txt_mapWidth.text = MapMgr.inst.mapWidth.toString();
			
			txt_mapHeight = view.getChild("txt_mapHeight").asTextInput;
			txt_mapHeight.text = MapMgr.inst.mapHeight.toString();
			
			var btn_walk:GButton = view.getChild("btn_walk").asButton;
			btn_walk.addClickListener(_tap_btn_walk);
			
			var btn_block:GButton = view.getChild("btn_block").asButton;
			btn_block.addClickListener(_tap_btn_block);
			
			var btn_blockVert:GButton = view.getChild("btn_blockVert").asButton;
			btn_blockVert.addClickListener(_tap_btn_blockVert);
			
			var btn_water:GButton = view.getChild("btn_water").asButton;
			btn_water.addClickListener(_tap_btn_water);
			
			var btn_clearWalk:GButton = view.getChild("btn_clearWalk").asButton;
			btn_clearWalk.addClickListener(_tap_btn_clearWalk);
			
			var btn_clearBolck:GButton = view.getChild("btn_clearBolck").asButton;
			btn_clearBolck.addClickListener(_tap_btn_clearBolck);
			
			var btn_clearBolckVert:GButton = view.getChild("btn_clearBolckVert").asButton;
			btn_clearBolckVert.addClickListener(_tap_btn_clearBolckVert);
			
			var btn_clearWater:GButton = view.getChild("btn_clearWater").asButton;
			btn_clearWater.addClickListener(_tap_btn_clearWater);
			
			var btn_resizeGrid:GButton = view.getChild("btn_resizeGrid").asButton;
			btn_resizeGrid.addClickListener(_tap_btn_resizeGrid);
			
			var btn_resizeMap:GButton = view.getChild("btn_resizeMap").asButton;
			btn_resizeMap.addClickListener(_tap_btn_resizeMap);
			
			var btn_toCenter:GButton = view.getChild("btn_toCenter").asButton;
			btn_toCenter.addClickListener(_tap_btn_toCenter);
			
			var btn_originalScale:GButton = view.getChild("btn_originalScale").asButton;
			btn_originalScale.addClickListener(_tap_btn_originalScale);
			
			var btn_exportJson:GButton = view.getChild("btn_exportJson").asButton;
			btn_exportJson.addClickListener(_tap_btn_exportJson);
			
			var btn_importJson:GButton = view.getChild("btn_importJson").asButton;
			btn_importJson.addClickListener(_tap_btn_importJson);
			
			var btn_clearAll:GButton = view.getChild("btn_clearAll").asButton;
			btn_clearAll.addClickListener(_tap_btn_clearAll);
			
			var btn_runDemo:GButton = view.getChild("btn_runDemo").asButton;
			btn_runDemo.addClickListener(_tap_btn_runDemo);
			
			onEmitter(GameEvent.ImportMapJson, onImportMapJson);
		}
		
		private function onImportMapJson(data:Object):void
		{
			txt_mapWidth.text = MapMgr.inst.mapWidth.toString();
			txt_mapHeight.text = MapMgr.inst.mapHeight.toString();
			txt_cellSize.text = MapMgr.inst.cellSize.toString();
		}
		
		private function _tap_btn_walk(evt:GTouchEvent):void{
			emit(GameEvent.ChangeGridType, [Enum.Walk]);
		}
		
		private function _tap_btn_block(evt:GTouchEvent):void{
			emit(GameEvent.ChangeGridType, [Enum.Block]);
		}
		private function _tap_btn_blockVert(evt:GTouchEvent):void{
			emit(GameEvent.ChangeGridType, [Enum.BlockVerts]);
		}
		private function _tap_btn_water(evt:GTouchEvent):void{
			emit(GameEvent.ChangeGridType, [Enum.Water]);
		}
		private function _tap_btn_clearWalk(evt:GTouchEvent):void{
			emit(GameEvent.ClearGridType, [Enum.Walk]);
		}
		private function _tap_btn_clearBolck(evt:GTouchEvent):void{
			emit(GameEvent.ClearGridType, [Enum.Block ]);
		}
		private function _tap_btn_clearBolckVert(evt:GTouchEvent):void{
			emit(GameEvent.ClearGridType, [Enum.BlockVerts]);
		}
		private function _tap_btn_clearWater(evt:GTouchEvent):void{
			emit(GameEvent.ClearGridType, [Enum.Water]);
		}
		private function _tap_btn_resizeGrid(evt:GTouchEvent):void{
			emit(GameEvent.ResizeGrid, [txt_cellSize.text]);
		}
		private function _tap_btn_resizeMap(evt:GTouchEvent):void{
			emit(GameEvent.ResizeMap, [txt_mapWidth.text, txt_mapHeight.text]);
		}
		private function _tap_btn_toCenter(evt:GTouchEvent):void{
			emit(GameEvent.ToCenter);
		}
		private function _tap_btn_originalScale(evt:GTouchEvent):void{
			emit(GameEvent.ToOriginalScale);
		}
		private function _tap_btn_exportJson(evt:GTouchEvent):void{
			MapMgr.inst.exportJsonData();
		}
		private function _tap_btn_importJson(evt:GTouchEvent):void{
			MapMgr.inst.importJsonData();
		}
		private function _tap_btn_clearAll(evt:GTouchEvent):void{
			emit(GameEvent.ClearAllData);
		}
		private function _tap_btn_runDemo(evt:GTouchEvent):void{
			emit(GameEvent.RunDemo);
		}
	}
}