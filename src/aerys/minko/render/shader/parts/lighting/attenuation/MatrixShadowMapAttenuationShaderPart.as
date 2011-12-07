package aerys.minko.render.shader.parts.lighting.attenuation
{
	import aerys.minko.render.effect.Style;
	import aerys.minko.render.effect.lighting.LightingStyle;
	import aerys.minko.render.shader.ActionScriptShaderPart;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.render.shader.node.leaf.Sampler;
	import aerys.minko.scene.data.LightData;
	
	/**
	 * Fixme, bias should be:Total bias is m*SLOPESCALE + DEPTHBIAS
	 * Where m = max( | ∂z/∂x | , | ∂z/∂y | )
	 * ftp://download.nvidia.com/developer/presentations/2004/GPU_Jackpot/Shadow_Mapping.pdf
	 * 
	 * (and we should implement PCF)
	 * 
	 * @author Romain Gilliotte <romain.gilliotte@aerys.in>
	 * 
	 */	
	public class MatrixShadowMapAttenuationShaderPart extends ActionScriptShaderPart implements IAttenuationShaderPart
	{
		public function getDynamicFactor(lightId	: uint,
										 position	: SValue = null) : SValue
		{
			position ||= interpolate(vertexPosition);
			
			var lightDepthSamplerId	: uint	 = Style.getStyleId('lighting matrixDepthMap' + lightId);
			
			var lightLocalToUV	: SValue = getWorldParameter(16, LightData, LightData.LOCAL_TO_UV, lightId)
			var shadowBias		: SValue = getStyleParameter(1, LightingStyle.SHADOWS_BIAS, 1 / 100);
			
			var uv : SValue;
			uv = multiply4x4(position, lightLocalToUV);
			uv = divide(uv, uv.w);
			
			var currentDepth : SValue = uv.z;
			
			var precomputedDepth : SValue;
			precomputedDepth = sampleTexture(lightDepthSamplerId, uv, Sampler.FILTER_LINEAR, Sampler.MIPMAP_DISABLE, Sampler.WRAPPING_CLAMP);
			precomputedDepth = precomputedDepth.x;
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
