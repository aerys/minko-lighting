package aerys.minko.render.effect.lighting.offscreen
{
	import aerys.minko.render.effect.animation.AnimationStyle;
	import aerys.minko.render.shader.ActionScriptShader;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.render.shader.parts.animation.AnimationShaderPart;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	import aerys.minko.type.animation.AnimationMethod;
	
	import flash.utils.Dictionary;
	
	public class MatrixShadowMapShader extends ActionScriptShader
	{
		private static const ANIMATION : AnimationShaderPart = new AnimationShaderPart();
		
		private var _lightId	: uint;
		private var _position	: SValue;
		
		public function MatrixShadowMapShader(lightId : uint)
		{
			_lightId = lightId;	
		}
		
		override protected function getOutputPosition() : SValue
		{
			var animationMethod		: uint	 = uint(getStyleConstant(AnimationStyle.METHOD, AnimationMethod.DISABLED));
			var maxInfluences		: uint	 = uint(getStyleConstant(AnimationStyle.MAX_INFLUENCES, 0));
			var numBones			: uint	 = uint(getStyleConstant(AnimationStyle.NUM_BONES, 0));
			var vertexPosition		: SValue = ANIMATION.getVertexPosition(animationMethod, maxInfluences, numBones);
			
			_position = interpolate(vertexPosition);
			
			var lightLocalToScreen	: SValue = getWorldParameter(16, LightData, LightData.LOCAL_TO_SCREEN, _lightId);
			var clipSpacePosition	: SValue = multiply4x4(vertexPosition, lightLocalToScreen);
			
			return clipSpacePosition;
		}
		
		override protected function getOutputColor(kills : Vector.<SValue>) : SValue
		{
			var lightLocalToScreen	: SValue = getWorldParameter(16, LightData, LightData.LOCAL_TO_SCREEN, _lightId);
			var clipSpacePosition	: SValue = multiply4x4(_position, lightLocalToScreen);
			
			var depth				: SValue = divide(clipSpacePosition.zzz, clipSpacePosition.www);
			return float4(depth.xxx, 1);
//			return pack(depth);
		}
		
		override public function getDataHash(styleData		: StyleData, 
											 transformData	: TransformData, 
											 worldData		: Dictionary) : String
		{
			var hash : String = 'frustumShadowMapDepthShader';
			hash += ANIMATION.getDataHash(styleData, transformData, worldData)
			hash += _lightId;
			
			return hash;
		}
	}
}
