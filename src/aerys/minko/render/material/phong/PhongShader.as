package aerys.minko.render.material.phong
{
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.ShaderSettings;
	import aerys.minko.render.shader.part.BlendingShaderPart;
	import aerys.minko.render.shader.part.phong.DiffuseShaderPart;
	import aerys.minko.render.shader.part.animation.VertexAnimationShaderPart;
	import aerys.minko.render.shader.part.phong.PhongShaderPart;
	import aerys.minko.render.shader.part.phong.attenuation.CubeShadowMapAttenuationShaderPart;
	import aerys.minko.render.shader.part.phong.attenuation.MatrixShadowMapAttenuationShaderPart;
	import aerys.minko.type.enum.Blending;
	import aerys.minko.type.enum.DepthTest;
	import aerys.minko.type.enum.SamplerDimension;
	import aerys.minko.type.enum.SamplerFiltering;
	import aerys.minko.type.enum.SamplerMipMapping;
	import aerys.minko.type.enum.SamplerWrapping;
	import aerys.minko.type.enum.TriangleCulling;
	import aerys.minko.render.geometry.stream.format.VertexComponent;
	
	public class PhongShader extends Shader
	{
		private var _vertexAnimationPart	: VertexAnimationShaderPart;
		private var _pixelColorPart			: DiffuseShaderPart;
		private var _lightingPart			: PhongShaderPart;
		
		private var _priority				: Number;
		private var _renderTarget			: RenderTarget;
		
		public function PhongShader(priority		: Number		= 0,
									 renderTarget	: RenderTarget	= null)
		{
			// init needed shader parts
			_vertexAnimationPart	= new VertexAnimationShaderPart(this);
			_pixelColorPart			= new DiffuseShaderPart(this);
			_lightingPart			= new PhongShaderPart(this);
			
			// save priority and render target to configure pass later
			_priority				= priority;
			_renderTarget			= renderTarget;
		}
		
		override protected function initializeSettings(passConfig : ShaderSettings) : void
		{
			var blending : uint = meshBindings.getConstant("blending", Blending.NORMAL);
			
			if (blending == Blending.ALPHA || blending == Blending.ADDITIVE)
				passConfig.priority -= 0.5;
			
			passConfig.priority			= _priority;
			passConfig.renderTarget		= _renderTarget;
			
			passConfig.depthTest		= meshBindings.getConstant("depthTest", DepthTest.LESS);
			passConfig.blending			= blending;
			passConfig.triangleCulling	= meshBindings.getConstant("triangleCulling", TriangleCulling.BACK);
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
