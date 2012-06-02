package aerys.minko.render.shader.parts.lighting.contribution
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.part.ShaderPart;
	
	public class LocalizedShaderPart extends ShaderPart implements IContributionShaderPart
	{
		use namespace minko_lighting;
		
		public function LocalizedShaderPart(main : Shader)
		{
			super(main);
		}
		
		public function getDiffuse(lightId : uint, wPos : SFloat, wNrm : SFloat, iwPos : SFloat, iwNrm : SFloat) : SFloat
		{
			var lightWorldPositionName	: String = LightingProperties.getNameFor(lightId, 'worldPosition');
			var lightDiffuseName		: String = LightingProperties.getNameFor(lightId, 'diffuse');
			
			var lightWorldPosition		: SFloat = sceneBindings.getParameter(lightWorldPositionName, 3);
			var lightDiffuse			: SFloat = sceneBindings.getParameter(lightDiffuseName, 1);
			
			if (meshBindings.propertyExists(LightingProperties.DIFFUSE_MULTIPLIER))
				lightDiffuse.scaleBy(meshBindings.getParameter(LightingProperties.DIFFUSE_MULTIPLIER, 1));
			
			var lightDirection			: SFloat = normalize(subtract(lightWorldPosition, iwPos));
			var lambertProduct			: SFloat = saturate(dotProduct3(lightDirection, iwNrm));
			
			return multiply(lightDiffuse, lambertProduct);
		}
		
		public function getSpecular(lightId : uint, wPos : SFloat, wNrm : SFloat, iwPos : SFloat, iwNrm : SFloat) : SFloat
		{
			var lightWorldPositionName	: String = LightingProperties.getNameFor(lightId, 'worldPosition');
			var lightSpecularName		: String = LightingProperties.getNameFor(lightId, 'specular');
			var lightShininessName		: String = LightingProperties.getNameFor(lightId, 'shininess');
			
			var lightWorldPosition		: SFloat = sceneBindings.getParameter(lightWorldPositionName, 3);
			var lightSpecular			: SFloat = sceneBindings.getParameter(lightSpecularName, 1);
			var lightShininess			: SFloat = sceneBindings.getParameter(lightShininessName, 1);
			
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
