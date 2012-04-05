package aerys.minko.render.shader.parts.lighting.attenuation
{
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.part.ShaderPart;
	import aerys.minko.type.stream.format.VertexComponent;
	
	public class HardConicAttenuationShaderPart extends ShaderPart implements IAttenuationShaderPart
	{
		public function HardConicAttenuationShaderPart(main : Shader)
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
			var lightWorldDirection	: SFloat = sceneBindings.getParameter('lightWorldDirection' + lightId, 3);
			var lightRadius			: SFloat = sceneBindings.getParameter('lightOuterRadius' + lightId, 1);
			
			var lightRadiusCosine	: SFloat = cos(lightRadius);
			var lightToPoint		: SFloat = subtract(worldInterpolatedPosition, lightWorldPosition);
			var lightAngleCosine	: SFloat = dotProduct3(lightWorldDirection, normalize(lightToPoint));
			
			return greaterEqual(lightAngleCosine, lightRadiusCosine);
		}
	}
}
