package aerys.minko.render.shader.node.light
{
	import aerys.minko.render.shader.node.Components;
	import aerys.minko.render.shader.node.Dummy;
	import aerys.minko.render.shader.node.IFragmentNode;
	import aerys.minko.render.shader.node.INode;
	import aerys.minko.render.shader.node.leaf.Constant;
	import aerys.minko.render.shader.node.leaf.Sampler;
	import aerys.minko.render.shader.node.operation.builtin.Multiply;
	import aerys.minko.render.shader.node.operation.builtin.Texture;
	import aerys.minko.render.shader.node.operation.manipulation.Extract;
	
	public class UnpackDepthFromLight extends Dummy implements IFragmentNode
	{
		public function UnpackDepthFromLight(lightIndex : uint, samplerStyleId : int)
		{
			
			var uv	: INode = new UVFromLight(lightIndex);
			
			// retrieve it.
			var depthMapSampler : Sampler = new Sampler(samplerStyleId,
														Sampler.FILTER_LINEAR,
														Sampler.MIPMAP_DISABLE,
														Sampler.WRAPPING_CLAMP);
			var packedDepth : INode = new Texture(uv, depthMapSampler);
			
			var unpackedDepth : INode = new Multiply(
				new Constant(1500), 
				new Extract(packedDepth, Components.X)
			);
			
//			var maxValue		: IShaderNode = new Constant(1000);
//			var quarterMaxValue	: IShaderNode = new Constant(250);
//			var unpackedDepth	: IShaderNode = new Unpack(packedOppositeDepth, quarterMaxValue, maxValue);
			
			super(unpackedDepth);
		}
	}
}