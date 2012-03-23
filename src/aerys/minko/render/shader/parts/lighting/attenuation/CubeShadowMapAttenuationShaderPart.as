package aerys.minko.render.shader.parts.lighting.attenuation
{
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.PassTemplate;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.part.ShaderPart;
	import aerys.minko.type.enum.SamplerDimension;
	import aerys.minko.type.enum.SamplerFilter;
	import aerys.minko.type.enum.SamplerMipmap;
	import aerys.minko.type.enum.SamplerWrapping;
	import aerys.minko.type.stream.format.VertexComponent;
	
	public class CubeShadowMapAttenuationShaderPart extends ShaderPart implements IAttenuationShaderPart
	{
		public function CubeShadowMapAttenuationShaderPart(main : PassTemplate)
		{
			super(main);
		}
		
		public function getAttenuationFactor(lightId					: uint, 
											 worldPosition				: SFloat,
											 worldNormal				: SFloat,
											 worldInterpolatedPosition	: SFloat,
											 worldInterpolatedNormal	: SFloat) : SFloat
		{
			var cubeDepthMap		: SFloat = sceneBindings.getTextureParameter(
				'lightCubeDepthMap' + lightId, 
				SamplerFilter.NEAREST, 
				SamplerMipmap.DISABLE, 
				SamplerWrapping.CLAMP, 
				SamplerDimension.CUBE
			);
			
			var shadowBias			: SFloat;
			if (meshBindings.propertyExists('lightShadowBias'))
				shadowBias = meshBindings.getParameter('lightShadowBias', 1);
			else
				shadowBias = sceneBindings.getParameter('lightShadowBias' + lightId, 1);
			
			var worldToLight		: SFloat = sceneBindings.getParameter('lightWorldToLight' + lightId, 16);
			var positionFromLight	: SFloat = interpolate(multiply4x4(worldPosition, worldToLight));
			var currentDepth		: SFloat = length(positionFromLight.xyz);
			
			var precomputedDepth	: SFloat = sampleTexture(cubeDepthMap, positionFromLight);
			precomputedDepth = multiply(precomputedDepth.x, 255);
//			precomputedDepth = unpack(precomputedDepth);
			
			return lessThan(currentDepth, add(shadowBias, precomputedDepth));
		}
	}
}
