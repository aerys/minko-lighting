package aerys.minko.render.effect.realistic
{
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.material.basic.BasicProperties;
	import aerys.minko.render.effect.reflection.ReflectionProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.ShaderSettings;
	import aerys.minko.render.shader.part.BlendingShaderPart;
	import aerys.minko.render.shader.part.DiffuseShaderPart;
	import aerys.minko.render.shader.part.animation.VertexAnimationShaderPart;
	import aerys.minko.render.shader.part.lighting.LightingShaderPart;
	import aerys.minko.render.shader.part.reflection.ReflectionShaderPart;
	import aerys.minko.type.enum.Blending;
	import aerys.minko.type.enum.DepthTest;
	import aerys.minko.type.enum.ReflectionType;
	import aerys.minko.type.enum.TriangleCulling;
	import aerys.minko.render.geometry.stream.format.VertexComponent;
	
	public class RealisticShader extends Shader
	{
		private var _vertexAnimationPart	: VertexAnimationShaderPart;
		private var _pixelColorPart			: DiffuseShaderPart;
		private var _blendingPart			: BlendingShaderPart;
		private var _lightingPart			: LightingShaderPart;
		private var _reflectionPart			: ReflectionShaderPart;
		
		private var _priority				: Number;
		private var _renderTarget			: RenderTarget;
		
		public function RealisticShader(priority		: Number		= 0,
									  renderTarget	: RenderTarget	= null)
		{
			// init needed shader parts
			_vertexAnimationPart	= new VertexAnimationShaderPart(this);
			_pixelColorPart			= new DiffuseShaderPart(this);
			_blendingPart			= new BlendingShaderPart(this);
			_lightingPart			= new LightingShaderPart(this);
			_reflectionPart			= new ReflectionShaderPart(this);
			
			// save priority and render target to configure pass later
			_priority				= priority;
			_renderTarget			= renderTarget;
		}
		
		override protected function initializeSettings(passConfig : ShaderSettings) : void
		{
			// alpha blended drawcalls have a lower priority than normal blended, so that transparent
			// geometries are rendered last.
			var blending : uint = meshBindings.getConstant("blending", Blending.NORMAL);
			
			passConfig.blending			= blending;
			passConfig.priority			= _priority;
			
			if (blending == Blending.ALPHA || blending == Blending.ADDITIVE)
				passConfig.priority -= 0.5;
			
			if (meshBindings.propertyExists('deltaPriority'))
				passConfig.priority += meshBindings.getConstant('deltaPriority');
			
			passConfig.renderTarget		= _renderTarget;
			passConfig.depthTest		= meshBindings.getConstant("depthTest", DepthTest.LESS);
			passConfig.triangleCulling	= meshBindings.getConstant("triangleCulling", TriangleCulling.BACK);
		}
		
		override protected function getVertexPosition() : SFloat
		{
			return localToScreen(_vertexAnimationPart.getAnimatedVertexPosition());
		}
		
		override protected function getPixelColor() : SFloat
		{
			// retrieve color (from diffuseMap or diffuseColor
			var color			: SFloat	= _pixelColorPart.getDiffuse();
			
			// compute and apply reflections
			var reflectionType	: int = 
				meshBindings.getConstant(ReflectionProperties.TYPE, ReflectionType.NONE);
			
			if (reflectionType != ReflectionType.NONE)
			{
				var blending		: uint		= meshBindings.getConstant(ReflectionProperties.BLENDING, Blending.ALPHA);
				var reflectionColor	: SFloat	= _reflectionPart.getReflectionColor();
				
				color = _blendingPart.blend(reflectionColor, color, blending);
			}

			// compute and apply lighting
			var lighting	: SFloat	= _lightingPart.getLightingColor();
			
			color = float4(multiply(color.rgb, lighting), color.a);
			
			if (meshBindings.propertyExists(BasicProperties.ALPHA_THRESHOLD))
			{
				var alphaThreshold : SFloat = meshBindings.getParameter('alphaThreshold', 1);
				
				kill(subtract(0.5, lessThan(color.w, alphaThreshold)));
			}
			
			return color;
		}
	}
}