package aerys.minko.render.shader.node.light
{
	import aerys.minko.render.shader.node.IFragmentNode;
	import aerys.minko.render.shader.node.operation.math.Sum;
	import aerys.minko.scene.visitor.data.LightData;
	import aerys.minko.scene.visitor.data.WorldDataList;
	
	public class LightsNode extends Sum implements IFragmentNode
	{
		public function LightsNode(lightDatas : WorldDataList, 
								   useShadows : Boolean)
		{
			super();
			
			var length : int = lightDatas ? lightDatas.length : 0;
			for (var i : int = 0; i < length; ++i) 
			{
				var lightData : LightData = lightDatas.getItem(i) as LightData;
				
				addTerm(
					new LightNode(i, lightData, useShadows)
				);
			}
		}
	}
}
