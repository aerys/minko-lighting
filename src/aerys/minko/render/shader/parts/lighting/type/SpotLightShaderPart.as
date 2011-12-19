package aerys.minko.render.shader.parts.lighting.type
{
	import aerys.minko.render.shader.ActionScriptShader;
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
		private var _localizedDiffusePart			: LocalizedDiffuseShaderPart			= null;
		private var _localizedSpecularPart			: LocalizedSpecularShaderPart			= null;
		private var _smoothConicAttenuationPart		: SmoothConicAttenuationShaderPart		= null;
		private var _hardConicAttenuationPart		: HardConicAttenuationShaderPart		= null;
		private var _squaredDistanceAttenuationPart	: SquaredDistanceAttenuationShaderPart	= null;
		private var _matrixShadowMapPart			: MatrixShadowMapAttenuationShaderPart	= null;
		
		public function SpotLightShaderPart(main : ActionScriptShader)
		{
			super(main);
			
			_localizedDiffusePart = new LocalizedDiffuseShaderPart(main);
			_localizedSpecularPart = new LocalizedSpecularShaderPart(main);
			_smoothConicAttenuationPart = new SmoothConicAttenuationShaderPart(main);
			_hardConicAttenuationPart = new HardConicAttenuationShaderPart(main);
			_squaredDistanceAttenuationPart = new SquaredDistanceAttenuationShaderPart(main);
			_matrixShadowMapPart = new MatrixShadowMapAttenuationShaderPart(main);
		}
		
		public function getLightContribution(lightId		: uint,
											 lightData		: LightData,
											 receiveShadows	: Boolean,
											 position		: SValue = null,
											 normal			: SValue = null) : SValue
		{
			position ||= interpolate(vertexPosition);
			normal	 ||= normalize(interpolate(vertexNormal));
			
			var contribution	: SValue = float(0);
			
			var diffuse		: SValue = _localizedDiffusePart.getDynamicTerm(lightId, lightData, position, normal);
			if (diffuse != null)
				contribution.incrementBy(diffuse);
			
			var specular	: SValue = _localizedSpecularPart.getDynamicTerm(lightId, lightData, position, normal);
			if (specular != null)
				contribution.incrementBy(specular);
			
			if (diffuse == null && specular == null)
				return null;
			
			if (lightData.distance != 0)
				contribution.scaleBy(_squaredDistanceAttenuationPart.getDynamicFactor(lightId, position));
			
			if (receiveShadows)
				contribution.scaleBy(_matrixShadowMapPart.getDynamicFactor(lightId, position));
			
			if (lightData.outerRadius == 0)
				return null;
			else if (lightData.outerRadius == lightData.innerRadius)
				contribution.scaleBy(_hardConicAttenuationPart.getDynamicFactor(lightId, position));
			else
				contribution.scaleBy(_smoothConicAttenuationPart.getDynamicFactor(lightId, position));
			
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
			
			return _localizedDiffusePart.getDynamicDataHash(lightData) 
				+ '|' + _localizedSpecularPart.getDynamicDataHash(lightData)
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