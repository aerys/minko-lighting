package aerys.minko.render.material.environment
{
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.material.basic.BasicShader;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.part.BlendingShaderPart;
	import aerys.minko.render.shader.part.environment.EnvironmentMappingShaderPart;
	import aerys.minko.type.enum.Blending;
	import aerys.minko.type.enum.EnvironmentMappingType;
	
	public class EnvironmentMappingShader extends BasicShader
	{
		private var _blendingPart	: BlendingShaderPart;
		private var _reflectionPart	: EnvironmentMappingShaderPart;
		
		public function EnvironmentMappingShader(renderTarget	: RenderTarget 	= null,
										 		 priority		: Number 		= 0)
		{
			super(renderTarget, priority);
			
			// init needed shader parts
			_reflectionPart	= new EnvironmentMappingShaderPart(this);
			_blendingPart	= new BlendingShaderPart(this);
		}
		
		override protected function getPixelColor() : SFloat
		{
			var color			: SFloat 	= super.getPixelColor();
			var reflectionType	: uint 		= meshBindings.getConstant(
				EnvironmentMappingProperties.ENVIRONMENT_MAPPING_TYPE, EnvironmentMappingType.NONE
			);
			
			if (reflectionType != EnvironmentMappingType.NONE)
			{
				var reflectionColor	: SFloat	= _reflectionPart.getEnvironmentColor();
				var blending		: uint		= meshBindings.getConstant(
					EnvironmentMappingProperties.ENVIRONMENT_BLENDING, Blending.ALPHA
				);
				
				color = _blendingPart.blend(reflectionColor, color, blending);
			}
			
			return color;
		}
	}
}
