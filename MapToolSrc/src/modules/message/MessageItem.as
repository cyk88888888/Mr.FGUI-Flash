package modules.message {
    import com.core.IDispose;
    import framework.utils.ObjectUtils;
    import framework.utils.StringUtils;
    
    import flash.display.Sprite;
    import flash.filters.GlowFilter;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import common.util.DspUtils;
    import core.utils.ObjectPoolList;
    import fairygui.GImage;

    public class MessageItem extends Sprite implements IDispose {
        public static var ObjectPool:ObjectPoolList;

        public static function NEW():MessageItem {
            ObjectPool ||= new ObjectPoolList(MessageItem);
            var obj:MessageItem = ObjectPool.Alloc(MessageItem);
            return obj;
        }

        public static function FREE(obj:MessageItem):void {
            obj.dispose();
            ObjectPool.Release(obj);
        }

        public var type:int;

        private var _size:int;
        private var _color:uint;
        private var _font:String;
        private var _str:String;
        private var _bold:Boolean;
        private var _txtStr:TextField;
        private var _bg:GImage;
        private var _stroke:Array;

        public function MessageItem() {
            mouseChildren = false;
            mouseEnabled = false;
            update("", 0xec1010);
        }

        public function showBg(visible:Boolean):void {
            _bg.visible = visible;
        }

        private function configUI():void {
//            if (_bg == null) {
//                _bg = new GImage();
//                _bg.sizeGrid = "10,10,10,10";
//                DspUtils.enable(_bg, false);
//                addChildAt(_bg, 0);
//            }
            if (!_txtStr) {
                _txtStr = new TextField();
                _txtStr.wordWrap = false;
                _txtStr.selectable = false;
                addChild(_txtStr);
            }
            var format:TextFormat = _txtStr.defaultTextFormat;
            format.align = TextFormatAlign.CENTER;
            format.font = _font;
            format.size = _size;
            format.color = _color;
            format.bold = _bold;
            _txtStr.defaultTextFormat = format;
            _txtStr.htmlText = _str;
            _txtStr.width = (_txtStr.textWidth + 20);
            _txtStr.y = 3;
            if (_bg != null) {
                _bg.width = (_txtStr.textWidth + 40);
                _bg.height = _txtStr.textHeight + 10;
                _bg.x = 0;
                _txtStr.x = 10;
            }
        }

        private function setStroke(value:Array):void {
            if (_stroke == value)
                return;
            _stroke = value;

            ObjectUtils.clearFilter(_txtStr, GlowFilter);
            if (Boolean(_stroke)) {
                var a:Array = StringUtils.fillArrayA([0x170702, 0.8, 2, 2, 10, 1], _stroke);
                ObjectUtils.addFilter(_txtStr, new GlowFilter(a[0], a[1], a[2], a[3], a[4], a[5]));
            }
        }

        private function reset():void {
            _size = 0;
            _color = 0;
            _font = "";
            _str = "";
            _bold = false;
            alpha = 1;
            _txtStr.htmlText = "";
        }

        public function update(content:String, color:uint, size:int = 14, font:String = "Tahoma", bold:Boolean = false, stroke:Array = null):void {
            _str = content;
            _color = color;
            _size = size;
            _font = font;
            _bold = bold;
            configUI();
            stroke ||= [0x0, 0.8, 2, 2, 10, 1];
            setStroke(stroke);
        }

        override public function get width():Number {
            return _txtStr.textWidth + 20;
        }

        public function get content():String {
            return _str;
        }

        public function dispose():void {
            DspUtils.removeChild(this);
            reset();
        }

    }
}
