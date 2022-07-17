package modules.editor
{
	import framework.base.Global;
	import framework.base.Layer;
	import framework.base.NtfyName;
	import com.core.loader.LoaderMgr;
	import com.core.loader.ResContent;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	
	import fairygui.GButton;
	import fairygui.GComponent;
	import fairygui.GGraph;
	import fairygui.GList;
	import fairygui.GObject;
	import fairygui.GRoot;
	import fairygui.GTextField;
	import fairygui.GTextInput;
	import fairygui.UIPackage;
	import fairygui.event.ItemEvent;
	
	import modules.dlg.GridResetDlg;
	import modules.editor.info.GridData;
	import modules.editor.model.EditorConst;
	import modules.message.Message;
	
	public class MapMenu extends Layer
	{
		private var _view:GComponent;
		private var _listMap:GList;
		private var _curClickItem:GButton;
		private var _btn_gridStatus:GButton;
		private var _btn_resetGrid:GButton;
		private var _txt_girdSize:GTextField;
		private var _btn_setStartPos:GButton;
		private var _txt_dispIdx:GTextInput;
		private var _btn_setAnmStartPos:GButton;
		
		private var _gridStatus:int = 1;//1显示格子，2隐藏格子
		private var _btn_export:GButton;
		private var _btn_resetPath:GButton;
		private var _txt_chapter:GTextInput;
		private var _txt_curGrid:GTextField;
		private var _btn_saveGridData:GButton;
		private var _btn_map:GButton;
		private var _btn_inport:GButton;
		private var _listJsonMap:GList;
		private var openfile:File;
		private var openfileArr:Array=new Array();
		
		public function MapMenu()
		{
		}
		
		override protected function cCreated():void{
			_view = UIPackage.createObject("Editor", "MapMenu").asCom;
			GRoot.inst.addChild(_view);
			
			_txt_girdSize = _view.getChild("txt_girdSize").asTextField;
			_txt_chapter = _view.getChild("txt_chapter").asTextInput;
			_txt_dispIdx = _view.getChild("txt_dispIdx").asTextInput;
			_txt_curGrid = _view.getChild("txt_curGrid").asTextField;
			
			_txt_chapter.singleLine = _txt_dispIdx.singleLine = _txt_curGrid.singleLine = true;
			_btn_gridStatus = _view.getChild("btn_gridStatus").asButton;
			_btn_gridStatus.addClickListener(onBtnClick);
			
			_btn_resetGrid = _view.getChild("btn_resetGrid").asButton;
			_btn_resetGrid.addClickListener(onBtnClick);
			
			_btn_export = _view.getChild("btn_export").asButton;
			_btn_export.addClickListener(onBtnClick);
			
			_btn_inport = _view.getChild("btn_inport").asButton;
			_btn_inport.addClickListener(onBtnClick);
			
			_btn_resetPath = _view.getChild("btn_resetPath").asButton;
			_btn_resetPath.addClickListener(onBtnClick);
			
			_btn_saveGridData = _view.getChild("btn_saveGridData").asButton;
			_btn_saveGridData.addClickListener(onBtnClick);
			
			_btn_setStartPos = _view.getChild("btn_setStartPos").asButton;
			_btn_setStartPos.addClickListener(onBtnClick);
			
			_btn_setAnmStartPos = _view.getChild("btn_setAnmStartPos").asButton;
			_btn_setAnmStartPos.addClickListener(onBtnClick);
			
			_listMap = _view.getChild("listMap").asList;
			_listMap.addEventListener(ItemEvent.CLICK, clickMapItem);
			_listMap.itemRenderer = renderMapItem;
			_listMap.numItems=EditorConst.BgRes.length;
			
			_listJsonMap = _view.getChild("listJsonMap").asList;
			_listJsonMap.addEventListener(ItemEvent.CLICK, clickJsonMapItem);
			_listJsonMap.itemRenderer = renderJsonMapItem;
			
			openfile=new File();
			openfile.addEventListener(Event.SELECT,SelectOpenFileFun);
			openfile.addEventListener(Event.CANCEL,SelectOpenFileFun);
			
		}
		
		override protected function onEnter():void{
			onEmitter(NtfyName.UpdateBgRes,function(data:Object):void{
				_txt_curGrid.text = "请点击要设置数据的格子";
				
			});
			onEmitter(NtfyName.UpdateResetGrid,function(data:Object):void{
				_txt_girdSize.text = "格子大小: " + data.body.size;
			});
			
			onEmitter(NtfyName.ClickGrid,function(data:Object):void{
				var index:int = data.body.idx;
				var gridPos:Array = _model.editor.getGridXYByIdx(index);
				_txt_curGrid.text = "当前设置数据的格子index: "+index+"\n"+"行: " + gridPos[0]+",列: " + gridPos[1];
				var gridData:GridData = _model.editor.gridData[index];
				if(gridData){
					_txt_chapter.text = gridData.chapterIdStrs ? gridData.chapterIdStrs :"";
					var dispIdxStr:String = "";
					if(gridData.dispIdx){
						var xy:Array = _model.editor.getGridXYByIdx(gridData.dispIdx);
						dispIdxStr = xy[0] + "," + xy[1];
					}
					_txt_dispIdx.text = dispIdxStr;
				}else{
					_txt_chapter.text = _txt_dispIdx.text = "";
				}
			});
			
			_txt_girdSize.text = "格子大小: " + EditorConst.GridSize;
			_txt_curGrid.text = "请点击要设置数据的格子";
		}
		
		private function renderMapItem(index:int, obj:GObject):void
		{
			var button:GButton = GButton(obj);
			var txt_name:GTextField = button.getChild("txt_name").asTextField;
			var img_select:GGraph = button.getChild("img_select").asGraph;
			txt_name.text = EditorConst.BgRes[index][0];
			img_select.visible = index==0;
			if(index == 0) {
				_curClickItem = button;
				_model.editor.jsonName = EditorConst.BgRes[index][1];
				_model.editor.mapName = EditorConst.BgRes[index][2];
			}
		}
		
		private function renderJsonMapItem(index:int, obj:GObject):void{
			var button:GButton = GButton(obj);
			var txt_name:GTextField = button.getChild("txt_name").asTextField;
			var img_select:GGraph = button.getChild("img_select").asGraph;
			txt_name.text = _model.editor.curInportJsonArr[index].name;
			img_select.visible = false;
		}
		
		private function clickMapItem(evt:ItemEvent):void
		{
			var button:GButton = GButton(evt.itemObject);
			var parent:GList = button.parent.asList;
			var clickIdx:int = parent.getChildIndex(button);
			if(_curClickItem == button) return;
			if(_curClickItem) _curClickItem.getChild("img_select").asGraph.visible = false;
			_curClickItem=evt.itemObject as GButton;
			_curClickItem.getChild("img_select").asGraph.visible = true;
			_model.editor.jsonName = EditorConst.BgRes[clickIdx][1];
			_model.editor.mapName = EditorConst.BgRes[clickIdx][2];
			Global.emmiter.emit(NtfyName.UpdateBgRes,{clickIdx:clickIdx});
		}
		
		
		private function onBtnClick(evt:Event):void
		{
			switch(evt.currentTarget)
			{
				case _btn_gridStatus://格子显隐
					_gridStatus = _gridStatus == 1 ? 2: 1;
					emit(NtfyName.UpdateGridStatus,{isShow:_gridStatus == 1});
					break;
				case _btn_resetGrid://重设格子大小
					new GridResetDlg().show();
					break;
				case _btn_export://生成json数据
					_model.editor.exportMapJson();
					break
				case _btn_inport://导入json数据
					openfile.browseForDirectory("请选择Json地图配置文件夹");
					break;
				case _btn_resetPath://重置保存路径
					_model.editor.savePath = null;
					_model.editor.exportMapJson();
					break;
				case _btn_saveGridData://保存格子数据
					_model.editor.saveGridData(_txt_dispIdx.text,_txt_chapter.text);
					if(_model.editor.curClickGridIdx) emit(NtfyName.AddDataFillGrid);
					break;
				case _btn_setStartPos://设置为起点
					if(!_model.editor.curClickGridIdx){
						Message.show("请先选择要设置为起点的格子");
						return;
					}
					_model.editor.startIdx = _model.editor.curClickGridIdx;
					if(_model.editor.startFillColorGrid){
						_model.editor.startFillColorGrid.parent.removeChild(_model.editor.startFillColorGrid);
					}
					emit(NtfyName.SetStartPoint);
					break;
				case _btn_setAnmStartPos:
					if(!_model.editor.curClickGridIdx){
						Message.show("请先选择要设置为神兽跟随点的格子");
						return;
					}
					_model.editor.anmEndIdx = _model.editor.curClickGridIdx;
					if(_model.editor.anmstartFillColorGrid){
						_model.editor.anmstartFillColorGrid.parent.removeChild(_model.editor.anmstartFillColorGrid);
					}
					emit(NtfyName.SetAnmStartPoint);
					break;
			}
			
		}
		
		private function SelectOpenFileFun(evt:Event):void
		{
			if(evt.type==Event.SELECT)
			{
				openfileArr=evt.currentTarget.getDirectoryListing();	
				checkIsJsonMapCfg(openfileArr);
			}
		}
		
		/**检测是否是json地图的配置**/
		private function checkIsJsonMapCfg(flieArr:Array):void{
			_model.editor.curInportJsonArr = [];
			for(var i:uint=0;i<flieArr.length;i++)
			{
				var fileName:String=flieArr[i].name;
				if(flieArr[i].extension=="json"){
					_model.editor.curInportJsonArr.push({name:fileName.split(".")[0],path:flieArr[i].nativePath});
				}
			}
			_listJsonMap.numItems = _model.editor.curInportJsonArr.length;
		}
		
		private function clickJsonMapItem(evt:ItemEvent):void
		{
			var button:GButton = GButton(evt.itemObject);
			var parent:GList = button.parent.asList;
			var clickIdx:int = parent.getChildIndex(button);
			if(_curClickItem == button) return;
			if(_curClickItem) _curClickItem.getChild("img_select").asGraph.visible = false;
			_curClickItem=evt.itemObject as GButton;
			_curClickItem.getChild("img_select").asGraph.visible = true;
			_model.editor.gridPathFillDic = new Dictionary();
			var jsonPath:String = _model.editor.curInportJsonArr[clickIdx].path; 
			LoaderMgr.getInstance().removeResource(jsonPath);//点击json文件。先移除缓存里的资源，去重新加载
			LoaderMgr.getInstance().load(jsonPath,onLoadComplete);
		}
		
		protected function onLoadComplete(url:String):void
		{
			var res:ResContent = LoaderMgr.getInstance().getResource(url);
			_model.editor.analyzeJson(res.content);
			emit(NtfyName.DrawMapScene);
		}
		
		public function get view():GComponent{
			return _view;
		}
	}
}