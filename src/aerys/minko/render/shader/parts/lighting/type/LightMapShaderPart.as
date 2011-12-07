package aerys.minko.render.shader.parts.lighting.type
{
	import aerys.minko.render.effect.lighting.LightingStyle;
	import aerys.minko.render.shader.ActionScriptShaderPart;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.type.math.Vector4;
	
	public class LightMapShaderPart extends ActionScriptShaderPart
	{
		public function getLightContribution() : SValue
		{
			var lightMapValue		: SValue = sampleTexture(LightingStyle.LIGHTMAP, interpolate(vertexUV));
			var lightMapMultiplier	: SValue = getStyleParameter(4, LightingStyle.LIGHTMAP_MULTIPLIER, new Vector4(1, 1, 1, 1));
			
			return multiply(lightMapValue, lightMapMultiplier);
		}
	}
}