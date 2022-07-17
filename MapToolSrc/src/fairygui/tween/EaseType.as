package fairygui.tween
{
	public class EaseType
	{
		public static const Linear:int = 0;
		public static const SineIn:int = 1;
		public static const SineOut:int = 2;
		public static const SineInOut:int = 3;
		public static const QuadIn:int = 4;
		public static const QuadOut:int = 5;
		public static const QuadInOut:int = 6;
		public static const CubicIn:int = 7;
		public static const CubicOut:int = 8;
		public static const CubicInOut:int = 9;
		public static const QuartIn:int = 10;
		public static const QuartOut:int = 11;
		public static const QuartInOut:int = 12;
		public static const QuintIn:int = 13;
		public static const QuintOut:int = 14;
		public static const QuintInOut:int = 15;
		public static const ExpoIn:int = 16;
		public static const ExpoOut:int = 17;
		public static const ExpoInOut:int = 18;
		public static const CircIn:int = 19;
		public static const CircOut:int = 20;
		public static const CircInOut:int = 21;
		public static const ElasticIn:int = 22;
		public static const ElasticOut:int = 23;
		public static const ElasticInOut:int = 24;
		public static const BackIn:int = 25;
		public static const BackOut:int = 26;
		public static const BackInOut:int = 27;
		public static const BounceIn:int = 28;
		public static const BounceOut:int = 29;
		public static const BounceInOut:int = 30;
		public static const Custom:int = 31;
		
		private static const easeTypeMap:Object = {
			"Linear" : EaseType.Linear ,
			"Elastic.In" : EaseType.ElasticIn ,
			"Elastic.Out" : EaseType.ElasticInOut ,
			"Elastic.InOut" : EaseType.ElasticInOut ,
			"Quad.In" : EaseType.QuadIn ,
			"Quad.Out" : EaseType.QuadOut ,
			"Quad.InOut" : EaseType.QuadInOut ,
			"Cube.In" : EaseType.CubicIn ,
			"Cube.Out" : EaseType.CubicOut ,
			"Cube.InOut" : EaseType.CubicInOut ,
			"Quart.In" : EaseType.QuartIn ,
			"Quart.Out" : EaseType.QuartOut ,
			"Quart.InOut" : EaseType.QuartInOut ,
			"Quint.In" : EaseType.QuintIn ,
			"Quint.Out" : EaseType.QuintOut ,
			"Quint.InOut" : EaseType.QuintInOut ,
			"Sine.In" : EaseType.SineIn ,
			"Sine.Out" : EaseType.SineOut ,
			"Sine.InOut" : EaseType.SineInOut ,
			"Bounce.In" : EaseType.BounceIn ,
			"Bounce.Out" : EaseType.BounceOut ,
			"Bounce.InOut" : EaseType.BounceInOut ,
			"Circ.In" : EaseType.CircIn ,
			"Circ.Out" : EaseType.CircOut ,
			"Circ.InOut" : EaseType.CircInOut ,
			"Expo.In" : EaseType.ExpoIn ,
			"Expo.Out" : EaseType.ExpoOut ,
			"Expo.InOut" : EaseType.ExpoInOut ,
			"Back.In" : EaseType.BackIn ,
			"Back.Out" : EaseType.BackOut ,
			"Back.InOut" : EaseType.BackInOut
		};
		
		public static function parseEaseType(value:String):int
		{
			var type:* = easeTypeMap[value];
			if(type==undefined)
				return EaseType.QuadOut;
			else
				return int(type);
		}
		
		public function EaseType()
		{
		}
	}
}