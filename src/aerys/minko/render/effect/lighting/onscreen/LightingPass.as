package aerys.minko.render.effect.lighting.onscreen
{
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.PassConfig;
	import aerys.minko.render.shader.PassInstance;
	import aerys.minko.render.shader.PassTemplate;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.part.BlendingShaderPart;
	import aerys.minko.render.shader.part.PixelColorShaderPart;
	import aerys.minko.render.shader.part.animation.VertexAnimationShaderPart;
	import aerys.minko.render.shader.parts.lighting.LightingShaderPart;
	import aerys.minko.type.enum.Blending;
	import aerys.minko.type.enum.DepthTest;
	import aerys.minko.type.enum.TriangleCulling;
	import aerys.minko.type.stream.format.VertexComponent;
	
	public class LightingPass extends PassTemplate
	{
		private var _vertexAnimationPart	: VertexAnimationShaderPart;
		private var _pixelColorPart			: PixelColorShaderPart;
		private var _blendingPart			: BlendingShaderPart;
		private var _lightingPart			: LightingShaderPart;
		
		private var _priority				: Number;
		private var _renderTarget			: RenderTarget;
		
		private var _vertexPosition			: SFloat;
		private var _vertexUV				: SFloat;
		private var _vertexNormal			: SFloat;
		
		public function LightingPass(priority		: Number		= 0,
									 renderTarget	: RenderTarget	= null)
		{
			// init needed shader parts
			_vertexAnimationPart	= new VertexAnimationShaderPart(this);
			_pixelColorPart			= new PixelColorShaderPart(this);
			_blendingPart			= new BlendingShaderPart(this);
			_lightingPart			= new LightingShaderPart(this);
			
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
		
		override protected function getVertexPosition() : SFloat
		{
			var culling : uint = meshBindings.getPropertyOrFallback("triangleCulling", TriangleCulling.BACK);
			
			_vertexPosition = _vertexAnimationPart.getAnimatedVertexPosition();
			_vertexUV		= getVertexAttribute(VertexComponent.UV);
			_vertexNormal	= _vertexAnimationPart.getAnimatedVertexNormal();
			
			if (culling == TriangleCulling.FRONT)
				_vertexNormal = negate(_vertexNormal);
			
			return localToScreen(_vertexPosition);
		}
		
		override protected function getPixelColor() : SFloat
		{
			var color		: SFloat	= _pixelColorPart.getPixelColor();
			var lighting	: SFloat	= _lightingPart.getLightingColor(_vertexPosition, _vertexUV, _vertexNormal);
			
			color.scaleBy(lighting);
			
			return color;
		}
		
	}
}