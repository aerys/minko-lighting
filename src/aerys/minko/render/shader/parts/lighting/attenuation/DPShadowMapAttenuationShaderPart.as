package aerys.minko.render.shader.parts.lighting.attenuation
{
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.PassTemplate;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.part.ShaderPart;
	import aerys.minko.render.shader.part.projection.ParaboloidProjectionShaderPart;
	import aerys.minko.type.enum.SamplerFilter;
	import aerys.minko.type.enum.SamplerMipmap;
	import aerys.minko.type.enum.SamplerWrapping;
	import aerys.minko.type.stream.format.VertexComponent;
	
	import flash.geom.Rectangle;
	
	public class DPShadowMapAttenuationShaderPart extends ShaderPart implements IAttenuationShaderPart
	{
		private static const TEXTURE_RECTANGLE	: Rectangle	= new Rectangle(0, 0, 1, 1);
		
		private var _paraboloidFrontPart	: ParaboloidProjectionShaderPart;
		private var _paraboloidBackPart		: ParaboloidProjectionShaderPart;
		
		public function DPShadowMapAttenuationShaderPart(main : PassTemplate)
		{
			super(main);
			
			_paraboloidFrontPart	= new ParaboloidProjectionShaderPart(main, true);
			_paraboloidBackPart		= new ParaboloidProjectionShaderPart(main, false);
		}
		
		public function getAttenuationFactor(lightId					: uint, 
											 worldPosition				: SFloat,
											 worldNormal				: SFloat,
											 worldInterpolatedPosition	: SFloat,
											 worldInterpolatedNormal	: SFloat) : SFloat
		{
			var shadowBias				: SFloat;
			if (meshBindings.propertyExists('lightShadowBias'))
				shadowBias = meshBindings.getParameter('lightShadowBias', 1);
			else
				shadowBias = sceneBindings.getParameter('lightShadowBias' + lightId, 1);
			
			// transform position to light space
			var worldToLight			: SFloat = sceneBindings.getParameter('lightWorldToLight' + lightId, 16);
			var positionFromLight		: SFloat = interpolate(multiply4x4(worldPosition, worldToLight));
			var isFront					: SFloat = greaterEqual(positionFromLight.z, 0);
			
			// retrieve sampler ids.
			var frontDepthMap	: SFloat = sceneBindings.getTextureParameter(
				'lightFrontParaboloidDepthMap' + lightId,
				SamplerFilter.LINEAR, SamplerMipmap.DISABLE, SamplerWrapping.CLAMP
			);
			
			var backDepthMap	: SFloat = sceneBindings.getTextureParameter(
				'lightBackParaboloidDepthMap' + lightId,
				SamplerFilter.LINEAR, SamplerMipmap.DISABLE, SamplerWrapping.CLAMP
			);
			
			// retrieve front depth
			var uvFront					: SFloat = _paraboloidFrontPart.projectVector(positionFromLight, TEXTURE_RECTANGLE, 0, 50);
			var frontPrecomputedDepth	: SFloat;
			frontPrecomputedDepth = sampleTexture(frontDepthMap, uvFront);
			frontPrecomputedDepth = frontPrecomputedDepth.x;
//			frontPrecomputedDepth = unpack(frontPrecomputedDepth);
			
			// retrieve back depth
			var uvBack					: SFloat = _paraboloidBackPart.projectVector(positionFromLight, TEXTURE_RECTANGLE, 0, 50);
			var backPrecomputedDepth	: SFloat;
			backPrecomputedDepth = sampleTexture(backDepthMap, uvBack);
			backPrecomputedDepth = backPrecomputedDepth.x;
//			backPrecomputedDepth = unpack(backPrecomputedDepth);
			
			var currentDepth			: SFloat = mix(uvBack.z, uvFront.z, isFront);
			var precomputedDepth		: SFloat = mix(backPrecomputedDepth, frontPrecomputedDepth, isFront);
			
			return lessThan(currentDepth, add(shadowBias, precomputedDepth));
		}
	}
}