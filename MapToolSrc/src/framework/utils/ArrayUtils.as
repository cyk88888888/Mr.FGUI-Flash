package framework.utils
{
	public class ArrayUtils
	{
		public static function cutArray(resourceArr:Array,pieceLen:int):Array{
			var resultArr:Array=[],index:int;
			var cutNum:int=Math.floor(resourceArr.length/pieceLen);
			var cutNumRemain:int=Math.floor(resourceArr.length%pieceLen);
			for(var i:int=0;i<resourceArr.length;i+=pieceLen){
				var repeat:int=pieceLen;
				if(cutNumRemain!=0){
					if(index==cutNum){
						repeat=cutNumRemain;
					}
				}
				for(var j:int=0;j<repeat;j++){
					var index1:int=i+j;
					resultArr[index]||=[];
					
					resultArr[index].push(resourceArr[index1]);
				}
				index++;
			}
			return resultArr;
		}
	}
}