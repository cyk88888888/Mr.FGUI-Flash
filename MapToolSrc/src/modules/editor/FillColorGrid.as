package modules.editor
{
	import flash.display.Shape;
	import flash.display.Sprite;

	public class FillColorGrid extends Sprite
	{
		public function FillColorGrid(x:int,y:int,size:int,color:uint=0x00FF00)
		{
			var shape:Shape = new Shape();
			shape.graphics.beginFill(color,0.5);
			shape.graphics.drawRect(x,y,size,size);
			shape.graphics.endFill();
			this.addChild(shape);
		}
		
	}
}