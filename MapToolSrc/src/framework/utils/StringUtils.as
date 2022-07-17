package framework.utils {
    import flash.geom.Rectangle;

    /**文本工具集*/
    public class StringUtils {

        /**用字符串填充数组，并返回数组副本*/
        public static function fillArray(arr:Array, str:String, type:Class = null):Array {
            var temp:Array = arr.concat();
            if (Boolean(str)) {
                var a:Array = str.split(",");
                extracted(temp, a, type);
            }
            return temp;
        }

        public static function fillArrayA(arr:Array, a:Array, type:Class = null):Array {
            var temp:Array = arr.concat();
            if (a != null)
                extracted(temp, a, type);
            return temp;
        }

        private static function extracted(temp:Array, a:Array, type:Class):void {
            for (var i:int = 0, n:int = Math.min(temp.length, a.length); i < n; i++) {
                var value:String = a[i];
                temp[i] = (value == "true" ? true : (value == "false" ? false : value));
                if (type != null) {
                    temp[i] = type(value);
                }
            }
        }

        /**转换Rectangle为逗号间隔的字符串*/
        public static function rectToString(rect:Rectangle):String {
            if (rect) {
                return rect.x + "," + rect.y + "," + rect.width + "," + rect.height;
            }
            return null;
        }

    }


}