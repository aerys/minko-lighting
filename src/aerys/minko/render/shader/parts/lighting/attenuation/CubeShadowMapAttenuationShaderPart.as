package aerys.minko.render.shader.parts.lighting.attenuation
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.compiler.register.Components;
	import aerys.minko.render.shader.part.ShaderPart;
	import aerys.minko.type.enum.SamplerDimension;
	import aerys.minko.type.enum.SamplerFiltering;
	import aerys.minko.type.enum.SamplerMipMapping;
	import aerys.minko.type.enum.SamplerWrapping;
	
	public class CubeShadowMapAttenuationShaderPart extends ShaderPart implements IAttenuationShaderPart
	{
		use namespace minko_lighting;
		
		private static const DEFAULT_BIAS : Number = 1 / 100;
		
		public function CubeShadowMapAttenuationShaderPart(main : Shader)
		{
			super(main);
		}
		
		public function getAttenuation(lightId : uint, wPos : SFloat, wNrm : SFloat, iwPos : SFloat, iwNrm : SFloat) : SFloat
		{
			// retrieve shadow bias
			var shadowBias : SFloat;
			if (meshBindings.propertyExists(LightingProperties.SHADOWS_BIAS))
				shadowBias = meshBindings.getParameter(LightingProperties.SHADOWS_BIAS, 1);
			else if (sceneBindings.propertyExists(LightingProperties.SHADOWS_BIAS))
				shadowBias = sceneBindings.getParameter(LightingProperties.SHADOWS_BIAS, 1);
			else
				shadowBias = float(DEFAULT_BIAS);
			
			// retrieve depthmap, transformation matrix, zNear and zFar
			var worldToLightName	: String = LightingProperties.getNameFor(lightId, 'worldToLocal');
			var zNearName			: String = LightingProperties.getNameFor(lightId, 'zNear');
			var zFarName			: String = LightingProperties.getNameFor(lightId, 'zFar');
			var depthMapName		: String = LightingProperties.getNameFor(lightId, 'shadowMapCube');
			
			var worldToLight		: SFloat = sceneBindings.getParameter(worldToLightName, 16);
			var zNear				: SFloat = sceneBindings.getParameter(zNearName, 1);
			var zFar				: SFloat = sceneBindings.getParameter(zFarName, 1);
			var cubeDepthMap		: SFloat = sceneBindings.getTextureParameter(
				depthMapName, SamplerFiltering.NEAREST, SamplerMipMapping.NEAREST, SamplerWrapping.CLAMP, SamplerDimension.CUBE);
			
			// retrieve precompute depth
			var positionFromLight	: SFloat = interpolate(multiply4x4(wPos, worldToLight));
			var precomputedDepth	: SFloat = extract(sampleTexture(cubeDepthMap, positionFromLight), Components.stringToComponent('X'));
			
			// retrieve real depth
			var currentDepth		: SFloat = divide(subtract(length(positionFromLight.xyz), zNear), subtract(zFar, zNear));
			
			return lessThan(currentDepth, add(shadowBias, precomputedDepth));
		}
	}
}
