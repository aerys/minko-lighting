package aerys.minko.render.shader.parts.lighting.attenuation
{
	import aerys.minko.render.shader.SFloat;

	public interface IAttenuationShaderPart
	{
		function getAttenuationFactor(lightId					: uint, 
									  worldPosition				: SFloat,
									  worldNormal				: SFloat,
									  worldInterpolatedPosition	: SFloat,
									  worldInterpolatedNormal	: SFloat) : SFloat;
	}
}
