package aerys.minko.render.shader.part.lighting.contribution
{
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.part.ShaderPart;
	import aerys.minko.render.shader.part.lighting.LightAwareShaderPart;
	
	public class LocalizedShaderPart extends LightAwareShaderPart implements IContributionShaderPart
	{
		public function LocalizedShaderPart(main : Shader)
		{
			super(main);
		}
		
		public function getDiffuse(lightId : uint, wPos : SFloat, wNrm : SFloat, iwPos : SFloat, iwNrm : SFloat) : SFloat
		{
			var lightWorldPosition		: SFloat = getLightParameter(lightId, 'worldPosition', 3);
			var lightDiffuse			: SFloat = getLightParameter(lightId, 'diffuse', 1);
			
			if (meshBindings.propertyExists(LightingProperties.DIFFUSE_MULTIPLIER))
				lightDiffuse.scaleBy(meshBindings.getParameter(LightingProperties.DIFFUSE_MULTIPLIER, 1));
			
			var lightDirection			: SFloat = normalize(subtract(lightWorldPosition, iwPos));
			var lambertProduct			: SFloat = saturate(dotProduct3(lightDirection, iwNrm));
			
			return multiply(lightDiffuse, lambertProduct);
		}
		
		public function getSpecular(lightId : uint, wPos : SFloat, wNrm : SFloat, iwPos : SFloat, iwNrm : SFloat) : SFloat
		{
			var lightWorldPosition		: SFloat = getLightParameter(lightId, 'worldPosition', 3);
			var lightSpecular			: SFloat = getLightParameter(lightId, 'specular', 1);
			var lightShininess			: SFloat = getLightParameter(lightId, 'shininess', 1);
			
			if (meshBindings.propertyExists(LightingProperties.SPECULAR_MULTIPLIER))
				lightSpecular.scaleBy(meshBindings.getParameter(LightingProperties.SPECULAR_MULTIPLIER, 1));
			
			if (meshBindings.propertyExists(LightingProperties.SHININESS_MULTIPLIER))
				lightShininess.scaleBy(meshBindings.getParameter(LightingProperties.SHININESS_MULTIPLIER, 1));
			
			var lightDirection			: SFloat = normalize(subtract(iwPos, lightWorldPosition));
			var viewDirection			: SFloat = normalize(subtract(cameraPosition, iwPos));
			var lightReflection			: SFloat = reflect(lightDirection, iwNrm);
			var lambertProduct			: SFloat = saturate(dotProduct3(lightReflection, viewDirection));
			
			return multiply(lightSpecular, power(lambertProduct, lightShininess));
		}
	}
}
