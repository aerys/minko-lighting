package aerys.minko.render.effect.reflection.onscreen
{
	import aerys.minko.render.effect.IEffectPass;
	import aerys.minko.render.effect.SinglePassRenderingEffect;
	import aerys.minko.render.effect.reflection.ReflectionStyle;
	import aerys.minko.render.renderer.RendererState;
	import aerys.minko.render.resource.IResource;
	import aerys.minko.render.shader.ActionScriptShader;
	import aerys.minko.render.shader.IShader;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.target.AbstractRenderTarget;
	import aerys.minko.scene.data.ReflectionData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	import aerys.minko.scene.data.WorldDataList;
	
	import flash.utils.Dictionary;
	
	public class ReflectionPass extends SinglePassRenderingEffect
	{
		private static const SHADER : IShader = new ReflectionShader();
		
		private var _reflectionResources : Vector.<IResource>;
		
		public function ReflectionPass(reflectionRessources	: Vector.<IResource>,
									   priority				: Number				= 0.0,
									   renderTarget			: AbstractRenderTarget	= null)
		{
			super(SHADER, priority, renderTarget);
			
			_reflectionResources = reflectionRessources;
		}
		
		override public function fillRenderState(state			: RendererState, 
												 styleData		: StyleData, 
												 transformData	: TransformData, 
												 worldData		: Dictionary):Boolean
		{
			var reflectionSourceId : int = int(styleData.get(ReflectionStyle.RECEIVE, -1));
			
			if (reflectionSourceId >= 0)
				styleData.set(ReflectionStyle.MAP, _reflectionResources[reflectionSourceId]);
			
			return super.fillRenderState(state, styleData, transformData, worldData);
		}
		
		override public function getPasses(styleStack		: StyleData, 
										   transformData	: TransformData, 
										   worldData		: Dictionary) : Vector.<IEffectPass>
		{
			throw new Error("This class should never be used as an Effect. Use ReflectionEffect instead.");
		}
	}
}