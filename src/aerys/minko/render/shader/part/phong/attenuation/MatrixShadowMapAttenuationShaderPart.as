package aerys.minko.render.shader.part.phong.attenuation
{
	import aerys.minko.render.material.phong.PhongProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.part.phong.LightAwareShaderPart;
	import aerys.minko.scene.node.light.DirectionalLight;
	import aerys.minko.type.enum.SamplerFiltering;
	import aerys.minko.type.enum.SamplerMipMapping;
	import aerys.minko.type.enum.SamplerWrapping;
	
	/**
	 * Fixme, bias should be:Total bias is m*SLOPESCALE + DEPTHBIAS
	 * Where m = max( | ∂z/∂x | , | ∂z/∂y | )
	 * ftp://download.nvidia.com/developer/presentations/2004/GPU_Jackpot/Shadow_Mapping.pdf
	 * 
	 * @author Romain Gilliotte
	 */
	public class MatrixShadowMapAttenuationShaderPart extends LightAwareShaderPart implements IAttenuationShaderPart
	{
		private static const DEFAULT_BIAS : Number = 1 / 256 / 256;
		
		public function MatrixShadowMapAttenuationShaderPart(main : Shader)
		{
			super(main);
		}
		
		public function getAttenuation(lightId : uint) : SFloat
		{
			var lightType : uint = getLightConstant(lightId, 'type');
			
			// retrieve shadow bias
			var shadowBias : SFloat;
			if (meshBindings.propertyExists(PhongProperties.SHADOW_BIAS))
				shadowBias = meshBindings.getParameter(PhongProperties.SHADOW_BIAS, 1);
			else if (sceneBindings.propertyExists(PhongProperties.SHADOW_BIAS))
				shadowBias = sceneBindings.getParameter(PhongProperties.SHADOW_BIAS, 1);
			else
				shadowBias = float(DEFAULT_BIAS);
			
			// retrieve depthmap and projection matrix
			var worldToUV	: SFloat = getLightParameter(lightId, 'worldToUV', 16);
			var depthMap	: SFloat = getLightTextureParameter(lightId, 'shadowMap', 
				SamplerFiltering.NEAREST, 
				SamplerMipMapping.DISABLE, 
				SamplerWrapping.CLAMP);
			
			// read expected depth from shadow map, and compute current depth
			var uv : SFloat;
			uv = multiply4x4(vsWorldPosition, worldToUV);
			uv = interpolate(uv);
			
			var currentDepth : SFloat = uv.z;
			if (lightType == DirectionalLight.TYPE)
				currentDepth = divide(currentDepth, uv.w);
			currentDepth = min(subtract(1, shadowBias), currentDepth);
			
			uv = divide(uv, uv.w);
			
			var outsideMap			: SFloat = notEqual(0, dotProduct4(notEqual(uv, saturate(uv)), notEqual(uv, saturate(uv))));
			var precomputedDepth	: SFloat = unpack(sampleTexture(depthMap, uv.xyyy));
			
			// do not shadow when current depth is less than shadowBias + precomputed depth
			var noShadows : SFloat = lessEqual(currentDepth, add(shadowBias, precomputedDepth));
			if (lightType == DirectionalLight.TYPE)
				noShadows = or(outsideMap, noShadows)
			
			return noShadows;
		}
	}
}
