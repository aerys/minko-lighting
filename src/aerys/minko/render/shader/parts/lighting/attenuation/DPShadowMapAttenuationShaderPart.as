package aerys.minko.render.shader.parts.lighting.attenuation
{
	import aerys.minko.render.effect.Style;
	import aerys.minko.render.effect.lighting.LightingStyle;
	import aerys.minko.render.shader.ActionScriptShader;
	import aerys.minko.render.shader.ActionScriptShaderPart;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.render.shader.node.leaf.Sampler;
	import aerys.minko.render.shader.parts.math.projection.ParaboloidProjectionShaderPart;
	import aerys.minko.scene.data.LightData;
	
	import flash.geom.Rectangle;
	
	public class DPShadowMapAttenuationShaderPart extends ActionScriptShaderPart implements IAttenuationShaderPart
	{
		private static const TEXTURE_RECTANGLE	: Rectangle	= new Rectangle(0, 0, 1, 1);
		
		private var _paraboloidFrontPart	: ParaboloidProjectionShaderPart	= null;
		private var _paraboloidBackPart		: ParaboloidProjectionShaderPart	= null;
		
		public function DPShadowMapAttenuationShaderPart(main : ActionScriptShader)
		{
			super(main);
			
			_paraboloidFrontPart = new ParaboloidProjectionShaderPart(main, true);
			_paraboloidBackPart = new ParaboloidProjectionShaderPart(main, false);
		}
		
		public function getDynamicFactor(lightId	: uint,
										 position	: SValue = null) : SValue
		{
			position ||= interpolate(vertexPosition);
			
			var shadowBias		: SValue = getStyleParameter(1, LightingStyle.SHADOWS_BIAS, 1 / 100);
			
			// transform position to light space
			var localToLight			: SValue = getWorldParameter(16, LightData, LightData.LOCAL_TO_LIGHT, lightId);
			var lightVertexPosition		: SValue = multiply4x4(position, localToLight);
			var isFront					: SValue = greaterEqual(lightVertexPosition.z, 0);
			
			// retrieve sampler ids.
			var frontDepthMapSamplerId	: uint	 = Style.getStyleId('lighting frontParaboloidDepthMap' + lightId);
			var backDepthMapSamplerId	: uint	 = Style.getStyleId('lighting backParaboloidDepthMap' + lightId);
			
			// retrieve front depth
			var uvFront					: SValue = _paraboloidFrontPart.projectVector(lightVertexPosition, TEXTURE_RECTANGLE, 0, 50);
			var frontPrecomputedDepth	: SValue;
			frontPrecomputedDepth = sampleTexture(frontDepthMapSamplerId, uvFront, Sampler.FILTER_LINEAR, Sampler.MIPMAP_DISABLE, Sampler.WRAPPING_CLAMP);
			frontPrecomputedDepth = frontPrecomputedDepth.x;
//			frontPrecomputedDepth = unpack(frontPrecomputedDepth);
			
			// retrieve back depth
			var uvBack					: SValue = _paraboloidBackPart.projectVector(lightVertexPosition, TEXTURE_RECTANGLE, 0, 50);
			var backPrecomputedDepth	: SValue;
			backPrecomputedDepth = sampleTexture(backDepthMapSamplerId, uvBack, Sampler.FILTER_LINEAR, Sampler.MIPMAP_DISABLE, Sampler.WRAPPING_CLAMP);
			backPrecomputedDepth = backPrecomputedDepth.x;
//			backPrecomputedDepth = unpack(backPrecomputedDepth);
			
			var currentDepth			: SValue = mix(uvBack.z, uvFront.z, isFront);
			var precomputedDepth		: SValue = mix(backPrecomputedDepth, frontPrecomputedDepth, isFront);
			
			return lessThan(currentDepth, add(shadowBias, precomputedDepth));
		}
		
		public function getStaticFactor(lightData	: LightData,
										position	: SValue = null) : SValue
		{
			throw new Error('Not yet implemented');
		}
	}
}