package aerys.minko.render.shader.parts.lighting.contribution
{
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.PassTemplate;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.part.ShaderPart;

	public class InfiniteShaderPart extends ShaderPart implements IContributionShaderPart
	{
		public function InfiniteShaderPart(main : PassTemplate)
		{
			super(main);
		}
		
		public function getDiffuseTerm(lightId						: uint, 
									   worldPosition				: SFloat,
									   worldNormal					: SFloat,
									   worldInterpolatedPosition	: SFloat,
									   worldInterpolatedNormal		: SFloat) : SFloat
		{
			var worldLightDirection : SFloat = sceneBindings.getParameter('lightWorldDirection' + lightId, 3);
			var lightDiffuse		: SFloat = sceneBindings.getParameter('lightDiffuse' + lightId, 1);
			
			if (meshBindings.propertyExists(LightingProperties.DIFFUSE_MULTIPLIER))
				lightDiffuse.scaleBy(meshBindings.getParameter(LightingProperties.DIFFUSE_MULTIPLIER, 1));
			
			var lambertProduct		: SFloat = saturate(negate(dotProduct3(worldLightDirection, worldInterpolatedNormal)));
			
			return multiply(lightDiffuse, lambertProduct);
		}
		
		public function getSpecularTerm(lightId						: uint, 
										worldPosition				: SFloat,
										worldNormal					: SFloat,
										worldInterpolatedPosition	: SFloat,
										worldInterpolatedNormal		: SFloat) : SFloat
		{
			var lightDirection		: SFloat = sceneBindings.getParameter('lightWorldDirection' + lightId, 3);
			var lightSpecular		: SFloat = sceneBindings.getParameter('lightSpecular' + lightId, 1);
			var lightShininess		: SFloat = sceneBindings.getParameter('lightShininess' + lightId, 1);
			
			if (meshBindings.propertyExists(LightingProperties.SPECULAR_MULTIPLIER))
				lightSpecular.scaleBy(meshBindings.getParameter(LightingProperties.SPECULAR_MULTIPLIER, 1));
			
			if (meshBindings.propertyExists(LightingProperties.SHININESS_MULTIPLIER))
				lightShininess.scaleBy(meshBindings.getParameter(LightingProperties.SHININESS_MULTIPLIER, 1));
			
			var viewDirection		: SFloat = normalize(subtract(worldInterpolatedPosition, cameraWorldPosition));
			var lightReflection		: SFloat = reflect(lightDirection, worldInterpolatedNormal);
			
			var lambertProduct		: SFloat = saturate(negate(dotProduct3(lightReflection, viewDirection)));
			
			return multiply(lightSpecular, power(lambertProduct, lightShininess));
		}
	}
}
