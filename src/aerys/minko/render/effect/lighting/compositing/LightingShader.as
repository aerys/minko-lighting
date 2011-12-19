package aerys.minko.render.effect.lighting.compositing
{
	import aerys.minko.render.effect.animation.AnimationStyle;
	import aerys.minko.render.effect.basic.BasicStyle;
	import aerys.minko.render.effect.lighting.LightingStyle;
	import aerys.minko.render.shader.ActionScriptShader;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.render.shader.parts.animation.AnimationShaderPart;
	import aerys.minko.render.shader.parts.diffuse.DiffuseShaderPart;
	import aerys.minko.render.shader.parts.lighting.LightingShaderPart;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	import aerys.minko.scene.data.WorldDataList;
	import aerys.minko.type.animation.AnimationMethod;
	import aerys.minko.type.enum.Blending;
	
	import flash.utils.Dictionary;
	
	public class LightingShader extends ActionScriptShader
	{
		private var _animationPart	: AnimationShaderPart	= null;
		private var _diffusePart	: DiffuseShaderPart		= null;
		private var _lightingPart	: LightingShaderPart	= null;
		
		private var _vertexPosition : SValue;
		private var _vertexUv		: SValue;
		private var _vertexNormal	: SValue;
		
		public function LightingShader()
		{
			super();
			
			_animationPart = new AnimationShaderPart(this);
			_diffusePart = new DiffuseShaderPart(this);
			_lightingPart = new LightingShaderPart(this);
		}
		
		override protected function getOutputPosition() : SValue
		{
			var normalMultiplier	: SValue = getStyleParameter(1, BasicStyle.NORMAL_MULTIPLIER);
			
			var animationMethod		: uint	 = uint(getStyleConstant(AnimationStyle.METHOD, AnimationMethod.DISABLED));
			var maxInfluences		: uint	 = uint(getStyleConstant(AnimationStyle.MAX_INFLUENCES, 0));
			var numBones			: uint	 = uint(getStyleConstant(AnimationStyle.NUM_BONES, 0));
			
			var vertexPosition		: SValue = _animationPart.getVertexPosition(animationMethod, maxInfluences, numBones);
			var vertexNormal		: SValue;
			vertexNormal = _animationPart.getVertexNormal(animationMethod, maxInfluences, numBones);
			vertexNormal = multiply(vertexNormal, normalMultiplier);
			
			_vertexPosition	= interpolate(vertexPosition);
			_vertexUv		= interpolate(vertexUV);
			_vertexNormal	= normalize(interpolate(vertexNormal));
			
			return multiply4x4(vertexPosition, localToScreenMatrix);
		}
		
		override protected function getOutputColor() : SValue
		{
			// compute diffuse color
			var diffuseStyle		: Object		= styleIsSet(BasicStyle.DIFFUSE) ? getStyleConstant(BasicStyle.DIFFUSE) : null;
			var color				: SValue		= _diffusePart.getDiffuseColor(diffuseStyle);
			
			// compute lighting color
			var lightEnabled		: Boolean		= Boolean(getStyleConstant(LightingStyle.LIGHTS_ENABLED, false));
			var lightGroup			: uint			= uint(getStyleConstant(LightingStyle.GROUP, 1));
			var lightMapEnabled		: Boolean		= styleIsSet(LightingStyle.LIGHTMAP);
			var shadowsEnabled		: Boolean		= Boolean(getStyleConstant(LightingStyle.SHADOWS_ENABLED, false));
			var shadowsReceive		: Boolean		= Boolean(getStyleConstant(LightingStyle.RECEIVE_SHADOWS, false));
			var lightDatas			: WorldDataList	= getWorldDataList(LightData);
			
			var lighting : SValue = 
				_lightingPart.getLightingColor(
					lightEnabled, lightGroup, lightMapEnabled, 
					shadowsEnabled && shadowsReceive, 
					lightDatas, 
					_vertexPosition, _vertexNormal);
			
			if (lighting != null)
				color = blend(lighting, color, Blending.LIGHT);
			
			return color;
		}
		
		override public function getDataHash(styleData		: StyleData, 
											 transformData	: TransformData, 
											 worldData		: Dictionary) : String
		{
			var hash : String = 'lighting';
			
			hash += _animationPart.getDataHash(styleData, transformData, worldData);
			hash += _diffusePart.getDataHash(styleData, transformData, worldData);
			hash += _lightingPart.getDataHash(styleData, transformData, worldData);
			
			return hash;
		}
		
	}
}