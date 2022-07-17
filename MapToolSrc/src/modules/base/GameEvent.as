package modules.base
{
	/**
	 * 游戏事件 
	 * @author cyk
	 * 
	 */	
	public class GameEvent
	{
		private static var _next:int = 0;
		
		private static function get next():String {
			_next++;
			return "GameEvent_" + _next;
		}
		public static const ChangeGridType:String = next;//变更格子类型
		public static const ClearGridType:String  = next;//删除指定类型格子
		public static const ClearLineAndGrid:String  = next;//删除所有线条和格子
		public static const ChangeMap:String  = next;//切换地图
		public static const ImportMapJson:String  = next;//导入地图json数据
		public static const ResizeGrid:String  = next;//变更格子大小
		public static const ResizeMap:String  = next;//变更地图大小
		public static const ScreenShoot:String  = next;//截图绘画区域
		public static const RunDemo:String  = next;//运行demo
		public static const CloseDemo:String  = next;//关闭demo
		public static const ToCenter:String  = next;//到地图中心点
		public static const ToOriginalScale:String  = next;//回归原大小缩放
		public static const ClearAllData:String  = next;//清除所有数据
	}
}