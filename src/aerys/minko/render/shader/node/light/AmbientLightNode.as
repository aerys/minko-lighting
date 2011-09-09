package aerys.minko.render.shader.node.light
{
	import aerys.minko.scene.data.LightData;
	import aerys.minko.render.shader.node.leaf.WorldParameter;
	
	public class AmbientLightNode extends WorldParameter
	{
		public function AmbientLightNode(lightIndex : uint)
		{
			super(3, LightData, LightData.PREMULTIPLIED_AMBIENT_COLOR, lightIndex);
		}
	}
}
