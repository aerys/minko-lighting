package aerys.minko.render.shader.node.light
{
	import aerys.minko.render.shader.node.Components;
	import aerys.minko.render.shader.node.Dummy;
	import aerys.minko.render.shader.node.IFragmentNode;
	import aerys.minko.render.shader.node.INode;
	import aerys.minko.render.shader.node.leaf.Attribute;
	import aerys.minko.render.shader.node.leaf.Constant;
	import aerys.minko.render.shader.node.leaf.WorldParameter;
	import aerys.minko.render.shader.node.operation.builtin.Multiply;
	import aerys.minko.render.shader.node.operation.builtin.Multiply4x4;
	import aerys.minko.render.shader.node.operation.manipulation.Combine;
	import aerys.minko.render.shader.node.operation.manipulation.Extract;
	import aerys.minko.render.shader.node.operation.manipulation.Interpolate;
	import aerys.minko.render.shader.node.operation.packing.PackScalarToColor;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.type.stream.format.VertexComponent;
	
	public class PackedDepthFromLight extends Dummy implements IFragmentNode
	{
		public function PackedDepthFromLight(lightIndex : uint)
		{
			var depth			: INode = new DepthFromLight(lightIndex);
			var maxValueParts	: INode = new Constant(0, 100, 200, 300);
			var maxValue		: INode = new Constant(400);
			
			var packedDepth		: INode = new PackScalarToColor(depth, maxValueParts, maxValue);
			
			super(packedDepth);
		
		}
	}
}