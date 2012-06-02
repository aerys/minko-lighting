package aerys.minko.render.shader.parts.lighting.contribution
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.part.ShaderPart;

	public class InfiniteShaderPart extends ShaderPart implements IContributionShaderPart
	{
		use namespace minko_lighting;
		
		public function InfiniteShaderPart(main : Shader)
		{
			super(main);
		}
		
		public function getDiffuse(lightId : uint, wPos : SFloat, wNrm : SFloat, iwPos : SFloat, iwNrm : SFloat) : SFloat
		{
			var worldDirectionName	: String = LightingProperties.getNameFor(lightId, 'worldDirection');
			var diffuseName			: String = LightingProperties.getNameFor(lightId, 'diffuse');
			
			var worldDirection 		: SFloat = sceneBindings.getParameter(worldDirectionName, 3);
			var diffuse				: SFloat = sceneBindings.getParameter(diffuseName, 1);
			
			if (meshBindings.propertyExists(LightingProperties.DIFFUSE_MULTIPLIER))
				diffuse.scaleBy(meshBindings.getParameter(LightingProperties.DIFFUSE_MULTIPLIER, 1));
			
			var lambertProduct		: SFloat = saturate(negate(dotProduct3(worldDirection, iwNrm)));
			
			return multiply(diffuse, lambertProduct);
		}
		
		public function getSpecular(lightId : uint, wPos : SFloat, wNrm : SFloat, iwPos : SFloat, iwNrm : SFloat) : SFloat
		{
			var lightDirectionName	: String = LightingProperties.getNameFor(lightId, 'worldDirection');
			var lightSpecularName	: String = LightingProperties.getNameFor(lightId, 'specular');
			var lightShininessName	: String = LightingProperties.getNameFor(lightId, 'shininess');
			
			var lightDirection		: SFloat = sceneBindings.getParameter(lightDirectionName, 3);
			var lightSpecular		: SFloat = sceneBindings.getParameter(lightSpecularName, 1);
			var lightShininess		: SFloat = sceneBindings.getParameter(lightShininessName, 1);
			
			if (meshBindings.propertyExists(LightingProperties.SPECULAR_MULTIPLIER))
				lightSpecular.scaleBy(meshBindings.getParameter(LightingProperties.SPECULAR_MULTIPLIER, 1));
			
			if (meshBindings.propertyExists(LightingProperties.SHININESS_MULTIPLIER))
				lightShininess.scaleBy(meshBindings.getParameter(LightingProperties.SHININESS_MULTIPLIER, 1));
			
			var viewDirection		: SFloat = normalize(subtract(iwPos, cameraPosition));
			var lightReflection		: SFloat = reflect(lightDirection, iwNrm);
			var lambertProduct		: SFloat = saturate(negate(dotProduct3(lightReflection, viewDirection)));
			
			return multiply(lightSpecular, power(lambertProduct, lightShininess));
		}
	}
}
