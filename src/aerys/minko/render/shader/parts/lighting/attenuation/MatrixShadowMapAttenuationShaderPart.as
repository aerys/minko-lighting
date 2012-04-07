package aerys.minko.render.shader.parts.lighting.attenuation
{
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.part.ShaderPart;
	import aerys.minko.type.enum.SamplerDimension;
	import aerys.minko.type.enum.SamplerFiltering;
	import aerys.minko.type.enum.SamplerMipMapping;
	import aerys.minko.type.enum.SamplerWrapping;
	import aerys.minko.type.stream.format.VertexComponent;
	
	/**
	 * Fixme, bias should be:Total bias is m*SLOPESCALE + DEPTHBIAS
	 * Where m = max( | ∂z/∂x | , | ∂z/∂y | )
	 * ftp://download.nvidia.com/developer/presentations/2004/GPU_Jackpot/Shadow_Mapping.pdf
	 * 
	 * or maybe implement dual shadow mapping to stop asking the user to manage shadow bias...
	 * 
	 * @author Romain Gilliotte
	 */
	public class MatrixShadowMapAttenuationShaderPart extends ShaderPart implements IAttenuationShaderPart
	{
		public function MatrixShadowMapAttenuationShaderPart(main : Shader)
		{
			super(main);
		}
		
		public function getAttenuationFactor(lightId					: uint,
											 worldPosition				: SFloat,
											 worldNormal				: SFloat,
											 worldInterpolatedPosition	: SFloat,
											 worldInterpolatedNormal	: SFloat) : SFloat
		{
			var depthMap		: SFloat = sceneBindings.getTextureParameter(
				'lightDepthMap' + lightId,
				SamplerFiltering.NEAREST, 
				SamplerMipMapping.DISABLE, 
				SamplerWrapping.CLAMP, 
				SamplerDimension.FLAT
			);
			
			var worldToLightUV	: SFloat = sceneBindings.getParameter('lightWorldToUV' + lightId, 16);
			var shadowBias		: SFloat;
			
			if (meshBindings.propertyExists('lightShadowBias'))
				shadowBias = meshBindings.getParameter('lightShadowBias', 1);
			else
				shadowBias = sceneBindings.getParameter('lightShadowBias' + lightId, 1);
			
			var uv : SFloat;
			uv = multiply4x4(worldPosition, worldToLightUV);
			uv = divide(uv, uv.w);
			uv = interpolate(uv);
			
			var currentDepth : SFloat = uv.z;
			
			var precomputedDepth : SFloat;
			precomputedDepth = sampleTexture(depthMap, uv);
			precomputedDepth = precomputedDepth.x;
//			precomputedDepth = unpack(precomputedDepth);
			
			return lessThan(currentDepth, add(shadowBias, precomputedDepth));
		}
	}
}
