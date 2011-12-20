package aerys.minko.render.effect.reflection.onscreen
{
	import aerys.minko.render.effect.animation.AnimationStyle;
	import aerys.minko.render.effect.basic.BasicStyle;
	import aerys.minko.render.effect.lighting.LightingStyle;
	import aerys.minko.render.effect.reflection.ReflectionStyle;
	import aerys.minko.render.effect.reflection.ReflectionType;
	import aerys.minko.render.renderer.RendererState;
	import aerys.minko.render.shader.ActionScriptShader;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.render.shader.parts.animation.AnimationShaderPart;
	import aerys.minko.render.shader.parts.diffuse.DiffuseShaderPart;
	import aerys.minko.render.shader.parts.lighting.LightingShaderPart;
	import aerys.minko.render.shader.parts.reflection.ReflectionShaderPart;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.ReflectionData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	import aerys.minko.scene.data.WorldDataList;
	import aerys.minko.type.animation.AnimationMethod;
	import aerys.minko.type.enum.Blending;
	
	import flash.utils.Dictionary;
	
	public class ReflectionShader extends ActionScriptShader
	{
		private var _animationPart	: AnimationShaderPart;
		private var _diffusePart	: DiffuseShaderPart;
		private var _reflectionPart	: ReflectionShaderPart;
		
		private var _vertexPosition : SValue;
		private var _vertexNormal	: SValue;
		
		public function ReflectionShader()
		{
			_animationPart = new AnimationShaderPart(this);
			_diffusePart = new DiffuseShaderPart(this);
			_reflectionPart = new ReflectionShaderPart(this);
		}
		
		override protected function getOutputPosition() : SValue
		{
			var animationMethod		: uint	 = uint(getStyleConstant(AnimationStyle.METHOD, AnimationMethod.DISABLED));
			var maxInfluences		: uint	 = uint(getStyleConstant(AnimationStyle.MAX_INFLUENCES, 0));
			var numBones			: uint	 = uint(getStyleConstant(AnimationStyle.NUM_BONES, 0));
			
			_vertexPosition = _animationPart.getVertexPosition(animationMethod, maxInfluences, numBones);
			_vertexNormal	= vertexNormal;
			
			return multiply4x4(_vertexPosition, localToScreenMatrix);
		}
		
		override protected function getOutputColor() : SValue
		{
			var color				: SValue;
			
			var diffuseStyle		: Object = styleIsSet(BasicStyle.DIFFUSE) ? getStyleConstant(BasicStyle.DIFFUSE) : null;
			color = _diffusePart.getDiffuseColor(diffuseStyle);
			
			var diffuseValue : SValue = saturate(dotProduct3(
				normalize(subtract(cameraLocalPosition, interpolate(vertexPosition))),
				normalize(interpolate(vertexNormal))
			));
			var finalLightingVal : SValue = add(
				0.5,
				multiply(0.5, diffuseValue),
				power(diffuseValue, 256)
			);
			color = multiply(color, float4(finalLightingVal.xxx, 1));
			
			
			var reflectionId		: int	 		= int(getStyleConstant(ReflectionStyle.RECEIVE, ReflectionType.NONE));
			var reflectionDatas		: WorldDataList	= getWorldDataList(ReflectionData);
			var reflectionBlending	: int	 		= int(getStyleConstant(ReflectionStyle.BLENDING, Blending.ALPHA));
			var reflectionColor		: SValue 		= _reflectionPart.getReflectionColor(reflectionId, reflectionDatas, _vertexPosition, _vertexNormal);
			if (reflectionColor != null)
				color = blend(reflectionColor, color, reflectionBlending);
			
			return color;
		}
		
		override public function getDataHash(styleData		: StyleData, 
											 transformData	: TransformData, 
											 worldData		: Dictionary) : String
		{
			 var hash : String = '';
			 
			 hash += _animationPart.getDataHash(styleData, transformData, worldData);
			 hash += _diffusePart.getDataHash(styleData, transformData, worldData);
			 hash += int(getStyleConstant(ReflectionStyle.RECEIVE, ReflectionType.NONE));
			 
			 return hash;
		}
		
	}
}