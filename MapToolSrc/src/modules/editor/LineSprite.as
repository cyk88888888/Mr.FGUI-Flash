package modules.editor
{
	import com.greensock.TweenMax;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	public class LineSprite extends Sprite
	{
		private var _bgW:Number;//背景图宽
		private var _bgH:Number;//背景图高
		private var _gridSize:int;
		private var selContainer:Sprite;
		public var gridPathCotainer:Sprite;
		public var gridDataCotainer:Sprite;
		
		public function LineSprite(w:Number,h:Number,gridSize:int)
		{
			_bgW = w;
			_bgH = h;
			_gridSize = gridSize;
			drawLines();
			gridPathCotainer = new Sprite();
			this.addChild(gridPathCotainer);
			gridDataCotainer = new Sprite();
			this.addChild(gridDataCotainer);
			selContainer = new Sprite();
			this.addChild(selContainer);
		}
		
		private function drawLines():void{
			var size:int = _gridSize;
			var col:int = Math.ceil(_bgW/size),line:int = Math.ceil(_bgH/size);
			var shape:Shape = new Shape();
			shape.graphics.lineStyle(1,0x00ffff);
			this.addChild(shape);
			//画行线
			for(var i:int = 0;i<line;i++){
				shape.graphics.moveTo(0, i*size);
				shape.graphics.lineTo(_bgW,i*size);
			}
			
			//画列线
			for(var j:int = 0;j<col;j++){
				shape.graphics.moveTo(j*size, 0);
				shape.graphics.lineTo(j*size,_bgH);
			}
		}
		
		private var selShape:Shape;
		public function drawSelectGraph(x:Number,y:Number):void{
			if(selContainer.numChildren>0) selContainer.removeChildAt(0);
			TweenMax.killTweensOf(selShape);
			selShape = getSelGraph(x,y);
			selContainer.addChild(selShape);
			
			doAlphaTween1();
		}
		
		private function getSelGraph(x:Number,y:Number):Shape{
			var shape:Shape = new Shape();
			var size:int = _gridSize;
			var _x:Number=x+0.5,_y:Number = y+0.5;
			shape.alpha = 0;
			shape.graphics.lineStyle(2,0xffff00);
			shape.graphics.moveTo(_x, _y);
			shape.graphics.lineTo(_x+size,_y);
			shape.graphics.lineTo(_x+size,_y+size);
			shape.graphics.lineTo(_x,_y+size);
			shape.graphics.lineTo(_x,_y);
			return shape;
		}
		
		private function doAlphaTween():void{
			TweenMax.to(selShape,0.6,{alpha:0,onComplete:doAlphaTween1});
		}
		
		private function  doAlphaTween1():void{
			TweenMax.to(selShape,0.6,{alpha:1,onComplete:doAlphaTween});
		}
		
	}
}