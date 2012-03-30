package aerys.minko.render.shader.parts.lighting.contribution
{
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.ActionScriptShader;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.part.ShaderPart;
	
	public class LocalizedShaderPart extends ShaderPart implements IContributionShaderPart
	{
		public function LocalizedShaderPart(main : ActionScriptShader)
		{
			super(main);
		}
		
		public function getDiffuseTerm(lightId						: uint, 
									   worldPosition				: SFloat,
									   worldNormal					: SFloat,
									   worldInterpolatedPosition	: SFloat,
									   worldInterpolatedNormal		: SFloat) : SFloat
		{
			var lightWorldPosition	: SFloat = sceneBindings.getParameter('lightWorldPosition' + lightId, 3);
			var lightDiffuse		: SFloat = sceneBindings.getParameter('lightDiffuse' + lightId, 1);
			
			if (meshBindings.propertyExists(LightingProperties.DIFFUSE_MULTIPLIER))
				lightDiffuse.scaleBy(meshBindings.getParameter(LightingProperties.DIFFUSE_MULTIPLIER, 1));
			
			var lightDirection		: SFloat = normalize(subtract(lightWorldPosition, worldInterpolatedPosition));
			var lambertProduct		: SFloat = saturate(dotProduct3(lightDirection, worldInterpolatedNormal));
			
			return multiply(lightDiffuse, lambertProduct);
		}
		
		public function getSpecularTerm(lightId						: uint, 
										worldPosition				: SFloat,
										worldNormal					: SFloat,
										worldInterpolatedPosition	: SFloat,
										worldInterpolatedNormal		: SFloat) : SFloat
		{
			var lightWorldPosition	: SFloat = sceneBindings.getParameter('lightWorldPosition' + lightId, 3);
			var lightSpecular		: SFloat = sceneBindings.getParameter('lightSpecular' + lightId, 1);
			var lightShininess		: SFloat = sceneBindings.getParameter('lightShininess' + lightId, 1);
			
			if (meshBindings.propertyExists(LightingProperties.SPECULAR_MULTIPLIER))
				lightSpecular.scaleBy(meshBindings.getParameter(LightingProperties.SPECULAR_MULTIPLIER, 1));
			
			if (meshBindings.propertyExists(LightingProperties.SHININESS_MULTIPLIER))
				lightShininess.scaleBy(meshBindings.getParameter(LightingProperties.SHININESS_MULTIPLIER, 1));
			
			var lightDirection		: SFloat = normalize(subtract(worldInterpolatedPosition, lightWorldPosition));
			var viewDirection		: SFloat = normalize(subtract(cameraWorldPosition, worldInterpolatedPosition));
			var lightReflection		: SFloat = reflect(lightDirection, worldInterpolatedNormal);
			
			var lambertProduct		: SFloat = saturate(dotProduct3(lightReflection, viewDirection));
			
			return multiply(lightSpecular, power(lambertProduct, lightShininess));
		}
	}
}
