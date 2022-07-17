package framework.base
{
	public class NtfyName
	{
		private static var _next:int = 0;
		
		private static function get next():String {
			_next++;
			return "NtfyName_" + _next;
		}
		public static const UpdateJsonList:String = next;
		public static const LoadXmlCount:String = next; 
		public static const UpdateBgRes:String = next;
		public static const UpdateGridStatus:String = next;
		public static const UpdateResetGrid:String = next;
		public static const ClickGrid:String = next;
		public static const DrawMapScene:String = next;
		public static const AddDataFillGrid:String = next;
		public static const SetStartPoint:String = next;
		public static const SetAnmStartPoint:String = next;
	}
}