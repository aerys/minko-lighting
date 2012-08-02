package aerys.minko.render.material.realistic
{
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.material.basic.BasicProperties;
	import aerys.minko.render.material.basic.BasicShader;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.part.BlendingShaderPart;
	import aerys.minko.render.shader.part.DiffuseShaderPart;
	import aerys.minko.render.shader.part.environment.EnvironmentMappingShaderPart;
	import aerys.minko.render.shader.part.phong.PhongShaderPart;
	
	public class RealisticShader extends BasicShader
	{
		private var _diffuse			: DiffuseShaderPart;
		private var _phong				: PhongShaderPart;
		private var _environmentMapping	: EnvironmentMappingShaderPart;
		private var _blending			: BlendingShaderPart;
		
		public function RealisticShader(priority		: Number		= 0.,
										renderTarget	: RenderTarget	= null)
		{
			super(renderTarget, priority);
			
			_diffuse			= new DiffuseShaderPart(this);
			_phong				= new PhongShaderPart(this);
			_environmentMapping = new EnvironmentMappingShaderPart(this);
			_blending			= new BlendingShaderPart(this);
		}
		
		override protected function getPixelColor() : SFloat
		{
			var diffuse	: SFloat	= _diffuse.getDiffuseColor();
			
			diffuse = _environmentMapping.applyEnvironmentMapping(diffuse);
			diffuse = _phong.applyPhongLighting(diffuse);
			
			if (meshBindings.propertyExists(BasicProperties.ALPHA_THRESHOLD))
			{
				var alphaThreshold : SFloat = meshBindings.getParameter(BasicProperties.ALPHA_THRESHOLD, 1);
				
				kill(subtract(0.5, lessThan(diffuse.w, alphaThreshold)));
			}
			
			return diffuse;
		}
	}
}