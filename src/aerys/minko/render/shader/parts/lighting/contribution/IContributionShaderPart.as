package aerys.minko.render.shader.parts.lighting.contribution
{
	import aerys.minko.render.shader.SFloat;

	public interface IContributionShaderPart
	{
		function getDiffuse(lightId						: uint, 
								worldPosition				: SFloat,
								worldNormal					: SFloat,
								worldInterpolatedPosition	: SFloat,
								worldInterpolatedNormal		: SFloat) : SFloat;
		
		function getSpecular(lightId					: uint, 
								 worldPosition				: SFloat,
								 worldNormal				: SFloat,
								 worldInterpolatedPosition	: SFloat,
								 worldInterpolatedNormal	: SFloat) : SFloat;
	}
}
