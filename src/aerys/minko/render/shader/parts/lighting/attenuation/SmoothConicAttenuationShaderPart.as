package aerys.minko.render.shader.parts.lighting.attenuation
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.part.ShaderPart;
	
	public class SmoothConicAttenuationShaderPart extends ShaderPart implements IAttenuationShaderPart
	{
		use namespace minko_lighting;
		
		public function SmoothConicAttenuationShaderPart(main : Shader)
		{
			super(main);
		}
		
		public function getAttenuation(lightId : uint, wPos : SFloat, wNrm : SFloat, iwPos : SFloat, iwNrm : SFloat) : SFloat
		{
			// retrieve light data.
			var lightWorldPositionName	: String = LightingProperties.getNameFor(lightId, 'worldPosition');
			var lightWorldDirectionName	: String = LightingProperties.getNameFor(lightId, 'worldDirection');
			var lightWorldPosition		: SFloat = sceneBindings.getParameter(lightWorldPositionName, 3);
			var lightWorldDirection		: SFloat = sceneBindings.getParameter(lightWorldDirectionName, 3);
			
			// compute cone (constant) factors. This will be resolved by the compiler.
			var lightInnerRadiusName	: String = LightingProperties.getNameFor(lightId, 'innerRadius');
			var lightOuterRadiusName	: String = LightingProperties.getNameFor(lightId, 'outerRadius');
			var lightInnerRadius		: SFloat = sceneBindings.getParameter(lightInnerRadiusName, 1);
			var lightOuterRadius		: SFloat = sceneBindings.getParameter(lightOuterRadiusName, 1);
			
			var factor1					: SFloat = divide(-1, subtract(cos(lightOuterRadius), cos(lightInnerRadius)));
			var factor2					: SFloat = subtract(1, multiply(cos(lightInnerRadius), factor1));
			
			// compute attenuation factor
			var lightToPoint			: SFloat = subtract(iwPos, lightWorldPosition);
			var lightAngleCosine		: SFloat = dotProduct3(lightWorldDirection, normalize(lightToPoint));
			
			return saturate(add(multiply(factor1, lightAngleCosine), factor2));
		}
		
	}
}
