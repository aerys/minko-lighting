package aerys.minko.render.shader.part.lighting
{
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.part.lighting.attenuation.CubeShadowMapAttenuationShaderPart;
	import aerys.minko.render.shader.part.lighting.attenuation.DPShadowMapAttenuationShaderPart;
	import aerys.minko.render.shader.part.lighting.attenuation.DistanceAttenuationShaderPart;
	import aerys.minko.render.shader.part.lighting.attenuation.HardConicAttenuationShaderPart;
	import aerys.minko.render.shader.part.lighting.attenuation.IAttenuationShaderPart;
	import aerys.minko.render.shader.part.lighting.attenuation.MatrixShadowMapAttenuationShaderPart;
	import aerys.minko.render.shader.part.lighting.attenuation.SmoothConicAttenuationShaderPart;
	import aerys.minko.render.shader.part.lighting.contribution.InfiniteShaderPart;
	import aerys.minko.render.shader.part.lighting.contribution.LocalizedShaderPart;
	import aerys.minko.type.enum.NormalMappingType;
	import aerys.minko.type.enum.ShadowMappingType;
	import aerys.minko.type.stream.format.VertexComponent;
	
	/**
	 * This shader part compute the lighting contribution of all lights
	 * 
	 * @author Romain Gilliotte
	 */	
	public class LightingShaderPart extends LightAwareShaderPart
	{
		private const LIGHT_TYPE_TO_FACTORY : Vector.<Function> = new <Function>[
			getAmbientLightContribution,
			getDirectionalLightContribution,
			getPointLightContribution,
			getSpotLightContribution
		];
		
		private var _shadowAttenuators				: Vector.<IAttenuationShaderPart>;
		private var _infinitePart					: InfiniteShaderPart;
		private var _localizedPart					: LocalizedShaderPart;
		private var _distanceAttenuationPart		: DistanceAttenuationShaderPart;
		private var _smoothConicAttenuationPart		: SmoothConicAttenuationShaderPart;
		private var _hardConicAttenuationPart		: HardConicAttenuationShaderPart;
		
		public function LightingShaderPart(main : Shader)
		{
			super(main);
			
			_infinitePart					= new InfiniteShaderPart(main);
			_localizedPart					= new LocalizedShaderPart(main);
			_distanceAttenuationPart		= new DistanceAttenuationShaderPart(main);
			_smoothConicAttenuationPart		= new SmoothConicAttenuationShaderPart(main);
			_hardConicAttenuationPart		= new HardConicAttenuationShaderPart(main);
			
			_shadowAttenuators = new <IAttenuationShaderPart>[
				null,
				new MatrixShadowMapAttenuationShaderPart(main),
				new DPShadowMapAttenuationShaderPart(main),
				new CubeShadowMapAttenuationShaderPart(main)
			];
		}
		
		public function getLightingColor() : SFloat
		{
			var lightValue : SFloat = float3(0, 0, 0);
			lightValue.incrementBy(getStaticLighting());
			lightValue.incrementBy(getDynamicLighting());
			
			return float4(lightValue, 1);
		}
		
		private function getStaticLighting() : SFloat
		{
			var contribution : SFloat;
			
			if (meshBindings.propertyExists(LightingProperties.LIGHTMAP))
			{
				var lightMap	: SFloat = meshBindings.getTextureParameter(LightingProperties.LIGHTMAP);
				var uv			: SFloat = getVertexAttribute(VertexComponent.UV);
				
				contribution = sampleTexture(lightMap, interpolate(uv));
				contribution = contribution.xyz;
				
				if (meshBindings.propertyExists(LightingProperties.LIGHTMAP_MULTIPLIER))
					contribution.scaleBy(meshBindings.getParameter(LightingProperties.LIGHTMAP_MULTIPLIER, 1));
			}
			else
				contribution = float3(0, 0, 0);
			
			return contribution;
		}
		
		private function getDynamicLighting() : SFloat
		{
			var receptionMask	: uint		= meshBindings.getConstant(LightingProperties.RECEPTION_MASK, 1);
			var dynamicLighting : SFloat	= float3(0, 0, 0);
			
			for (var lightId : uint = 0;; ++lightId)
			{
				if (!lightPropertyExists(lightId, 'emissionMask'))
					break;
				
				var emissionMask : uint = getLightConstant(lightId, 'emissionMask');
				
				if ((emissionMask & receptionMask) != 0)
				{
					var color			: SFloat	= getLightParameter(lightId, 'color', 4);
					var type			: uint		= getLightConstant(lightId, 'type')
					var contribution	: SFloat	= LIGHT_TYPE_TO_FACTORY[type](lightId);
					
					dynamicLighting.incrementBy(multiply(color.rgb, contribution));
				}
			}
			
			return dynamicLighting;
		}
		
		private function getAmbientLightContribution(lightId : uint) : SFloat
		{
			var ambient : SFloat = getLightParameter(lightId, 'ambient', 1);
			
			if (meshBindings.propertyExists(LightingProperties.AMBIENT_MULTIPLIER))
				ambient.scaleBy(sceneBindings.getParameter(LightingProperties.AMBIENT_MULTIPLIER, 1));
			
			return ambient;
		}
		
		private function getDirectionalLightContribution(lightId : uint) : SFloat
		{
			var hasDiffuse				: Boolean	= getLightConstant(lightId, 'diffuseEnabled');
			var hasSpecular				: Boolean	= getLightConstant(lightId, 'specularEnabled');
			var shadowCasting			: uint		= getLightConstant(lightId, 'shadowCastingType');
			var meshReceiveShadows		: Boolean	= meshBindings.getConstant(LightingProperties.RECEIVE_SHADOWS, false);
			var computeShadows			: Boolean	= shadowCasting != ShadowMappingType.NONE && meshReceiveShadows;
			var normalMappingType	: uint		= meshBindings.getConstant(LightingProperties.NORMAL_MAPPING_TYPE, NormalMappingType.NONE);
			
			var contribution			: SFloat	= float(0);
			
			if (hasDiffuse)
			{
				if (normalMappingType != NormalMappingType.NONE)
					contribution.incrementBy(_infinitePart.computeDiffuseInTangentSpace(lightId));
				else
					contribution.incrementBy(_infinitePart.computeDiffuseInWorldSpace(lightId));
			}
			
			if (hasSpecular)
			{
				if (normalMappingType != NormalMappingType.NONE)
					contribution.incrementBy(_infinitePart.computeSpecularInTangentSpace(lightId));
				else
					contribution.incrementBy(_infinitePart.computeSpecularInWorldSpace(lightId));
			}
			
			if (computeShadows)
				contribution.scaleBy(_shadowAttenuators[shadowCasting].getAttenuation(lightId));
			
			return contribution;
		}
		
		private function getPointLightContribution(lightId : uint) : SFloat
		{
			var hasDiffuse			: Boolean	= getLightConstant(lightId, 'diffuseEnabled');
			var hasSpecular			: Boolean	= getLightConstant(lightId, 'specularEnabled');
			var shadowCasting		: uint		= getLightConstant(lightId, 'shadowCastingType');
			var isAttenuated		: Boolean	= getLightConstant(lightId, 'attenuationEnabled');
			var normalMappingType	: uint		= meshBindings.getConstant(LightingProperties.NORMAL_MAPPING_TYPE, NormalMappingType.NONE);
			var meshReceiveShadows	: Boolean	= meshBindings.getConstant(LightingProperties.RECEIVE_SHADOWS, false);
			var computeShadows		: Boolean	= shadowCasting != ShadowMappingType.NONE && meshReceiveShadows;
			
			var contribution		: SFloat	= float(0);
			
			if (hasDiffuse)
			{
				if (normalMappingType != NormalMappingType.NONE)
					contribution.incrementBy(_localizedPart.computeDiffuseInTangentSpace(lightId));
				else
					contribution.incrementBy(_localizedPart.computeDiffuseInWorldSpace(lightId));
			}
			
			if (hasSpecular)
			{
				if (normalMappingType != NormalMappingType.NONE)
					contribution.incrementBy(_localizedPart.computeSpecularInTangentSpace(lightId));
				else
					contribution.incrementBy(_localizedPart.computeSpecularInWorldSpace(lightId));
			}
			
			if (isAttenuated)
				contribution.scaleBy(_distanceAttenuationPart.getAttenuation(lightId));
			
			if (computeShadows)
				contribution.scaleBy(_shadowAttenuators[shadowCasting].getAttenuation(lightId));
			
			return contribution;
		}
		
		private function getSpotLightContribution(lightId : uint) : SFloat
		{
			var hasDiffuse			: Boolean	= getLightConstant(lightId, 'diffuseEnabled');
			var hasSpecular			: Boolean	= getLightConstant(lightId, 'specularEnabled');
			var shadowCasting		: uint		= getLightConstant(lightId, 'shadowCastingType');
			var isAttenuated		: Boolean	= getLightConstant(lightId, 'attenuationEnabled');
			var lightHasSmoothEdge	: Boolean	= getLightConstant(lightId, 'smoothRadius');
			var meshReceiveShadows	: Boolean	= meshBindings.getConstant(LightingProperties.RECEIVE_SHADOWS, false);
			var computeShadows		: Boolean	= shadowCasting != ShadowMappingType.NONE && meshReceiveShadows;
			var normalMappingType	: uint		= meshBindings.getConstant(LightingProperties.NORMAL_MAPPING_TYPE, NormalMappingType.NONE);
			
			var contribution		: SFloat	= float(0);
			
			if (hasDiffuse)
			{
				if (normalMappingType != NormalMappingType.NONE)
					contribution.incrementBy(_localizedPart.computeDiffuseInTangentSpace(lightId));
				else
					contribution.incrementBy(_localizedPart.computeDiffuseInWorldSpace(lightId));
			}
			
			if (hasSpecular)
			{
				if (normalMappingType != NormalMappingType.NONE)
					contribution.incrementBy(_localizedPart.computeSpecularInTangentSpace(lightId));
				else
					contribution.incrementBy(_localizedPart.computeSpecularInWorldSpace(lightId));
			}
			
			if (isAttenuated)
				contribution.scaleBy(_distanceAttenuationPart.getAttenuation(lightId));
			
			if (lightHasSmoothEdge)
				contribution.scaleBy(_smoothConicAttenuationPart.getAttenuation(lightId));
			else
				contribution.scaleBy(_hardConicAttenuationPart.getAttenuation(lightId));
			
			if (computeShadows)
				contribution.scaleBy(_shadowAttenuators[shadowCasting].getAttenuation(lightId));
			
			return contribution;
		}
	}
}
