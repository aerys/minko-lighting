package aerys.minko.render.shader.parts.lighting.type
{
	import aerys.minko.render.shader.ActionScriptShader;
	import aerys.minko.render.shader.ActionScriptShaderPart;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.scene.data.LightData;
	
	public class AmbientLightShaderPart extends ActionScriptShaderPart
	{
		public function AmbientLightShaderPart(main : ActionScriptShader)
		{
			super(main);
		}
		
		public function getDynamicLightContribution(lightId : uint) : SValue
		{
			return getWorldParameter(1, LightData, LightData.LOCAL_AMBIENT, lightId);
		}
		
	}
}
