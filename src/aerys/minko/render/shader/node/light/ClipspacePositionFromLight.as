package aerys.minko.render.shader.node.light
{
	import aerys.minko.render.effect.animation.AnimationStyle;
	import aerys.minko.render.shader.node.Dummy;
	import aerys.minko.render.shader.node.IFragmentNode;
	import aerys.minko.render.shader.node.INode;
	import aerys.minko.render.shader.node.IVertexNode;
	import aerys.minko.render.shader.node.animation.AnimatedPosition;
	import aerys.minko.render.shader.node.leaf.Attribute;
	import aerys.minko.render.shader.node.leaf.WorldParameter;
	import aerys.minko.render.shader.node.operation.builtin.Multiply4x4;
	import aerys.minko.render.shader.node.operation.manipulation.Interpolate;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.type.animation.AnimationMethod;
	import aerys.minko.type.stream.format.VertexComponent;
	
	public class ClipspacePositionFromLight extends Dummy implements IVertexNode
	{
		public function get interpolated() : INode
		{
			return new Interpolate(this);
		}
		
		public function ClipspacePositionFromLight(styleData : StyleData, lightIndex : uint)
		{
			var position : INode = new AnimatedPosition(
				styleData.get(AnimationStyle.METHOD, AnimationMethod.DISABLED) as uint,
				styleData.get(AnimationStyle.MAX_INFLUENCES, 0) as uint,
				styleData.get(AnimationStyle.NUM_BONES, 0) as uint
			);
			
			var result : INode = new Multiply4x4(
				position,
				new WorldParameter(16, LightData, LightData.LOCAL_TO_SCREEN, lightIndex)
			);
			
			super(result);
		}
	}
}