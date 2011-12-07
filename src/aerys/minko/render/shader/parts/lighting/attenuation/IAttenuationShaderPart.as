package aerys.minko.render.shader.parts.lighting.attenuation
{
	import aerys.minko.render.shader.SValue;
	import aerys.minko.scene.data.LightData;

	public interface IAttenuationShaderPart
	{
		function getDynamicFactor(lightId	: uint,
								  position	: SValue = null) : SValue;
		
		function getStaticFactor(lightData	: LightData,
								 position	: SValue = null) : SValue
	}
}