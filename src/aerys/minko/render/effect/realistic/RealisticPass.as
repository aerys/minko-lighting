package aerys.minko.render.effect.realistic
{
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.effect.basic.BasicProperties;
	import aerys.minko.render.effect.reflection.ReflectionProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.ShaderSettings;
	import aerys.minko.render.shader.part.BlendingShaderPart;
	import aerys.minko.render.shader.part.DiffuseShaderPart;
	import aerys.minko.render.shader.part.animation.VertexAnimationShaderPart;
	import aerys.minko.render.shader.parts.lighting.LightingShaderPart;
	import aerys.minko.render.shader.parts.reflection.ReflectionShaderPart;
	import aerys.minko.type.enum.Blending;
	import aerys.minko.type.enum.DepthTest;
	import aerys.minko.type.enum.ReflectionType;
	import aerys.minko.type.enum.TriangleCulling;
	import aerys.minko.type.stream.format.VertexComponent;
	
	public class RealisticPass extends Shader
	{
		private var _vertexAnimationPart	: VertexAnimationShaderPart;
		private var _pixelColorPart			: DiffuseShaderPart;
		private var _blendingPart			: BlendingShaderPart;
		private var _lightingPart			: LightingShaderPart;
		private var _reflectionPart			: ReflectionShaderPart;
		
		private var _priority				: Number;
		private var _renderTarget			: RenderTarget;
		
		private var _vertexPosition			: SFloat;
		private var _vertexUV				: SFloat;
		private var _vertexNormal			: SFloat;
		
		public function RealisticPass(priority		: Number		= 0,
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
			var culling : uint = meshBindings.getConstant("triangleCulling", TriangleCulling.BACK);
			
			// store position, uv and normal in attributes, so that getPixelColor() can use them
			_vertexPosition = _vertexAnimationPart.getAnimatedVertexPosition();
			_vertexUV		= getVertexAttribute(VertexComponent.UV);
			_vertexNormal	= _vertexAnimationPart.getAnimatedVertexNormal();
			
			// invert normal is culling is backwars to allow proper lighting
			if (culling == TriangleCulling.FRONT)
				_vertexNormal = negate(_vertexNormal);
			
			return localToScreen(_vertexPosition);
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
				var reflectionColor	: SFloat	= _reflectionPart.getReflectionColor(_vertexPosition, _vertexUV, _vertexNormal);
				
				color = _blendingPart.blend(reflectionColor, color, blending);
			}

			// compute and apply lighting
			var lighting	: SFloat	= _lightingPart.getLightingColor(_vertexPosition, _vertexUV, _vertexNormal);
			color = _blendingPart.blend(lighting, color, Blending.LIGHT);
			
			if (meshBindings.propertyExists(BasicProperties.ALPHA_THRESHOLD))
			{
				var alphaThreshold : SFloat = meshBindings.getParameter('alphaThreshold', 1);
				
				kill(subtract(0.5, lessThan(color.w, alphaThreshold)));
			}
			
			return color;
		}
	}
}