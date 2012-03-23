package aerys.minko.render.shader.parts.lighting.attenuation
{
	import aerys.minko.render.shader.PassTemplate;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.part.ShaderPart;
	import aerys.minko.type.stream.format.VertexComponent;
	
	public class DistanceAttenuationShaderPart extends ShaderPart implements IAttenuationShaderPart
	{
		public function DistanceAttenuationShaderPart(main : PassTemplate)
		{
			super(main);
		}
		
		public function getAttenuationFactor(lightId					: uint,
											 worldPosition				: SFloat,
											 worldNormal				: SFloat,
											 worldInterpolatedPosition	: SFloat,
											 worldInterpolatedNormal	: SFloat) : SFloat
		{
			var lightWorldPosition	: SFloat = sceneBindings.getParameter('lightWorldPosition' + lightId, 3);
			var lightDistance 		: SFloat = sceneBindings.getParameter('lightDistance' + lightId, 1);
			var lightSquareDistance	: SFloat = multiply(lightDistance, lightDistance);
			
			var lightToPoint		: SFloat = subtract(worldInterpolatedPosition, lightWorldPosition);
			var squareDistance		: SFloat = dotProduct3(lightToPoint, lightToPoint);
			
			return saturate(divide(lightSquareDistance, squareDistance));
		}
	}
}
