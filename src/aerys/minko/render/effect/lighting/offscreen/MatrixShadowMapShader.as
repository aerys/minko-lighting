package aerys.minko.render.effect.lighting.offscreen
{
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.ActionScriptShader;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.part.animation.VertexAnimationShaderPart;
	import aerys.minko.type.enum.Blending;
	
	public class MatrixShadowMapShader extends ActionScriptShader
	{
		private var _vertexAnimationPart	: VertexAnimationShaderPart;
		private var _lightId				: uint		= 0;
		private var _vertexPosition			: SFloat	= null;
		
		public function MatrixShadowMapShader(lightId	: uint,
											  priority	: Number,
											  target	: RenderTarget)
		{
			super(priority, target);
			
			_lightId				= lightId;	
			_vertexAnimationPart	= new VertexAnimationShaderPart(this);
			
			forkTemplate.blending	= Blending.NORMAL;
		}
		
		override protected function initializeFork(fork : Shader) : void
		{
			super.initializeFork(fork);
			
			fork.enabled = meshBindings.propertyExists(LightingProperties.CAST_SHADOWS) 
				&& !meshBindings.getProperty(LightingProperties.CAST_SHADOWS)
		}
		
		override protected function getVertexPosition() : SFloat
		{
			_vertexPosition = _vertexAnimationPart.getAnimatedVertexPosition();
			
			var worldPosition		: SFloat = localToWorld(_vertexPosition);
			var worldToLightScreen	: SFloat = sceneBindings.getParameter('lightWorldToLightScreen' + _lightId, 16);
			var clipSpacePosition	: SFloat = multiply4x4(worldPosition, worldToLightScreen);
			
			return clipSpacePosition;
		}
		
		override protected function getPixelColor() : SFloat
		{
			var worldPosition		: SFloat = localToWorld(interpolate(_vertexPosition));
			var worldToLightScreen	: SFloat = sceneBindings.getParameter('lightWorldToLightScreen' + _lightId, 16);
			var clipSpacePosition	: SFloat = multiply4x4(worldPosition, worldToLightScreen);
			var depth				: SFloat = divide(clipSpacePosition.zzz, clipSpacePosition.www);
			
			return float4(depth.xxx, 1);
//			return pack(depth);
		}
	}
}
