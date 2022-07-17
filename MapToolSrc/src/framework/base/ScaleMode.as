package framework.base
{
	/**
	 * 页面最大最小宽高参数设置
	 */
	public class ScaleMode
	{
		/**
		 * 设计宽度
		 */
		public var designWidth: Number;
		/**
		 * 设计高度
		 */
		public var designHeight: Number;
		/**
		 * 设计最小高度
		 */
		public var designHeight_min: Number;
		/**
		 * 设计最大高度
		 */
		public var designHeight_max: Number;
		
		public function ScaleMode(_designWidth:Number, _designHeight:Number, _designHeight_min:Number, _designHeight_max:Number)
		{
			designWidth = _designWidth;
			designHeight = _designHeight;
			designHeight_min = _designHeight_min;
			designHeight_max = _designHeight_max;
		}
	}
}