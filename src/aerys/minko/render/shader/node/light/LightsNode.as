package aerys.minko.render.shader.node.light
{
	import aerys.minko.render.shader.node.Dummy;
	import aerys.minko.render.shader.node.IFragmentNode;
	import aerys.minko.render.shader.node.INode;
	import aerys.minko.render.shader.node.operation.math.Product;
	import aerys.minko.render.shader.node.operation.math.Sum;
	import aerys.minko.scene.visitor.data.LightData;
	import aerys.minko.scene.visitor.data.StyleStack;
	import aerys.minko.scene.visitor.data.WorldDataList;
	
	import flash.utils.Dictionary;
	
	public class LightsNode extends Dummy implements IFragmentNode
	{
		public function LightsNode(styleStack			: StyleStack,
								   worldData			: Dictionary,
								   lightDepthSamplers	: Vector.<int>)
		{
			// retrieve data
			var lightDatas : WorldDataList = worldData[LightData];
			
			// compute light sum
			var lightSum : Sum = new Sum();
			
			var shadowedCount	: uint	= 0;
			var lightCount		: uint	= lightDatas ? lightDatas.length : 0;
			
			for (var lightId : int = 0; lightId < lightCount; ++lightId) 
			{
				var lightData	: LightData	= lightDatas.getItem(lightId) as LightData;
				var lightNode	: INode		= 
					new LightNode(lightId, styleStack, worldData, lightDepthSamplers[shadowedCount]);
				
				if (lightData.castShadows)
					++shadowedCount;
				
				lightSum.addTerm(lightNode);
			}
			
			super(lightSum);
		}
	}
}
