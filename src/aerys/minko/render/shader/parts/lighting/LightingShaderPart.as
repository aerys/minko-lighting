package aerys.minko.render.shader.parts.lighting
{
	import aerys.minko.render.effect.lighting.LightingStyle;
	import aerys.minko.render.shader.parts.lighting.attenuation.CubeShadowMapAttenuationShaderPart;
	import aerys.minko.render.shader.parts.lighting.type.AmbientLightShaderPart;
	import aerys.minko.render.shader.parts.lighting.type.DirectionalLightShaderPart;
	import aerys.minko.render.shader.parts.lighting.type.LightMapShaderPart;
	import aerys.minko.render.shader.parts.lighting.type.PointLightShaderPart;
	import aerys.minko.render.shader.parts.lighting.type.SpotLightShaderPart;
	import aerys.minko.render.shader.ActionScriptShaderPart;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	import aerys.minko.scene.data.WorldDataList;
	import aerys.minko.scene.node.light.AmbientLight;
	import aerys.minko.scene.node.light.DirectionalLight;
	import aerys.minko.scene.node.light.PointLight;
	import aerys.minko.scene.node.light.SpotLight;
	
	import flash.utils.Dictionary;
	
	public class LightingShaderPart extends ActionScriptShaderPart
	{
		private static const LIGHT_MAP			: LightMapShaderPart			= new LightMapShaderPart();
		private static const AMBIENT_LIGHT		: AmbientLightShaderPart		= new AmbientLightShaderPart();
		private static const DIRECTIONAL_LIGHT	: DirectionalLightShaderPart	= new DirectionalLightShaderPart();
		private static const POINT_LIGHT		: PointLightShaderPart			= new PointLightShaderPart();
		private static const SPOT_LIGHT			: SpotLightShaderPart			= new SpotLightShaderPart();
		
		public function getLightingColor(lightEnabled		: Boolean, 
										 lightGroup			: uint,
										 lightMapEnabled	: Boolean,
										 shadowsReceive		: Boolean,
										 lightDatas			: WorldDataList,
										 position			: SValue = null,
										 normal				: SValue = null) : SValue
		{
			var lighting : SValue = float3(0);
			
			if (!lightMapEnabled && !lightEnabled)
				return null;
			
			// process static light mapping
			if (lightMapEnabled)
			{
				lighting.incrementBy(LIGHT_MAP.getLightContribution());
			}
			
			// process dynamic lighting
			if (lightEnabled)
			{
				var numLights		: uint		= lightDatas.length;
				
				for (var lightId : uint = 0; lightId < numLights; ++lightId)
				{
					var lightData			: LightData	= LightData(lightDatas.getItem(lightId));
					var lightContribution	: SValue	= getLightContribution(lightId, lightData, lightGroup, shadowsReceive, position, normal);
					var lightColor			: SValue	= getWorldParameter(3, LightData, LightData.COLOR, lightId); 
					
					if (lightContribution == null)
						continue;
					
					lighting.incrementBy(multiply(lightColor, lightContribution));
				}
			}
			
			return float4(lighting, 1);
		}
		
		private function getLightContribution(lightId			: uint,
											  lightData			: LightData,
											  lightGroup		: uint,
											  receiveShadows	: Boolean,
											  position			: SValue,
											  normal			: SValue) : SValue
		{
			if ((lightData.group & lightGroup) == 0)
				return null;
			
			receiveShadows &&= lightData.castShadows;
			
			switch (lightData.type)
			{
				case AmbientLight.TYPE:
					return AMBIENT_LIGHT.getLightContribution(lightId);
				
				case DirectionalLight.TYPE:
					return DIRECTIONAL_LIGHT.getLightContribution(lightId, lightData, receiveShadows, position, normal);
				
				case PointLight.TYPE:
					return POINT_LIGHT.getLightContribution(lightId, lightData, receiveShadows, position, normal);
				
				case SpotLight.TYPE:
					return SPOT_LIGHT.getLightContribution(lightId, lightData, receiveShadows, position, normal);
			}
			
			throw new Error('Unsupported light type');
		}
		
		override public function getDataHash(styleData		: StyleData, 
											 transformData	: TransformData, 
											 worldData		: Dictionary) : String
		{
			var lightEnabled		: Boolean		= Boolean(styleData.get(LightingStyle.LIGHTS_ENABLED, false));
			var lightGroup			: uint			= uint(styleData.get(LightingStyle.GROUP, 1));
			var lightMapEnabled		: Boolean		= styleData.isSet(LightingStyle.LIGHTMAP);
			var shadowsEnabled		: Boolean		= Boolean(styleData.get(LightingStyle.SHADOWS_ENABLED, false));
			var shadowsReceive		: Boolean		= Boolean(styleData.get(LightingStyle.RECEIVE_SHADOWS, false));
			var lightDatas			: WorldDataList	= worldData[LightData];
			
			var hash				: String		= 'lightingsp';
			
			hash += uint(lightMapEnabled).toString();
			hash += uint(lightEnabled).toString();
			
			if (lightEnabled)
			{
				var numLights		: uint		= lightDatas.length;
				var receiveShadows	: Boolean	= shadowsEnabled && shadowsReceive;
				
				hash += numLights.toString();
				hash += uint(receiveShadows).toString();
				
				for (var lightId : uint = 0; lightId < numLights; ++lightId)
				{
					var lightData : LightData = LightData(lightDatas.getItem(lightId));
					
					hash += getLightHash(lightId, lightData, lightGroup);
				}
			}
			
			return hash;
		}
		
		private function getLightHash(lightId		: uint,
									  lightData		: LightData,
									  lightGroup	: uint) : String
		{
			if ((lightData.group & lightGroup) == 0)
				return '0';
			
			switch (lightData.type)
			{
				case AmbientLight.TYPE:
					return '2';
					
				case DirectionalLight.TYPE:
					return '3' + uint(lightData.castShadows).toString() + DIRECTIONAL_LIGHT.getLightHash(lightData);
					
				case PointLight.TYPE:
					return '4' + uint(lightData.castShadows).toString() + POINT_LIGHT.getLightHash(lightData);
					
				case SpotLight.TYPE:
					return '5' + uint(lightData.castShadows).toString() + POINT_LIGHT.getLightHash(lightData);
			}
			
			throw new Error('Unsupported light type');
		}
	}
}