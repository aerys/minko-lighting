package aerys.minko.render.shader.node.light
{
	import aerys.minko.render.shader.node.Components;
	import aerys.minko.render.shader.node.Dummy;
	import aerys.minko.render.shader.node.IFragmentNode;
	import aerys.minko.render.shader.node.INode;
	import aerys.minko.render.shader.node.leaf.Attribute;
	import aerys.minko.render.shader.node.leaf.WorldParameter;
	import aerys.minko.render.shader.node.operation.builtin.Divide;
	import aerys.minko.render.shader.node.operation.builtin.Multiply4x4;
	import aerys.minko.render.shader.node.operation.manipulation.Combine;
	import aerys.minko.render.shader.node.operation.manipulation.Extract;
	import aerys.minko.render.shader.node.operation.manipulation.Interpolate;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.type.vertex.format.VertexComponent;
	
	public class UVFromLight extends Dummy implements IFragmentNode
	{
		public function UVFromLight(lightIndex : uint)
		{
			var simpleUv : INode = new Multiply4x4(
				new Interpolate(new Attribute(VertexComponent.XYZ)),
				new WorldParameter(16, LightData, LightData.LOCAL_TO_UV, lightIndex)
			);
			
			var uv : INode = new Divide(
				simpleUv, 
				new Extract(simpleUv, Components.W)
			);
			
			super(uv);
		}
	}
}