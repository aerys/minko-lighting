package aerys.minko.render.shader.parts.lighting.attenuation
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.part.ShaderPart;
	
	public class HardConicAttenuationShaderPart extends ShaderPart implements IAttenuationShaderPart
	{
		use namespace minko_lighting;
		
		public function HardConicAttenuationShaderPart(main : Shader)
		{
			super(main);
		}
		
		public function getAttenuation(lightId : uint, wPos : SFloat, wNrm : SFloat, iwPos : SFloat, iwNrm : SFloat) : SFloat
		{
			var lightWorldPositionName	: String = LightingProperties.getNameFor(lightId, 'worldPosition');
			var lightWorldDirectionName	: String = LightingProperties.getNameFor(lightId, 'worldDirection');
			var lightRadiusName			: String = LightingProperties.getNameFor(lightId, 'outerRadius');
			
			var lightWorldPosition		: SFloat = sceneBindings.getParameter(lightWorldPositionName, 3);
			var lightWorldDirection		: SFloat = sceneBindings.getParameter(lightWorldDirectionName, 3);
			var lightRadius				: SFloat = sceneBindings.getParameter(lightRadiusName, 1);
			
			var lightRadiusCosine		: SFloat = cos(divide(lightRadius, 2));
			var lightToPoint			: SFloat = subtract(iwPos, lightWorldPosition);
			var lightAngleCosine		: SFloat = dotProduct3(lightWorldDirection, normalize(lightToPoint));
			
			return greaterEqual(lightAngleCosine, lightRadiusCosine);
		}
	}
}
