package aerys.minko.render.effect.lighting.offscreen
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.effect.basic.BasicProperties;
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.ShaderSettings;
	import aerys.minko.render.shader.part.animation.VertexAnimationShaderPart;
	import aerys.minko.type.enum.Blending;
	import aerys.minko.type.enum.TriangleCulling;
	
	public class MatrixShadowMapShader extends Shader
	{
		use namespace minko_lighting;
		
		private var _vertexAnimationPart	: VertexAnimationShaderPart;
		private var _lightId				: uint;
		private var _clipspacePosition		: SFloat;
		
		public function MatrixShadowMapShader(lightId		: uint,
											  priority		: Number,
											  renderTarget	: RenderTarget)
		{
			super(renderTarget, priority);
			
			_vertexAnimationPart	= new VertexAnimationShaderPart(this);
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
			var worldToScreenName	: String = LightingProperties.getNameFor(_lightId, 'worldToScreen');
			var worldToScreen		: SFloat = sceneBindings.getParameter(worldToScreenName, 16);
			var vertexPosition		: SFloat = localToWorld(_vertexAnimationPart.getAnimatedVertexPosition());
			
			_clipspacePosition = multiply4x4(vertexPosition, worldToScreen);
			
			return float4(_clipspacePosition.xy, multiply(_clipspacePosition.z, _clipspacePosition.w), _clipspacePosition.w); 
		}
		
		/**
		 * @see http://www.mvps.org/directx/articles/linear_z/linearz.htm Linear Z-buffering
		 */		
		override protected function getPixelColor() : SFloat
		{
			var iClipspacePosition	: SFloat = interpolate(_clipspacePosition);
			return iClipspacePosition.z;
		}
	}
}
