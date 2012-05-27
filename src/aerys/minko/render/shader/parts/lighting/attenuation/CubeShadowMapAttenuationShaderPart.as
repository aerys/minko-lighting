package aerys.minko.render.shader.parts.lighting.attenuation
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.part.ShaderPart;
	import aerys.minko.type.enum.SamplerDimension;
	import aerys.minko.type.enum.SamplerFiltering;
	import aerys.minko.type.enum.SamplerMipMapping;
	import aerys.minko.type.enum.SamplerWrapping;
	
	public class CubeShadowMapAttenuationShaderPart extends ShaderPart implements IAttenuationShaderPart
	{
		use namespace minko_lighting;
		
		private static const DEFAULT_BIAS : Number = 2;
		
		public function CubeShadowMapAttenuationShaderPart(main : Shader)
		{
			super(main);
		}
		
		public function getAttenuation(lightId : uint, wPos : SFloat, wNrm : SFloat, iwPos : SFloat, iwNrm : SFloat) : SFloat
		{
			// retrieve depthmap and transformation matrix
			var worldToLightName	: String = LightingProperties.getNameFor(lightId, 'worldToLocal');
			var depthMapName		: String = LightingProperties.getNameFor(lightId, 'shadowMapCube');
			
			var worldToLight		: SFloat = sceneBindings.getParameter(worldToLightName, 16);
			var cubeDepthMap		: SFloat = sceneBindings.getTextureParameter(
				depthMapName, SamplerFiltering.NEAREST, SamplerMipMapping.NEAREST, SamplerWrapping.CLAMP, SamplerDimension.CUBE);
			
			// retrieve shadow bias
			var shadowBias : SFloat;
			if (meshBindings.propertyExists(LightingProperties.SHADOWS_BIAS))
				shadowBias = meshBindings.getParameter(LightingProperties.SHADOWS_BIAS, 1);
			else if (sceneBindings.propertyExists(LightingProperties.SHADOWS_BIAS))
				shadowBias = sceneBindings.getParameter(LightingProperties.SHADOWS_BIAS, 1);
			else
				shadowBias = float(DEFAULT_BIAS);
			
			var positionFromLight	: SFloat = interpolate(multiply4x4(wPos, worldToLight));
			var currentDepth		: SFloat = length(positionFromLight.xyz);
			
			var precomputedDepth	: SFloat = sampleTexture(cubeDepthMap, positionFromLight);
//			return precomputedDepth.xyz;
			precomputedDepth = multiply(precomputedDepth.x, 255);
//			precomputedDepth = unpack(precomputedDepth);
			
			return lessThan(currentDepth, add(shadowBias, precomputedDepth));
		}
	}
}
