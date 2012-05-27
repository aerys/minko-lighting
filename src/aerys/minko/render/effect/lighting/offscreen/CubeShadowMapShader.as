package aerys.minko.render.effect.lighting.offscreen
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.effect.basic.BasicProperties;
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.ShaderInstance;
	import aerys.minko.render.shader.ShaderSettings;
	import aerys.minko.render.shader.part.animation.VertexAnimationShaderPart;
	import aerys.minko.type.enum.Blending;
	import aerys.minko.type.enum.TriangleCulling;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Vector4;
	
	public class CubeShadowMapShader extends Shader
	{
		use namespace minko_lighting;
		
		private static const VIEW_MATRICES : Vector.<Matrix4x4> = new <Matrix4x4>[
			new Matrix4x4().lookAt(Vector4.ZERO, Vector4.X_AXIS,		Vector4.Y_AXIS),		// look at positive x
			new Matrix4x4().lookAt(Vector4.ZERO, new Vector4(-1, 0, 0),	Vector4.Y_AXIS),		// look at negative x
			new Matrix4x4().lookAt(Vector4.ZERO, Vector4.Y_AXIS,		new Vector4(0, 0, -1)),	// look at positive y
			new Matrix4x4().lookAt(Vector4.ZERO, new Vector4(0, -1, 0),	Vector4.Z_AXIS),		// look at negative y
			new Matrix4x4().lookAt(Vector4.ZERO, Vector4.Z_AXIS,		Vector4.Y_AXIS),		// look at positive z, that's identity!!
			new Matrix4x4().lookAt(Vector4.ZERO, new Vector4(0, 0, -1),	Vector4.Y_AXIS),		// look at negative z
		];
		
		private var _vertexAnimationPart	: VertexAnimationShaderPart;
		
		private var _lightId				: uint;
		private var _priority				: Number;
		private var _renderTarget			: RenderTarget;
		
		private var _lightToScreen			: Matrix4x4;
		private var _positionFromLight		: SFloat;
		
		public function CubeShadowMapShader(lightId		: uint, 
										  side			: uint, 
										  priority		: Number,
										  renderTarget	: RenderTarget)
		{
			var viewMatrix			: Matrix4x4 = VIEW_MATRICES[side];
			var modifierMatrix		: Matrix4x4 = new Matrix4x4().perspectiveFoV(Math.PI / 2, 1, 1, 1000);
			
			_vertexAnimationPart	= new VertexAnimationShaderPart(this);
			_priority				= priority;
			_renderTarget			= renderTarget;
			_lightToScreen			= new Matrix4x4().copyFrom(viewMatrix).append(modifierMatrix);
			_lightId				= lightId;	
		}
		
		override protected function initializeSettings(passConfig : ShaderSettings) : void
		{
			passConfig.triangleCulling	= meshBindings.getConstant(BasicProperties.TRIANGLE_CULLING, TriangleCulling.BACK);
			passConfig.triangleCulling = TriangleCulling.NONE;
			passConfig.blending			= Blending.NORMAL;
			passConfig.priority			= _priority;
			passConfig.renderTarget		= _renderTarget;
			passConfig.enabled			= meshBindings.getConstant(LightingProperties.CAST_SHADOWS, true);
		}
		
		override protected function getVertexPosition() : SFloat
		{
			var worldToLightName	: String = LightingProperties.getNameFor(_lightId, 'worldToLocal');
			
			var worldToLight		: SFloat = sceneBindings.getParameter(worldToLightName, 16);
			var position			: SFloat = _vertexAnimationPart.getAnimatedVertexPosition();
			var worldPosition		: SFloat = localToWorld(position);
			
			_positionFromLight = multiply4x4(worldPosition, worldToLight);
			
			return multiply4x4(_positionFromLight, _lightToScreen);
		}
		
		override protected function getPixelColor() : SFloat
		{
			var positionFromLight	: SFloat = interpolate(_positionFromLight);
			var distance			: SFloat = length(positionFromLight.xyz);
//			return float4(1, 0, 0, 1);
			distance = divide(distance, 255);
			
			return float4(distance.xxx, 1);
		}
	}
}
