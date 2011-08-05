package aerys.minko.render.shader.node.light
{
	import aerys.minko.render.shader.node.Dummy;
	import aerys.minko.render.shader.node.IFragmentNode;
	import aerys.minko.render.shader.node.INode;
	import aerys.minko.render.shader.node.IVertexNode;
	import aerys.minko.render.shader.node.leaf.Attribute;
	import aerys.minko.render.shader.node.leaf.WorldParameter;
	import aerys.minko.render.shader.node.operation.builtin.Multiply4x4;
	import aerys.minko.render.shader.node.operation.manipulation.Interpolate;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.type.stream.format.VertexComponent;
	
	public class ClipspacePositionFromLight extends Dummy implements IVertexNode
	{
		public function get interpolated() : INode
		{
			return new Interpolate(this);
		}
		
		public function ClipspacePositionFromLight(lightIndex : uint)
		{
			var result : INode = new Multiply4x4(
				new Attribute(VertexComponent.XYZ),
				new WorldParameter(16, LightData, LightData.LOCAL_TO_SCREEN, lightIndex)
			);
			
			super(result);
		}
	}
}