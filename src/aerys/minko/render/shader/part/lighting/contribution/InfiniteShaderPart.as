package aerys.minko.render.shader.part.lighting.contribution
{
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.part.lighting.LightAwareShaderPart;

	public class InfiniteShaderPart extends LightAwareShaderPart implements IContributionShaderPart
	{
		public function InfiniteShaderPart(main : Shader)
		{
			super(main);
		}
		
		public function getDiffuse(lightId : uint, wPos : SFloat, wNrm : SFloat, iwPos : SFloat, iwNrm : SFloat) : SFloat
		{
			var worldDirection 	: SFloat = getLightParameter(lightId, 'worldDirection', 3);
			var diffuse			: SFloat = getLightParameter(lightId, 'diffuse', 1);
			
			if (meshBindings.propertyExists(LightingProperties.DIFFUSE_MULTIPLIER))
				diffuse.scaleBy(meshBindings.getParameter(LightingProperties.DIFFUSE_MULTIPLIER, 1));
			
			var lambertProduct	: SFloat = saturate(negate(dotProduct3(worldDirection, iwNrm)));
			
			return multiply(diffuse, lambertProduct);
		}
		
		public function getSpecular(lightId : uint, wPos : SFloat, wNrm : SFloat, iwPos : SFloat, iwNrm : SFloat) : SFloat
		{
			var lightDirection	: SFloat = getLightParameter(lightId, 'worldDirection', 3);
			var lightSpecular	: SFloat = getLightParameter(lightId, 'specular', 1);
			var lightShininess	: SFloat = getLightParameter(lightId, 'shininess', 1);
			
			if (meshBindings.propertyExists(LightingProperties.SPECULAR_MULTIPLIER))
				lightSpecular.scaleBy(meshBindings.getParameter(LightingProperties.SPECULAR_MULTIPLIER, 1));
			
			if (meshBindings.propertyExists(LightingProperties.SHININESS_MULTIPLIER))
				lightShininess.scaleBy(meshBindings.getParameter(LightingProperties.SHININESS_MULTIPLIER, 1));
			
			var viewDirection	: SFloat = normalize(subtract(iwPos, cameraPosition));
			var lightReflection	: SFloat = reflect(lightDirection, iwNrm);
			var lambertProduct	: SFloat = saturate(negate(dotProduct3(lightReflection, viewDirection)));
			
			return multiply(lightSpecular, power(lambertProduct, lightShininess));
		}
	}
}
