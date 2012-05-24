package aerys.minko.render.shader.parts.lighting.attenuation
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.part.ShaderPart;
	
	public class DistanceAttenuationShaderPart extends ShaderPart implements IAttenuationShaderPart
	{
		use namespace minko_lighting;
		
		public function DistanceAttenuationShaderPart(main : Shader)
		{
			super(main);
		}
		
		public function getAttenuation(lightId : uint, wPos : SFloat, wNrm : SFloat, iwPos : SFloat, iwNrm : SFloat) : SFloat
		{
			var lightWorldPositionName	: String = LightingProperties.getNameFor(lightId, 'worldPosition');
			var lightAttDistanceName	: String = LightingProperties.getNameFor(lightId, 'attenuationDistance');
			
			var lightWorldPosition		: SFloat = sceneBindings.getParameter(lightWorldPositionName, 3);
			var lightDistance 			: SFloat = sceneBindings.getParameter(lightAttDistanceName, 1);
			
			var lightSquareDistance		: SFloat = multiply(lightDistance, lightDistance);
			var lightToPoint			: SFloat = subtract(iwPos, lightWorldPosition);
			var squareDistance			: SFloat = dotProduct3(lightToPoint, lightToPoint);
			
			return saturate(divide(lightSquareDistance, squareDistance));
		}
	}
}
