package aerys.minko.render.shader.node.light
{
	import aerys.minko.render.shader.node.Dummy;
	import aerys.minko.render.shader.node.IFragmentNode;
	import aerys.minko.render.shader.node.INode;
	import aerys.minko.render.shader.node.leaf.Constant;
	import aerys.minko.render.shader.node.operation.builtin.Divide;
	import aerys.minko.render.shader.node.operation.packing.PackScalarToColor;
	
	public class PackedDepthFromLight extends Dummy implements IFragmentNode
	{
		public function PackedDepthFromLight(lightIndex : uint)
		{
			var depth			: INode = new DepthFromLight(lightIndex);
			var maxValueParts	: INode = new Constant(0, 100, 200, 300);
			var maxValue		: INode = new Constant(400);
			
			var packedDepth		: INode = new PackScalarToColor(new Divide(depth, maxValue));
			
			super(packedDepth);
		
		}
	}
}