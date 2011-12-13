package aerys.minko.render.effect.lighting.offscreen
{
	import aerys.minko.render.effect.IEffectPass;
	import aerys.minko.render.effect.basic.BasicStyle;
	import aerys.minko.render.effect.lighting.LightingStyle;
	import aerys.minko.render.renderer.RendererState;
	import aerys.minko.render.shader.ActionScriptShader;
	import aerys.minko.render.target.AbstractRenderTarget;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	import aerys.minko.scene.data.ViewportData;
	import aerys.minko.type.enum.Blending;
	import aerys.minko.type.enum.CompareMode;
	import aerys.minko.type.enum.TriangleCulling;
	
	import flash.utils.Dictionary;
	
	public class DepthPass implements IEffectPass
	{
		private var _shader			: ActionScriptShader;
		private var _renderTarget	: AbstractRenderTarget;
		private var _priority		: Number;
		
		public function DepthPass(shader 		: ActionScriptShader,
								  priority		: Number				= 0,
								  renderTarget	: AbstractRenderTarget	= null)
		{
			_shader			= shader;
			_priority		= priority;
			_renderTarget	= renderTarget;
		}
		
		public function fillRenderState(state			: RendererState, 
										styleData		: StyleData, 
										transformData	: TransformData, 
										worldData		: Dictionary) : Boolean
		{
			if (!styleData.get(LightingStyle.CAST_SHADOWS, false))
				return false;
			
			_shader.fillRenderState(state, styleData, transformData, worldData);
			
			state.blending			= Blending.NORMAL;
			state.depthTest			= CompareMode.LESS;
			state.priority			= _priority;
			state.renderTarget		= _renderTarget || worldData[ViewportData].renderTarget;
			state.triangleCulling	= styleData.get(BasicStyle.TRIANGLE_CULLING, TriangleCulling.BACK) as uint;
			
			return true;
		}
	}
}
