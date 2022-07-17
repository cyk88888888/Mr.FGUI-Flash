package modules.message {
    import framework.base.Global;
    import com.common.util.ArrayUtils;
    import com.greensock.TimelineLite;
    import com.greensock.TweenLite;
    
    import flash.display.DisplayObject;
    import flash.geom.Point;

    public class Message {
        public static const TYPE_NORMAL:int = 2; //右下角
        public static const TYPE_LAYOUT_2:int = 1; //
        public static const TYPE_MOUSEPOS:int = 0; //鼠标位置
        public static const TYPE_MISSION:int = 3; //任务

        [ArrayElementType("modules.message.MessageItem")]
        private static var _showingItems:Array = [];

        private static function onMsgTime(item:MessageItem):void {
            _showingItems.push(item);
            item.alpha = 0.1;
            var ey:Number = item.y - 71;
            if (ey < 0) {
                ey = 0;
            }
            var timeline:TimelineLite = new TimelineLite({"onComplete": onComplate, "onCompleteParams": [item]});
            timeline.append(new TweenLite(item, 0.5, {"alpha": 1, "y": ey}));
            timeline.append(new TweenLite(item, 0.5, {"alpha": 0, "delay": 0.5}));
            timeline.play();
        }

        private static function onComplate(item:MessageItem):void {
            TweenLite.killTweensOf(item);
            MessageItem.FREE(item);
            var index:int = _showingItems.indexOf(item);
            if (index > -1) {
                ArrayUtils.removeAt(_showingItems, index);
            }
        }

        public static function show(content:String, size:int = 30, type:int = TYPE_MOUSEPOS, color:uint = 0xec1010, point:Point = null):void {
			var messageItem:MessageItem;
			if (content == "" || content == null) {
				return;
			}
			//非鼠标位置类型的信息，限制重复出现的频率
			if (type != TYPE_MOUSEPOS && type != TYPE_LAYOUT_2) {
				for each(messageItem in _showingItems) {
					if (messageItem && messageItem.type == type && messageItem.content == content) {
						return;
					}
				}
			}
			
			messageItem = MessageItem.NEW();
			messageItem.type = type;
			//messageItem.showBg(true);
			
			if (type == TYPE_MOUSEPOS) {
				messageItem.update(content, color, size, "宋体", false);
				messageItem.x = (Global.stage.mouseX - (messageItem.width * 0.5));
				messageItem.y = Global.stage.mouseY;
			} else if (type == TYPE_LAYOUT_2 && point) {
				messageItem.update(content, color, size, "宋体", false);
				messageItem.x = (point.x - (messageItem.width * 0.5));
				messageItem.y = point.y;
			} else if (type == TYPE_NORMAL) {
				messageItem.update(content, color, size, "宋体", false);
				messageItem.x = (((Global.stage.stageWidth * 0.5) + 460) - (messageItem.width * 0.5));
				messageItem.y = (Global.stage.stageHeight - 80);
			}
			
			Global.stage.addChild(messageItem);
			layoutMessageItem(messageItem);
			onMsgTime(messageItem);
        }

        private static function layoutMessageItem(display:DisplayObject):void {
            if (display.x < 0) {
                display.x = 30
            }
            if ((display.x + display.width) > Global.stage.stageWidth) {
                display.x = Global.stage.stageWidth-display.width;
            }
        }
    }
}
