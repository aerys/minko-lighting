package aerys.minko.render.shader.parts.lighting.attenuation
{
	import aerys.minko.render.effect.Style;
	import aerys.minko.render.effect.lighting.LightingStyle;
	import aerys.minko.render.shader.ActionScriptShaderPart;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.render.shader.node.leaf.Sampler;
	import aerys.minko.scene.data.LightData;
	
	public class CubeShadowMapAttenuationShaderPart extends ActionScriptShaderPart implements IAttenuationShaderPart
	{
		public function getDynamicFactor(lightId	: uint, 
										 position	: SValue = null) : SValue
		{
			position ||= interpolate(vertexPosition);
			
			var cubeMap				: uint	 = Style.getStyleId('lighting cubeDepthMap' + lightId);
			var shadowBias			: SValue = getStyleParameter(1, LightingStyle.SHADOWS_BIAS, 0.6);
			
			var localToLight		: SValue = getWorldParameter(16, LightData, LightData.LOCAL_TO_LIGHT, lightId);
			var positionFromLight	: SValue = multiply4x4(position, localToLight);
			var currentDepth		: SValue = length(positionFromLight.xyz);
			
			var precomputedDepth	: SValue = sampleTexture(
				cubeMap, 
				positionFromLight, 
				Sampler.FILTER_NEAREST, 
				Sampler.MIPMAP_DISABLE, 
				Sampler.WRAPPING_CLAMP, 
				Sampler.DIMENSION_CUBE
			);
			
			precomputedDepth = multiply(precomputedDepth.x, 255);
//			precomputedDepth = unpack(precomputedDepth);
			return ifLessThan(currentDepth, add(shadowBias, precomputedDepth));
		}
		
		public function getStaticFactor(lightData	: LightData,
										position	: SValue = null) : SValue
		{
			throw new Error('Not yet implemented');
		}
	}
}