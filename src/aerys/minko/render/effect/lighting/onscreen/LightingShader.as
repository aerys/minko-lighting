package aerys.minko.render.effect.lighting.onscreen
{
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.ActionScriptShader;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.part.BlendingShaderPart;
	import aerys.minko.render.shader.part.PixelColorShaderPart;
	import aerys.minko.render.shader.part.animation.VertexAnimationShaderPart;
	import aerys.minko.render.shader.parts.lighting.LightingShaderPart;
	import aerys.minko.type.enum.Blending;
	import aerys.minko.type.enum.DepthTest;
	import aerys.minko.type.enum.TriangleCulling;
	import aerys.minko.type.stream.format.VertexComponent;
	
	public class LightingShader extends ActionScriptShader
	{
		private var _vertexAnimationPart	: VertexAnimationShaderPart;
		private var _pixelColorPart			: PixelColorShaderPart;
		private var _blendingPart			: BlendingShaderPart;
		private var _lightingPart			: LightingShaderPart;
		
		private var _vertexPosition			: SFloat;
		private var _vertexUV				: SFloat;
		private var _vertexNormal			: SFloat;
		
		public function LightingShader(priority	: Number		= 0,
									   target	: RenderTarget	= null)
		{
			super(priority, target);
			
			_vertexAnimationPart	= new VertexAnimationShaderPart(this);
			_pixelColorPart			= new PixelColorShaderPart(this);
			_blendingPart			= new BlendingShaderPart(this);
			_lightingPart			= new LightingShaderPart(this);
			
			defaultMeshProperties = {
				blending 			: Blending.NORMAL,
				triangleCulling 	: TriangleCulling.BACK,
				depthTest			: DepthTest.LESS,
				enableDepthWrite	: true,
				lightGroup			: 1
			};
		}
		
		override protected function initializeFork(fork : Shader) : void
		{
			super.initializeFork(fork);
			
			var blending : uint = meshBindings.getProperty("blending");
			
			if (blending == Blending.ALPHA || blending == Blending.ADDITIVE)
				fork.priority -= 0.5;
			
			fork.depthTest			= meshBindings.getProperty("depthTest");
			fork.blending			= blending;
			fork.triangleCulling	= meshBindings.getProperty("triangleCulling");
		}
		
		override protected function getVertexPosition() : SFloat
		{
			_vertexPosition = _vertexAnimationPart.getAnimatedVertexPosition();
			_vertexUV		= getVertexAttribute(VertexComponent.UV);
			_vertexNormal	= _vertexAnimationPart.getAnimatedVertexNormal();
			
//			if (meshBindings.propertyExists("triangleCulling")
//				&& meshBindings.getProperty('triangleCulling') == TriangleCulling.FRONT)
//				_vertexNormal = negate(_vertexNormal);
			
			return localToScreen(_vertexPosition);
		}
		
		override protected function getPixelColor() : SFloat
		{
			var color		: SFloat	= _pixelColorPart.getPixelColor();
			var lighting	: SFloat	= _lightingPart.getLightingColor(_vertexPosition, _vertexUV, _vertexNormal);
			
			color.scaleBy(lighting);
			
			return color;
		}
		
	}
}