package aerys.minko.render.shader.node.light
{
	import aerys.minko.render.shader.node.Components;
	import aerys.minko.render.shader.node.Dummy;
	import aerys.minko.render.shader.node.IFragmentNode;
	import aerys.minko.render.shader.node.INode;
	import aerys.minko.render.shader.node.leaf.Attribute;
	import aerys.minko.render.shader.node.leaf.WorldParameter;
	import aerys.minko.render.shader.node.operation.builtin.Multiply4x4;
	import aerys.minko.render.shader.node.operation.manipulation.Extract;
	import aerys.minko.render.shader.node.operation.manipulation.Interpolate;
	import aerys.minko.scene.visitor.data.LightData;
	import aerys.minko.type.vertex.format.VertexComponent;
	
	public class DepthFromLight extends Dummy implements IFragmentNode
	{
		public function DepthFromLight(lightIndex : uint)
		{
			var node : INode = new Extract(
				new Multiply4x4(
					new Interpolate(new Attribute(VertexComponent.XYZ)),
					new WorldParameter(16, LightData, LightData.LOCAL_TO_VIEW, lightIndex)
				),
				Components.Z
			);
			
			super(node);
		}
	}
}