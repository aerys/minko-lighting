package aerys.minko.render.effect.lighting.depth
{
	import aerys.minko.Minko;
	import aerys.minko.render.effect.animation.AnimationStyle;
	import aerys.minko.render.shader.ActionScriptShader;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.render.shader.parts.animation.AnimationShaderPart;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	import aerys.minko.type.animation.AnimationMethod;
	import aerys.minko.type.log.DebugLevel;
	import aerys.minko.type.math.ConstVector4;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Vector4;
	
	import flash.utils.Dictionary;
	
	public class CubeShadowMapShader extends ActionScriptShader
	{
		private var _animationPart 		: AnimationShaderPart = null;
		
		private var _lightId			: uint;
		private var _side				: uint;
		
		private var _positionFromLight	: SValue;
		
		public function CubeShadowMapShader(lightId	: uint,
											side	: uint)
		{
			_lightId	= lightId;	
			_side		= side;
			
			_animationPart = new AnimationShaderPart(this);
		}
		
		private static const VIEW_MATRICES : Vector.<Matrix4x4> = Vector.<Matrix4x4>([
			Matrix4x4.lookAtLH(ConstVector4.ZERO, ConstVector4.X_AXIS,		ConstVector4.Y_AXIS),	 // look at positive x
			Matrix4x4.lookAtLH(ConstVector4.ZERO, new Vector4(-1, 0, 0),	ConstVector4.Y_AXIS),	 // look at negative x
			Matrix4x4.lookAtLH(ConstVector4.ZERO, ConstVector4.Y_AXIS,		new Vector4(0, 0, -1)),	 // look at positive y
			Matrix4x4.lookAtLH(ConstVector4.ZERO, new Vector4(0, -1, 0),	ConstVector4.Z_AXIS),	 // look at negative y
			Matrix4x4.lookAtLH(ConstVector4.ZERO, ConstVector4.Z_AXIS,		ConstVector4.Y_AXIS),	 // look at positive z // identity!!
			Matrix4x4.lookAtLH(ConstVector4.ZERO, new Vector4(0, 0, -1),	ConstVector4.Y_AXIS),	 // look at negative z
		]);
		
		override protected function getOutputPosition() : SValue
		{
			
			Minko.debugLevel = DebugLevel.SHADER_AGAL;
			
			var animationMethod		: uint	 = uint(getStyleConstant(AnimationStyle.METHOD, AnimationMethod.DISABLED));
			var maxInfluences		: uint	 = uint(getStyleConstant(AnimationStyle.MAX_INFLUENCES, 0));
			var numBones			: uint	 = uint(getStyleConstant(AnimationStyle.NUM_BONES, 0));
			var vertexPosition		: SValue = _animationPart.getVertexPosition(animationMethod, maxInfluences, numBones);
			
			var localToLight		: SValue = getWorldParameter(16, LightData, LightData.LOCAL_TO_LIGHT, _lightId);
			var lightToScreen		: SValue = new SValue(Matrix4x4.multiply(
				Matrix4x4.perspectiveFoVLH(Math.PI / 2, 1, 1, 1000),
				VIEW_MATRICES[_side]
			));
			
			_positionFromLight = multiply4x4(vertexPosition, localToLight);
			return multiply4x4(_positionFromLight, lightToScreen);
		}
		
		override protected function getOutputColor() : SValue
		{
			var distance : SValue = length(interpolate(_positionFromLight).xyz);
			distance = divide(distance, 255);
			return float4(distance.xxx, 1);
		}
		
		override public function getDataHash(styleData		: StyleData, 
											 transformData	: TransformData, 
											 worldData		: Dictionary) : String
		{
			var hash : String = 'frustumShadowMapDepthShader';
			hash += _animationPart.getDataHash(styleData, transformData, worldData)
			hash += _lightId
			hash += _side;
			
			return hash;
		}
		
	}
}