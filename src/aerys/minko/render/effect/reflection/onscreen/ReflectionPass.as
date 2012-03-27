package aerys.minko.render.effect.reflection.onscreen
{
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.effect.reflection.ReflectionProperties;
	import aerys.minko.render.shader.PassConfig;
	import aerys.minko.render.shader.PassTemplate;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.part.BlendingShaderPart;
	import aerys.minko.render.shader.part.PixelColorShaderPart;
	import aerys.minko.render.shader.part.animation.VertexAnimationShaderPart;
	import aerys.minko.render.shader.parts.reflection.ReflectionShaderPart;
	import aerys.minko.type.enum.Blending;
	import aerys.minko.type.enum.DepthTest;
	import aerys.minko.type.enum.TriangleCulling;
	
	public class ReflectionPass extends PassTemplate
	{
		private var _vertexAnimationPart	: VertexAnimationShaderPart;
		private var _pixelColorPart			: PixelColorShaderPart;
		private var _blendingShaderPart		: BlendingShaderPart;
		private var _reflectionPart			: ReflectionShaderPart;
		
		private var _priority				: Number;
		private var _renderTarget			: RenderTarget;
		
		private var _vertexPosition 		: SFloat;
		private var _vertexNormal			: SFloat;
		
		public function ReflectionPass(priority		: Number = 0,
									   renderTarget	: RenderTarget = null)
		{
			// init needed shader parts
			_vertexAnimationPart	= new VertexAnimationShaderPart(this);
			_pixelColorPart			= new PixelColorShaderPart(this);
			_reflectionPart			= new ReflectionShaderPart(this);
			
			// save priority and render target to configure pass later
			_priority				= priority;
			_renderTarget			= renderTarget;
		}
		
		override protected function configurePass(passConfig : PassConfig) : void
		{
			var blending : uint = meshBindings.getPropertyOrFallback("blending", Blending.NORMAL);
			
			if (blending == Blending.ALPHA || blending == Blending.ADDITIVE)
				passConfig.priority -= 0.5;
			
			passConfig.priority			= _priority;
			passConfig.renderTarget		= _renderTarget;
			
			passConfig.depthTest		= meshBindings.getPropertyOrFallback("depthTest", DepthTest.LESS);
			passConfig.blending			= blending;
			passConfig.triangleCulling	= meshBindings.getPropertyOrFallback("triangleCulling", TriangleCulling.BACK);
		}
		
		override protected function getVertexPosition():SFloat
		{
			_vertexPosition = _vertexAnimationPart.getAnimatedVertexPosition();
			_vertexNormal	= _vertexAnimationPart.getAnimatedVertexNormal();
			
			return localToScreen(_vertexPosition);
		}
		
		override protected function getPixelColor() : SFloat
		{
			var color : SFloat = _pixelColorPart.getPixelColor();
			
			return color;
		}
	}
}