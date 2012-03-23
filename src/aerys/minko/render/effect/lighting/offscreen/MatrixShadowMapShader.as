package aerys.minko.render.effect.lighting.offscreen
{
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.PassConfig;
	import aerys.minko.render.shader.PassInstance;
	import aerys.minko.render.shader.PassTemplate;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.part.animation.VertexAnimationShaderPart;
	import aerys.minko.type.enum.Blending;
	
	public class MatrixShadowMapShader extends PassTemplate
	{
		private var _vertexAnimationPart	: VertexAnimationShaderPart;
		private var _lightId				: uint		= 0;
		private var _vertexPosition			: SFloat	= null;
		
		public function MatrixShadowMapShader(lightId	: uint,
											  priority	: Number,
											  target	: RenderTarget)
		{
			_lightId				= lightId;	
			_vertexAnimationPart	= new VertexAnimationShaderPart(this);
		}
		
		override protected function configurePass(passConfig : PassConfig) : void
		{
			passConfig.blending = Blending.NORMAL;
			
			passConfig.enabled = 
				meshBindings.getPropertyOrFallback(LightingProperties.CAST_SHADOWS, true);
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
