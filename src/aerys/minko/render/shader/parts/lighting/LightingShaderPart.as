package aerys.minko.render.shader.parts.lighting
{
	import aerys.minko.render.effect.lighting.LightingStyle;
	import aerys.minko.render.shader.ActionScriptShader;
	import aerys.minko.render.shader.ActionScriptShaderPart;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.render.shader.parts.lighting.type.AmbientLightShaderPart;
	import aerys.minko.render.shader.parts.lighting.type.DirectionalLightShaderPart;
	import aerys.minko.render.shader.parts.lighting.type.LightMapShaderPart;
	import aerys.minko.render.shader.parts.lighting.type.PointLightShaderPart;
	import aerys.minko.render.shader.parts.lighting.type.SpotLightShaderPart;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	import aerys.minko.scene.data.WorldDataList;
	import aerys.minko.scene.node.light.AmbientLight;
	import aerys.minko.scene.node.light.ConstDirectionalLight;
	import aerys.minko.scene.node.light.ConstPointLight;
	import aerys.minko.scene.node.light.ConstSpotLight;
	import aerys.minko.scene.node.light.DirectionalLight;
	import aerys.minko.scene.node.light.PointLight;
	import aerys.minko.scene.node.light.SpotLight;
	
	import flash.utils.Dictionary;
	
	/**
	 * This shader part compute the lighting contribution of all lights
	 * 
	 * @author Romain Gilliotte <romain.gilliotte@aerys.in>
	 */	
	public class LightingShaderPart extends ActionScriptShaderPart
	{
		private var _lightMapPart			: LightMapShaderPart			= null;
		private var _ambientLightPart		: AmbientLightShaderPart		= null;
		private var _directionalLightPart	: DirectionalLightShaderPart	= null
		private var _pointLightPart			: PointLightShaderPart			= null;
		private var _spotLightPart			: SpotLightShaderPart			= null;
		
		public function LightingShaderPart(main : ActionScriptShader)
		{
			super(main);
			
			_lightMapPart = new LightMapShaderPart(main);
			_ambientLightPart = new AmbientLightShaderPart(main);
			_directionalLightPart = new DirectionalLightShaderPart(main);
			_pointLightPart = new PointLightShaderPart(main);
			_spotLightPart = new SpotLightShaderPart(main);
		}
		
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
				lighting.incrementBy(_lightMapPart.getLightContribution());
			}
			
			// process dynamic lighting
			if (lightEnabled)
			{
				var numLights		: uint		= lightDatas ? lightDatas.length : 0;
				
				for (var lightId : uint = 0; lightId < numLights; ++lightId)
				{
					var lightData			: LightData	= LightData(lightDatas.getItem(lightId));
					var lightContribution	: SValue	= getLightContribution(lightId, lightData, lightGroup, shadowsReceive, position, normal);
					var lightColor			: SValue	= getWorldParameter(3, LightData, LightData.COLOR, lightId); 
					
					if (lightContribution == null)
						continue;
					
					lighting.incrementBy(lightContribution);
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
					return _ambientLightPart.getDynamicLightContribution(lightId);
				
				case DirectionalLight.TYPE:
					return _directionalLightPart.getDynamicLightContribution(lightId, lightData, receiveShadows, position, normal);
				
				case PointLight.TYPE:
					return _pointLightPart.getDynamicLightContribution(lightId, lightData, receiveShadows, position, normal);
				
				case SpotLight.TYPE:
					return _spotLightPart.getDynamicLightContribution(lightId, lightData, receiveShadows, position, normal);
				
				case ConstDirectionalLight.TYPE:
					return _directionalLightPart.getStaticLightContribution(lightId, lightData, receiveShadows, position, normal);
				
				case ConstPointLight.TYPE:
					return _pointLightPart.getStaticLightContribution(lightId, lightData, receiveShadows, position, normal);
				
				case ConstSpotLight.TYPE:
					return _spotLightPart.getStaticLightContribution(lightId, lightData, receiveShadows, position, normal);
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
				var numLights		: uint		= lightDatas ? lightDatas.length : 0;
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
		
		/**
		 * There is a known bug here: if the user replaces a const light, by another one of the same type, the changes will not be reflected on the scene
		 * It is unlikely to happen, and allow us to save some performance
		 */		
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
					return '3' + uint(lightData.castShadows).toString() + _directionalLightPart.getDynamicLightHash(lightData);
					
				case PointLight.TYPE:
					return '4' + uint(lightData.castShadows).toString() + _pointLightPart.getDynamicLightHash(lightData);
					
				case SpotLight.TYPE:
					return '5' + uint(lightData.castShadows).toString() + _spotLightPart.getDynamicLightHash(lightData);
				
				case ConstDirectionalLight.TYPE:
					return '7' + uint(lightData.castShadows).toString();
					
				case ConstPointLight.TYPE:
					return '8' + uint(lightData.castShadows).toString();
					
				case ConstSpotLight.TYPE:
					return '9' + uint(lightData.castShadows).toString();
			}
			
			throw new Error('Unsupported light type');
		}
	}
}