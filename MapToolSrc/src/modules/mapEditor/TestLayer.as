package modules.mapEditor
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import fairygui.GComponent;
	
	import framework.base.BaseUT;
	import framework.base.Global;
	import framework.ui.UILayer;

	public class TestLayer extends UILayer
	{
		protected override function get pkgName():String
		{
			return "MapEditor";
		}
		private var grp_container:GComponent;
		private var linePointArr:Array = [
			[new Point(100,100),new Point(1450,100)],
			[new Point(1450,100),new Point(1450,810)],
			[new Point(100,810),new Point(1450,810)],
		    [new Point(100,100),new Point(100,810)]
		];
		private var _isMouseDown:Boolean;
		private var centerLine:Sprite = new Sprite();
		protected override function onEnter():void{
			grp_container = view.getChild("grp_container").asCom;
			view.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			view.addEventListener(MouseEvent.MOUSE_MOVE,mouseMove);
			view.addEventListener(MouseEvent.MOUSE_UP, onMouseUP);
			for(var i: int = 0;i<linePointArr.length;i++){
				var line:Sprite = new Sprite();
				line.graphics.lineStyle(1,0x00000);
				var startPos:Point = linePointArr[i][0];
				var endPos:Point = linePointArr[i][1];
				line.graphics.moveTo(startPos.x,startPos.y);
				line.graphics.lineTo(endPos.x,endPos.y);
				view.displayListContainer.addChild(line);
			}
			view.displayListContainer.addChild(centerLine);
		}
		
		
		protected function onMouseDown(event:Event):void
		{
			_isMouseDown = true;
		}
		
		protected function onMouseUP(event:Event):void
		{
			_isMouseDown = false;
		}
		
		protected function mouseMove(evt:MouseEvent):void
		{
			
			if(_isMouseDown){
				centerLine.graphics.clear();
				centerLine.graphics.lineStyle(1,0x00FF00);
				centerLine.graphics.moveTo(775,455);
				centerLine.graphics.lineTo(Global.stage.mouseX,Global.stage.mouseY);
				
				var angle:int = BaseUT.radian_to_angle(Math.atan2(Global.stage.mouseY-445,Global.stage.mouseX-775));
				grp_container.displayListContainer.removeChildren();
				var toStartPos:Point =  new Point(775,455);
				var toEndPos:Point = new Point(Global.stage.mouseX,Global.stage.mouseY);
				
				var crosspoint:Point;
				var crosspoint1:Point;
				var crosspoint2:Point;
				if(angle>=-90 && angle<=0){
					crosspoint1 = checkPoint(linePointArr[0][0], linePointArr[0][1], toStartPos, toEndPos);
					crosspoint2 = checkPoint(linePointArr[1][0], linePointArr[1][1], toStartPos, toEndPos);
				}else if(angle>=0&&angle<=90){
					crosspoint1 = checkPoint(linePointArr[1][0], linePointArr[1][1], toStartPos, toEndPos);
					crosspoint2 = checkPoint(linePointArr[2][0], linePointArr[2][1], toStartPos, toEndPos);
				}else if(angle>=90&&angle<=180){
					crosspoint1 = checkPoint(linePointArr[2][0], linePointArr[2][1],toStartPos,  toEndPos);
					crosspoint2 = checkPoint(linePointArr[3][0], linePointArr[3][1], toStartPos, toEndPos);
				}else{
					crosspoint1 = checkPoint(linePointArr[3][0], linePointArr[3][1], toStartPos, toEndPos);
					crosspoint2 = checkPoint(linePointArr[0][0], linePointArr[0][1], toStartPos, toEndPos);
				}
				trace(angle,crosspoint1,crosspoint2,crosspoint);
				crosspoint = crosspoint1 && crosspoint1.x>=100 && crosspoint1.y>=100 && crosspoint1.x<=1450&&crosspoint1.y<=810? crosspoint1 : crosspoint2;
				if(crosspoint){
					var distance1:Number = BaseUT.distance(toStartPos.x,toStartPos.y,toEndPos.x,toEndPos.y);
					var distance2:Number = BaseUT.distance(toStartPos.x,toStartPos.y,crosspoint.x,crosspoint.y);
					if(distance1 <= distance2){
						crosspoint = toEndPos;
					}
					var tempSp:Sprite = new Sprite();
					tempSp.graphics.beginFill(0xFF0000);
					tempSp.graphics.drawCircle(crosspoint.x,crosspoint.y,20);
					tempSp.graphics.endFill();
					grp_container.displayListContainer.addChild(tempSp);
				}
			}
		}
		
		
		private function checkPoint(p1Start:Point, p1End:Point,p2Start:Point,p2End:Point):Point
		{
			var p:Point = new Point();
			if (p1Start.x == p1End.x)
			{
				if (p2Start.x == p2End.x)
				{
					trace("平行线");
					p = null;
				}
				else
				{
					p.x = p1Start.x;
					p.y = p2Start.y+(p1Start.x-p2Start.x)/(p2End.x-p2Start.x)*(p2End.y-p2Start.y);
				}
			}
			else if (p2Start.x == p2End.x)
			{
				p.x = p2Start.x;
				p.y = p1Start.y+(p2Start.x-p1Start.x)/(p1End.x-p1Start.x)*(p1End.y-p1Start.y);
			}
			else
			{
				var K1:Number = (p1Start.y-p1End.y)/(p1Start.x-p1End.x);
				var K2:Number = (p2Start.y-p2End.y)/(p2Start.x-p2End.x);
				if (K1 == K2)
				{
					trace("平行线");
					p = null;
				}
				else
				{
					var B1:Number = (p1Start.x*p1End.y-p1Start.y*p1End.x)/(p1Start.x-p1End.x);
					var B2:Number = (p2Start.x*p2End.y-p2Start.y*p2End.x)/(p2Start.x-p2End.x);
					p.x = (B2 - B1) / (K1 - K2);
					p.y = K1 * p.x + B1;
				}
			}
			return p;
		}
		
	}
}