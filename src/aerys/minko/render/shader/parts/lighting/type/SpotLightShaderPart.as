package aerys.minko.render.shader.parts.lighting.type
{
	import aerys.minko.render.shader.ActionScriptShaderPart;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.render.shader.parts.lighting.attenuation.HardConicAttenuationShaderPart;
	import aerys.minko.render.shader.parts.lighting.attenuation.MatrixShadowMapAttenuationShaderPart;
	import aerys.minko.render.shader.parts.lighting.attenuation.SmoothConicAttenuationShaderPart;
	import aerys.minko.render.shader.parts.lighting.attenuation.SquaredDistanceAttenuationShaderPart;
	import aerys.minko.render.shader.parts.lighting.contribution.LocalizedDiffuseShaderPart;
	import aerys.minko.render.shader.parts.lighting.contribution.LocalizedSpecularShaderPart;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	
	import flash.utils.Dictionary;
	
	public class SpotLightShaderPart extends ActionScriptShaderPart
	{
		private static const LOCALIZED_DIFFUSE				: LocalizedDiffuseShaderPart			= new LocalizedDiffuseShaderPart();
		private static const LOCALIZED_SPECULAR				: LocalizedSpecularShaderPart			= new LocalizedSpecularShaderPart();
		private static const SMOOTH_CONIC_ATTENUATION		: SmoothConicAttenuationShaderPart		= new SmoothConicAttenuationShaderPart();
		private static const HARD_CONIC_ATTENUATION			: HardConicAttenuationShaderPart		= new HardConicAttenuationShaderPart();
		private static const SQUARED_DISTANCE_ATTENUATION	: SquaredDistanceAttenuationShaderPart	= new SquaredDistanceAttenuationShaderPart();
		private static const MATRIX_SHADOW_MAP				: MatrixShadowMapAttenuationShaderPart	= new MatrixShadowMapAttenuationShaderPart();
		
		public function getLightContribution(lightId		: uint,
											 lightData		: LightData,
											 receiveShadows	: Boolean,
											 position		: SValue = null,
											 normal			: SValue = null) : SValue
		{
			position ||= interpolate(vertexPosition);
			normal	 ||= normalize(interpolate(vertexNormal));
			
			var contribution	: SValue = float(0);
			
			var diffuse		: SValue = LOCALIZED_DIFFUSE.getDynamicTerm(lightId, lightData, position, normal);
			if (diffuse != null)
				contribution.incrementBy(diffuse);
			
			var specular	: SValue = LOCALIZED_SPECULAR.getDynamicTerm(lightId, lightData, position, normal);
			if (specular != null)
				contribution.incrementBy(specular);
			
			if (diffuse == null && specular == null)
				return null;
			
			if (lightData.distance != 0)
				contribution.scaleBy(SQUARED_DISTANCE_ATTENUATION.getDynamicFactor(lightId, position));
			
			if (receiveShadows)
				contribution.scaleBy(MATRIX_SHADOW_MAP.getDynamicFactor(lightId, position));
			
			if (lightData.outerRadius == 0)
				return null;
			else if (lightData.outerRadius == lightData.innerRadius)
				contribution.scaleBy(HARD_CONIC_ATTENUATION.getDynamicFactor(lightId, position));
			else
				contribution.scaleBy(SMOOTH_CONIC_ATTENUATION.getDynamicFactor(lightId, position));
			
			return contribution;
		}
		
		public function getLightHash(lightData : LightData) : String
		{
			var radiusDecision : uint;
			if (lightData.outerRadius == 0)
				radiusDecision = 0;
			else if (lightData.outerRadius == lightData.innerRadius)
				radiusDecision = 1;
			else
				radiusDecision = 2;
			
			return LOCALIZED_DIFFUSE.getDynamicDataHash(lightData) 
				+ '|' + LOCALIZED_SPECULAR.getDynamicDataHash(lightData)
				+ '|' + uint(lightData.distance != 0)
				+ '|' + radiusDecision;				
		}
		
		override public function getDataHash(styleData		: StyleData,
											 transformData	: TransformData, 
											 worldData		: Dictionary) : String
		{
			throw new Error('Use getLightHash instead');
		}

	}
}