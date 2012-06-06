package aerys.minko.render.shader.part.lighting
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.part.ShaderPart;
	
	public class LightAwareShaderPart extends ShaderPart
	{
		use namespace minko_lighting;
		
		public function LightAwareShaderPart(main : Shader)
		{
			super(main);
		}
		
		public function lightPropertyExists(lightId : uint, name : String) : Boolean
		{
			var parameterName : String = LightingProperties.getNameFor(lightId, name);
			return sceneBindings.propertyExists(parameterName);
		}
		
		public function getLightConstant(lightId : uint, name : String, defaultValue : Object = null) : *
		{
			var parameterName : String = LightingProperties.getNameFor(lightId, name);
			return sceneBindings.getConstant(parameterName, defaultValue);
		}
		
		public function getLightParameter(lightId : uint, name : String, size : uint) : SFloat
		{
			var parameterName : String = LightingProperties.getNameFor(lightId, name);
			return sceneBindings.getParameter(parameterName, size);
		}
		
		public function getLightTextureParameter(lightId	: uint,
												 name		: String, 
												 filter		: uint = 1, 
												 mipmap		: uint = 0, 
												 wrapping	: uint = 1, 
												 dimension	: uint = 0) : SFloat
		{
			var parameterName : String = LightingProperties.getNameFor(lightId, name);
			return sceneBindings.getTextureParameter(parameterName, filter, mipmap, wrapping, dimension);
		}
	}
}
