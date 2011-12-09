package aerys.minko.render.shader.parts.lighting.type
{
	import aerys.minko.render.shader.ActionScriptShaderPart;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.render.shader.parts.lighting.attenuation.CubeShadowMapAttenuationShaderPart;
	import aerys.minko.render.shader.parts.lighting.attenuation.DPShadowMapAttenuationShaderPart;
	import aerys.minko.render.shader.parts.lighting.attenuation.SquaredDistanceAttenuationShaderPart;
	import aerys.minko.render.shader.parts.lighting.contribution.LocalizedDiffuseShaderPart;
	import aerys.minko.render.shader.parts.lighting.contribution.LocalizedSpecularShaderPart;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	
	import flash.utils.Dictionary;
	
	public class PointLightShaderPart extends ActionScriptShaderPart
	{
		private static const LOCALIZED_DIFFUSE				: LocalizedDiffuseShaderPart			= new LocalizedDiffuseShaderPart();
		private static const LOCALIZED_SPECULAR				: LocalizedSpecularShaderPart			= new LocalizedSpecularShaderPart();
		private static const SQUARED_DISTANCE_ATTENUATION	: SquaredDistanceAttenuationShaderPart	= new SquaredDistanceAttenuationShaderPart();
		private static const DP_SHADOW_MAP_ATTENUATION		: DPShadowMapAttenuationShaderPart		= new DPShadowMapAttenuationShaderPart();
		private static const CUBE_SHADOW_MAP_ATTENUATION	: CubeShadowMapAttenuationShaderPart	= new CubeShadowMapAttenuationShaderPart();
		
		public function getLightContribution(lightId 		: uint,
											 lightData		: LightData,
											 receiveShadows	: Boolean,
											 position		: SValue = null,
											 normal			: SValue = null) : SValue
		{
			position ||= interpolate(vertexPosition);
			normal	 ||= normalize(interpolate(vertexNormal));
			
			var contribution	: SValue = float(0);
			
			var diffuse : SValue = LOCALIZED_DIFFUSE.getDynamicTerm(lightId, lightData, position, normal);
			if (diffuse != null)
				contribution.incrementBy(diffuse);
			
			var specular : SValue = LOCALIZED_SPECULAR.getDynamicTerm(lightId, lightData, position, normal);
			if (specular != null)
				contribution.incrementBy(specular);
			
			if (diffuse == null && specular == null)
				return null;
			
			if (lightData.distance != 0)
				contribution.scaleBy(SQUARED_DISTANCE_ATTENUATION.getDynamicFactor(lightId, position));
			
			if (receiveShadows)
			{
				if (lightData.useParaboloidShadows)
					contribution.scaleBy(DP_SHADOW_MAP_ATTENUATION.getDynamicFactor(lightId, position));
				else
					contribution.scaleBy(CUBE_SHADOW_MAP_ATTENUATION.getDynamicFactor(lightId, position));
			}
			
			return contribution;
		}
		
		public function getLightHash(lightData : LightData) : String
		{
			// we should add receive shadows here, but it's handled on LightingShaderPart
			return LOCALIZED_DIFFUSE.getDynamicDataHash(lightData) 
				+ '|' + LOCALIZED_SPECULAR.getDynamicDataHash(lightData)
				+ '|' + uint(lightData.distance != 0).toString()
				+ '|' + uint(lightData.useParaboloidShadows).toString();
		}
		
		override public function getDataHash(styleData		: StyleData, 
											 transformData	: TransformData, 
											 worldData		: Dictionary) : String
		{
			throw new Error('Use getLightHash instead');
		}
	}
}
