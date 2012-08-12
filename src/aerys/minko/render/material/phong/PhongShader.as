package aerys.minko.render.material.phong
{
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.material.basic.BasicShader;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.part.animation.VertexAnimationShaderPart;
	import aerys.minko.render.shader.part.phong.DiffuseShaderPart;
	import aerys.minko.render.shader.part.phong.PhongShaderPart;
	
	public class PhongShader extends BasicShader
	{
		private var _vertexAnimationPart	: VertexAnimationShaderPart;
		private var _pixelColorPart			: DiffuseShaderPart;
		private var _lightingPart			: PhongShaderPart;
		
		public function PhongShader(priority		: Number		= 0,
									renderTarget	: RenderTarget	= null)
		{
			super(renderTarget, priority);
			
			// init needed shader parts
			_vertexAnimationPart	= new VertexAnimationShaderPart(this);
			_pixelColorPart			= new DiffuseShaderPart(this);
			_lightingPart			= new PhongShaderPart(this);
		}
		
		override protected function getVertexPosition() : SFloat
		{
			return localToScreen(_vertexAnimationPart.getAnimatedVertexPosition());
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
