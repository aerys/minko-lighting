package aerys.minko.effect.light
{
	import aerys.minko.render.effect.IEffectPass;
	import aerys.minko.render.effect.basic.BasicStyle;
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.shader.DynamicShader;
	import aerys.minko.render.shader.node.INode;
	import aerys.minko.render.shader.node.light.ClipspacePositionFromLight;
	import aerys.minko.render.shader.node.light.PackedDepthFromLight;
	import aerys.minko.render.state.Blending;
	import aerys.minko.render.state.RenderState;
	import aerys.minko.render.state.TriangleCulling;
	import aerys.minko.scene.visitor.data.StyleStack;
	import aerys.minko.scene.visitor.data.TransformData;
	
	import flash.utils.Dictionary;
	
	public class LightDepthPass implements IEffectPass
	{
		protected var _shader				: DynamicShader;		
		protected var _lightIndex			: uint;
		protected var _priority				: Number;
		protected var _renderTarget			: RenderTarget;
		
		public function LightDepthPass(lightIndex	: uint			= 0,
									   priority		: Number		= 0,
									   renderTarget	: RenderTarget	= null)
		{
			_lightIndex			= lightIndex;
			_priority			= priority;
			_renderTarget		= renderTarget;
			_shader				= createShader(lightIndex);
		}
		
		protected function createShader(lightIndex : uint) : DynamicShader
		{
			var clipspacePosition	: INode	= new ClipspacePositionFromLight(_lightIndex);
			var pixelColor			: INode	= new PackedDepthFromLight(_lightIndex);
			
			return DynamicShader.create(clipspacePosition, pixelColor);
		}
		
		public function fillRenderState(state		: RenderState,
										styleStack	: StyleStack, 
										local		: TransformData,
										world		: Dictionary) : Boolean
		{
			if (!styleStack.get(LightingStyle.CAST_SHADOWS, false))
				return false;
			
			state.blending			= Blending.NORMAL;
			state.priority			= _priority;
			state.renderTarget		= _renderTarget;
			state.shader			= _shader;
			state.triangleCulling	= styleStack.get(BasicStyle.TRIANGLE_CULLING, TriangleCulling.BACK) as uint;
			
			_shader.fillRenderState(state, styleStack, local, world);
			
			return true;
		}
	}
}