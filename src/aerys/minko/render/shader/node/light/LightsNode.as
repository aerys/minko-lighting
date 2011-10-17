package aerys.minko.render.shader.node.light
{
	import aerys.minko.render.effect.lighting.LightingStyle;
	import aerys.minko.render.shader.node.Dummy;
	import aerys.minko.render.shader.node.IFragmentNode;
	import aerys.minko.render.shader.node.INode;
	import aerys.minko.render.shader.node.operation.math.Sum;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.WorldDataList;
	
	import flash.utils.Dictionary;
	
	public class LightsNode extends Dummy implements IFragmentNode
	{
		public function LightsNode(styleStack			: StyleData,
								   worldData			: Dictionary,
								   lightDepthSamplers	: Vector.<int>)
		{
			// retrieve data
			var lightDatas		: WorldDataList = worldData[LightData];
			
			// compute light sum
			var lightSum		: Sum 		= new Sum();
			
			var shadowedCount	: uint		= 0;
			var lightCount		: uint		= lightDatas ? lightDatas.length : 0;
			var lightGroup		: uint		= uint(styleStack.get(LightingStyle.GROUP, 1));
			var shadowsEnabled	: uint		= uint(styleStack.get(LightingStyle.SHADOWS_ENABLED, false));
			var castShadows		: Boolean	= Boolean(styleStack.get(LightingStyle.CAST_SHADOWS, false));
			
			for (var lightId : int = 0; lightId < lightCount; ++lightId) 
			{
				var lightNode	: INode		= null;
				var lightData	: LightData	= lightDatas.getItem(lightId) as LightData;
				
				if ((lightData.group & lightGroup) == 0)
					continue;
				
				if (castShadows && shadowsEnabled && lightData.castShadows)
				{
					lightNode = new LightNode(lightId, styleStack, worldData, lightDepthSamplers[shadowedCount]);
					++shadowedCount;
				}
				else
				{
					lightNode = new LightNode(lightId, styleStack, worldData, SpotLightNode.NO_LIGHT_DEPTH_SAMPLER);
				}
				
				lightSum.addTerm(lightNode);
			}
			
			super(lightSum);
		}
	}
}
