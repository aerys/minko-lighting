package aerys.minko.render.material.phong
{
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.material.basic.BasicShader;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.part.phong.LightAwareDiffuseShaderPart;
	import aerys.minko.render.shader.part.phong.PhongShaderPart;
	
	public class PhongShader extends BasicShader
	{
		private var _pixelColorPart	: LightAwareDiffuseShaderPart;
		private var _lightingPart	: PhongShaderPart;
		
		public function PhongShader(renderTarget	: RenderTarget	= null,
									priority		: Number		= 0.)
		{
			super(renderTarget, priority);
			
			// init shader parts
			_pixelColorPart	= new LightAwareDiffuseShaderPart(this);
			_lightingPart	= new PhongShaderPart(this);
		}
		
		override protected function getPixelColor() : SFloat
		{
			var color	 : SFloat = _pixelColorPart.getDiffuseColor();
			var lighting : SFloat = _lightingPart.getLightingColor();
			
			color = float4(multiply(lighting, color.rgb), color.a);
			
			return color;
		}
	}
}
