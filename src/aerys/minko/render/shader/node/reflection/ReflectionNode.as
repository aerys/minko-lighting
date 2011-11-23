package aerys.minko.render.shader.node.reflection
{
	import aerys.minko.render.effect.reflection.ReflectionStyle;
	import aerys.minko.render.shader.node.Dummy;
	import aerys.minko.render.shader.node.IFragmentNode;
	import aerys.minko.render.shader.node.INode;
	import aerys.minko.render.shader.node.leaf.Attribute;
	import aerys.minko.render.shader.node.leaf.Constant;
	import aerys.minko.render.shader.node.leaf.Sampler;
	import aerys.minko.render.shader.node.leaf.StyleParameter;
	import aerys.minko.render.shader.node.leaf.WorldParameter;
	import aerys.minko.render.shader.node.operation.builtin.Add;
	import aerys.minko.render.shader.node.operation.builtin.DotProduct3;
	import aerys.minko.render.shader.node.operation.builtin.Multiply;
	import aerys.minko.render.shader.node.operation.builtin.Normalize;
	import aerys.minko.render.shader.node.operation.builtin.ReciprocalRoot;
	import aerys.minko.render.shader.node.operation.builtin.Subtract;
	import aerys.minko.render.shader.node.operation.builtin.Texture;
	import aerys.minko.render.shader.node.operation.math.PlanarReflection;
	import aerys.minko.scene.data.CameraData;
	import aerys.minko.type.stream.format.VertexComponent;
	
	public class ReflectionNode extends Dummy implements IFragmentNode
	{
		public function ReflectionNode()
		{
			var surfaceNormal				: INode	= new Attribute(VertexComponent.NORMAL).interpolated;
//			var localViewDirection			: INode = new WorldParameter(3, CameraData, CameraData.LOCAL_DIRECTION);
			var cameraToVertex				: INode	= new Subtract(
				new Attribute(VertexComponent.XYZ).interpolated,
				new WorldParameter(3, CameraData, CameraData.LOCAL_POSITION)
			);
			
//			super(new Combine(new Normalize(cameraToVertex), new Constant(1.)));
//			super(new RootWrapper(new Constant(1., 1., 1., 1.)));
			
			//var reflectedLocalViewDirection	: INode = new PlanarReflection(localViewDirection, surfaceNormal);
			var reflectedLocalViewDirection	: INode = new PlanarReflection(new Normalize(cameraToVertex), surfaceNormal);
			
			var rWithZIncrement : INode = new Add(
				reflectedLocalViewDirection,
				new Constant(0, 0, 1)
			);
			
			// .5 / sqrt(r.x ^ 2 + r.y ^ 2 + r.z ^ 2) 
			var mReciprocal : INode = new Multiply(
				new Constant(.5),
				new ReciprocalRoot(
					new DotProduct3(rWithZIncrement, rWithZIncrement)
				)
			);
			
			var uv : INode = new Add( // check why did we had to negate
				new Constant(.5),
				new Multiply(reflectedLocalViewDirection, mReciprocal)
			);
			
			var result : INode = new Multiply(
				new Texture(uv, new Sampler(ReflectionStyle.ENVIRONMENT_MAP)),
				new StyleParameter(4, ReflectionStyle.RGBA)
			);
			
			super(result);
		}
	}
}