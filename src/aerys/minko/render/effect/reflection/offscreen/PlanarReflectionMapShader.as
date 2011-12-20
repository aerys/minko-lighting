package aerys.minko.render.effect.reflection.offscreen
{
	import aerys.minko.render.effect.animation.AnimationStyle;
	import aerys.minko.render.effect.basic.BasicStyle;
	import aerys.minko.render.shader.ActionScriptShader;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.render.shader.parts.animation.AnimationShaderPart;
	import aerys.minko.render.shader.parts.diffuse.DiffuseShaderPart;
	import aerys.minko.scene.data.CameraData;
	import aerys.minko.scene.data.ReflectionData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	import aerys.minko.type.animation.AnimationMethod;
	
	import flash.utils.Dictionary;
	
	public class PlanarReflectionMapShader extends ActionScriptShader
	{
		private var _animationPart	: AnimationShaderPart;
		private var _diffusePart	: DiffuseShaderPart;
		
		private var _reflectionId	: uint;
		private var _vertexPosition	: SValue;
		
		public function PlanarReflectionMapShader(reflectionId : uint)
		{
			_reflectionId	= reflectionId;
			_animationPart	= new AnimationShaderPart(this);
			_diffusePart	= new DiffuseShaderPart(this);
		}
		
		override protected function getOutputPosition() : SValue
		{
			var animationMethod		: uint	 = uint(getStyleConstant(AnimationStyle.METHOD, AnimationMethod.DISABLED));
			var maxInfluences		: uint	 = uint(getStyleConstant(AnimationStyle.MAX_INFLUENCES, 0));
			var numBones			: uint	 = uint(getStyleConstant(AnimationStyle.NUM_BONES, 0));
			_vertexPosition = _animationPart.getVertexPosition(animationMethod, maxInfluences, numBones);
			
			var localToScreen		: SValue = getWorldParameter(16, ReflectionData, ReflectionData.LOCAL_TO_SCREEN, _reflectionId);
			
			return multiply4x4(_vertexPosition, localToScreen);
		}
		
		override protected function getOutputColor() : SValue
		{
			var diffuseStyle	: Object = styleIsSet(BasicStyle.DIFFUSE) ? getStyleConstant(BasicStyle.DIFFUSE) : null;
			var diffuse			: SValue = _diffusePart.getDiffuseColor(diffuseStyle);
			
			var localToSurface			: SValue = getWorldParameter(16, ReflectionData, ReflectionData.LOCAL_TO_PLANE, _reflectionId);
			var pixelIsAfterThePlane	: SValue = multiply4x4(interpolate(_vertexPosition), localToSurface).z;
			var cameraIsAfterThePlane	: SValue = getWorldParameter(1, ReflectionData, ReflectionData.CAMERA_SIDE, _reflectionId);
			
			kill(multiply(cameraIsAfterThePlane, pixelIsAfterThePlane));
			
			return diffuse;
		}
		
		override public function getDataHash(styleData		: StyleData, 
											 transformData	: TransformData, 
											 worldData		: Dictionary) : String
		{
			var hash : String = '';
			
			hash += _animationPart.getDataHash(styleData, transformData, worldData);
			hash += _diffusePart.getDataHash(styleData, transformData, worldData);
			
			return hash;
		}
		
	}
}
