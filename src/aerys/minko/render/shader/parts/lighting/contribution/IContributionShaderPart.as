package aerys.minko.render.shader.parts.lighting.contribution
{
	import aerys.minko.render.shader.SFloat;

	public interface IContributionShaderPart
	{
		function getDiffuseTerm(lightId						: uint, 
								worldPosition				: SFloat,
								worldNormal					: SFloat,
								worldInterpolatedPosition	: SFloat,
								worldInterpolatedNormal		: SFloat) : SFloat;
		
		function getSpecularTerm(lightId					: uint, 
								 worldPosition				: SFloat,
								 worldNormal				: SFloat,
								 worldInterpolatedPosition	: SFloat,
								 worldInterpolatedNormal	: SFloat) : SFloat;
	}
}
