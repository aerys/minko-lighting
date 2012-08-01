package aerys.minko.render.effect.lighting.offscreen
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.material.basic.BasicProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.ShaderSettings;
	import aerys.minko.render.shader.part.DiffuseShaderPart;
	import aerys.minko.render.shader.part.animation.VertexAnimationShaderPart;
	import aerys.minko.scene.node.light.SpotLight;
	import aerys.minko.type.enum.Blending;
	import aerys.minko.type.enum.TriangleCulling;
	
	public class MatrixShadowMapShader extends Shader
	{
		use namespace minko_lighting;
		
		private var _vertexAnimationPart	: VertexAnimationShaderPart;
		private var _diffusePart			: DiffuseShaderPart;
		private var _lightId				: uint;
		private var _clipspacePosition		: SFloat;
		
		public function MatrixShadowMapShader(lightId		: uint,
											  priority		: Number,
											  renderTarget	: RenderTarget)
		{
			super(renderTarget, priority);
			
			_vertexAnimationPart	= new VertexAnimationShaderPart(this);
			_diffusePart			= new DiffuseShaderPart(this);
			_lightId				= lightId;
		}
		
		override protected function initializeSettings(passConfig : ShaderSettings) : void
		{
			passConfig.blending			= Blending.NORMAL;
			passConfig.enabled			= meshBindings.getConstant(LightingProperties.CAST_SHADOWS, true);
			passConfig.triangleCulling	= meshBindings.getConstant(BasicProperties.TRIANGLE_CULLING, TriangleCulling.BACK);
		}
		
		override protected function getVertexPosition() : SFloat
		{
			var lightTypeName		: String = LightingProperties.getNameFor(_lightId, 'type');
			var worldToScreenName	: String = LightingProperties.getNameFor(_lightId, 'worldToScreen');
			
			var lightType			: uint	 = sceneBindings.getConstant(lightTypeName);
			var worldToScreen		: SFloat = sceneBindings.getParameter(worldToScreenName, 16);
			var vertexPosition		: SFloat = localToWorld(_vertexAnimationPart.getAnimatedVertexPosition());
			
			_clipspacePosition = multiply4x4(vertexPosition, worldToScreen);
			
			if (lightType == SpotLight.TYPE)
				return float4(_clipspacePosition.xy, multiply(_clipspacePosition.z, _clipspacePosition.w), _clipspacePosition.w);
			else
				return _clipspacePosition;
		}
		
		/**
		 * @see http://www.mvps.org/directx/articles/linear_z/linearz.htm Linear Z-buffering
		 */		
		override protected function getPixelColor() : SFloat
		{
			var iClipspacePosition	: SFloat = interpolate(_clipspacePosition);
			
			if (meshBindings.propertyExists(BasicProperties.ALPHA_THRESHOLD))
			{
				var diffuse			: SFloat	= _diffusePart.getDiffuse();
				var alphaThreshold 	: SFloat 	= meshBindings.getParameter('alphaThreshold', 1);
				
				kill(subtract(0.5, lessThan(diffuse.w, alphaThreshold)));
			}
			
			return pack(iClipspacePosition.z);
		}
	}
}
