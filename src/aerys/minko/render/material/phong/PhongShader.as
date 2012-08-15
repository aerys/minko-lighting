package aerys.minko.render.material.phong
{
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.material.basic.BasicShader;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.part.phong.DiffuseShaderPart;
	import aerys.minko.render.shader.part.phong.PhongShaderPart;
	
	public class PhongShader extends BasicShader
	{
		private var _pixelColorPart	: DiffuseShaderPart;
		private var _lightingPart	: PhongShaderPart;
		
		public function PhongShader(renderTarget	: RenderTarget	= null,
									priority		: Number		= 0.)
		{
			super(renderTarget, priority);
			
			// init shader parts
			_pixelColorPart	= new DiffuseShaderPart(this);
			_lightingPart	= new PhongShaderPart(this);
		}
		
		override protected function getPixelColor() : SFloat
		{
			var color	 : SFloat = _pixelColorPart.getDiffuse();
			var lighting : SFloat = _lightingPart.getLightingColor();
			
			color = float4(multiply(lighting, color.rgb), color.a);
			
			return color;
		}
	}
}
