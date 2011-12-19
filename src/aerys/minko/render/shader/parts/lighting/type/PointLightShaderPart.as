package aerys.minko.render.shader.parts.lighting.type
{
	import aerys.minko.render.shader.ActionScriptShader;
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
	import aerys.minko.type.stream.format.VertexComponent;
	
	import flash.utils.Dictionary;
	
	public class PointLightShaderPart extends ActionScriptShaderPart
	{
		private var _localizedDiffusePart				: LocalizedDiffuseShaderPart			= null;
		private var _localizedSpecularPart				: LocalizedSpecularShaderPart			= null;
		private var _squaredAttenuationDistancePart		: SquaredDistanceAttenuationShaderPart	= null;
		private var _dpShadowMapAttenuationPart			: DPShadowMapAttenuationShaderPart		= null;
		private var _cubeShadowMapAttenuationPart		: CubeShadowMapAttenuationShaderPart	= null;
		
		public function PointLightShaderPart(main : ActionScriptShader)
		{
			super(main);
			
			_localizedDiffusePart = new LocalizedDiffuseShaderPart(main);
			_localizedSpecularPart = new LocalizedSpecularShaderPart(main);
			_squaredAttenuationDistancePart = new SquaredDistanceAttenuationShaderPart(main);
			_dpShadowMapAttenuationPart = new DPShadowMapAttenuationShaderPart(main);
			_cubeShadowMapAttenuationPart = new CubeShadowMapAttenuationShaderPart(main);
		}
		
		public function getLightContribution(lightId 		: uint,
											 lightData		: LightData,
											 receiveShadows	: Boolean,
											 position		: SValue = null,
											 normal			: SValue = null) : SValue
		{
			position ||= getVertexAttribute(VertexComponent.XYZ);
			normal	 ||= getVertexAttribute(VertexComponent.NORMAL);
			
			var contribution	: SValue = float(0);
			
			var diffuse : SValue = _localizedDiffusePart.getDynamicTerm(lightId, lightData, position, normal);
			if (diffuse != null)
				contribution.incrementBy(diffuse);
			
			var specular : SValue = _localizedSpecularPart.getDynamicTerm(lightId, lightData, position, normal);
			if (specular != null)
				contribution.incrementBy(specular);
			
			if (diffuse == null && specular == null)
				return null;
			
			if (lightData.distance != 0)
				contribution.scaleBy(_squaredAttenuationDistancePart.getDynamicFactor(lightId, position));
			
			if (receiveShadows)
			{
				if (lightData.useParaboloidShadows)
					contribution.scaleBy(_dpShadowMapAttenuationPart.getDynamicFactor(lightId, position));
				else
					contribution.scaleBy(_cubeShadowMapAttenuationPart.getDynamicFactor(lightId, position));
			}
			
			return contribution;
		}
		
		public function getLightHash(lightData : LightData) : String
		{
			// we should add receive shadows here, but it's handled on LightingShaderPart
			return _localizedDiffusePart.getDynamicDataHash(lightData) 
				+ '|' + _localizedSpecularPart.getDynamicDataHash(lightData)
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
