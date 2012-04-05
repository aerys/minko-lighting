package aerys.minko.render.shader.parts.lighting.attenuation
{
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.part.ShaderPart;
	import aerys.minko.type.stream.format.VertexComponent;
	
	public class SmoothConicAttenuationShaderPart extends ShaderPart implements IAttenuationShaderPart
	{
		public function SmoothConicAttenuationShaderPart(main : Shader)
		{
			super(main);
		}
		
		public function getAttenuationFactor(lightId					: uint,
											 worldPosition				: SFloat,
											 worldNormal				: SFloat,
											 worldInterpolatedPosition	: SFloat,
											 worldInterpolatedNormal	: SFloat) : SFloat
		{
			// retrieve light data.
			var lightWorldPosition	: SFloat = sceneBindings.getParameter('lightWorldPosition' + lightId, 3);
			var lightWorldDirection	: SFloat = sceneBindings.getParameter('lightWorldDirection' + lightId, 3);
			
			// compute cone (constant) factors. This will be resolved by the compiler.
			var lightInnerRadius	: SFloat = sceneBindings.getParameter('lightInnerRadius' + lightId, 1);
			var lightOuterRadius	: SFloat = sceneBindings.getParameter('lightOuterRadius' + lightId, 1);
			
			var factor1				: SFloat = divide(-1, subtract(cos(lightOuterRadius), cos(lightInnerRadius)));
			var factor2				: SFloat = subtract(1, multiply(cos(lightInnerRadius), factor1));
			
			// compute attenuation factor
			var lightToPoint		: SFloat = subtract(worldInterpolatedPosition, lightWorldPosition);
			var lightAngleCosine	: SFloat = dotProduct3(lightWorldDirection, normalize(lightToPoint));
			
			return saturate(add(multiply(factor1, lightAngleCosine), factor2));
		}
		
	}
}
