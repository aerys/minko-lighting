package aerys.minko.render.shader.parts.lighting.attenuation
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.part.ShaderPart;
	import aerys.minko.type.enum.SamplerFiltering;
	import aerys.minko.type.enum.SamplerMipMapping;
	import aerys.minko.type.enum.SamplerWrapping;
	
	/**
	 * Fixme, bias should be:Total bias is m*SLOPESCALE + DEPTHBIAS
	 * Where m = max( | ∂z/∂x | , | ∂z/∂y | )
	 * ftp://download.nvidia.com/developer/presentations/2004/GPU_Jackpot/Shadow_Mapping.pdf
	 * 
	 * or maybe implement middle point shadow mapping to stop asking the user to manage shadow bias...
	 * 
	 * @author Romain Gilliotte
	 */
	public class MatrixShadowMapAttenuationShaderPart extends ShaderPart implements IAttenuationShaderPart
	{
		use namespace minko_lighting;
		
		private static const DEFAULT_BIAS : Number = 0.2;
		
		public function MatrixShadowMapAttenuationShaderPart(main : Shader)
		{
			super(main);
		}
		
		public function getAttenuation(lightId : uint, wPos : SFloat, wNrm : SFloat, iwPos : SFloat, iwNrm : SFloat) : SFloat
		{
			// retrieve depthmap and projection matrix
			var lightWorldToUVName	: String = LightingProperties.getNameFor(lightId, 'worldToUV');
			var lightDepthMapName	: String = LightingProperties.getNameFor(lightId, 'shadowMap');
			
			var worldToLightUV		: SFloat = sceneBindings.getParameter(lightWorldToUVName, 16);
			var depthMap			: SFloat = 
				sceneBindings.getTextureParameter(lightDepthMapName, SamplerFiltering.NEAREST, SamplerMipMapping.DISABLE, SamplerWrapping.CLAMP);
			
			// retrieve shadow bias
			var shadowBias : SFloat;
			if (meshBindings.propertyExists(LightingProperties.SHADOWS_BIAS))
				shadowBias = meshBindings.getParameter(LightingProperties.SHADOWS_BIAS, 1);
			else if (sceneBindings.propertyExists(LightingProperties.SHADOWS_BIAS))
				shadowBias = sceneBindings.getParameter(LightingProperties.SHADOWS_BIAS, 1);
			else
				shadowBias = float(DEFAULT_BIAS);
			
			// read expected depth from shadow map, and compute current depth
			var uv : SFloat;
			uv = multiply4x4(wPos, worldToLightUV);
			uv = divide(uv, uv.w);
			uv = interpolate(uv);
			
			var currentDepth : SFloat = uv.z;
			
			var precomputedDepth : SFloat;
			precomputedDepth = sampleTexture(depthMap, uv);
			precomputedDepth = precomputedDepth.x;
//			precomputedDepth = unpack(precomputedDepth);
			
			// shadow then current depth is less than shadowBias + precomputed depth
			return lessThan(currentDepth, add(shadowBias, precomputedDepth));
		}
	}
}
