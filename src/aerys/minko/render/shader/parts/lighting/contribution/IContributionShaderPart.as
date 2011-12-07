package aerys.minko.render.shader.parts.lighting.contribution
{
	import aerys.minko.render.shader.SValue;
	import aerys.minko.scene.data.LightData;

	public interface IContributionShaderPart
	{
		function getDynamicTerm(lightId		: uint,
								lightData	: LightData,
								position	: SValue = null,
							    normal		: SValue = null) : SValue;
		
		function getDynamicDataHash(lightData : LightData) : String;
		
		function getStaticTerm(lightData	: LightData,
							   position		: SValue = null,
							   normal		: SValue = null) : SValue;
		
		function getStaticDataHash(lightData : LightData) : String;
		
	}
}