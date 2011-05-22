package aerys.minko.render.shader.node.light
{
	import aerys.minko.scene.visitor.data.LightData;
	import aerys.minko.render.shader.node.leaf.WorldParameter;
	
	public class AmbientLightNode extends WorldParameter
	{
		public function AmbientLightNode(lightIndex : uint)
		{
			super(3, LightData, LightData.LOCAL_AMBIENT_X_COLOR, lightIndex);
		}
	}
}
