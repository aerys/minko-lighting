package aerys.minko.render.shader.node.light
{
	import aerys.minko.render.shader.node.Dummy;
	import aerys.minko.render.shader.node.IFragmentNode;
	import aerys.minko.render.shader.node.INode;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.StyleStack;
	
	import flash.utils.Dictionary;
	
	public class LightNode extends Dummy implements IFragmentNode
	{
		public function LightNode(lightIndex		: uint, 
								  styleStack		: StyleStack, 
								  worldData			: Dictionary, 
								  lightDepthSampler	: uint)
		{
			var lightData : LightData = worldData[LightData].getItem(lightIndex);
			
			var lightingNode : INode;
			switch (lightData.type)
			{
				case LightData.TYPE_AMBIENT:
					lightingNode = new AmbientLightNode(lightIndex);
					break;
				
				case LightData.TYPE_DIRECTIONAL : 
					lightingNode = new DirectionalLightNode(lightIndex, lightData, styleStack);
					break;
					
				case LightData.TYPE_SPOT :
				case LightData.TYPE_POINT :
					lightingNode = new SpotLightNode(lightIndex, styleStack, worldData, lightDepthSampler);
					break;
			}
			
			super(lightingNode);
			
			if (lightingNode == null)
				throw new Error('Unknown light type');
		}
	}
}