package aerys.minko.render.shader.parts.lighting
{
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.part.ShaderPart;
	import aerys.minko.render.shader.parts.lighting.attenuation.CubeShadowMapAttenuationShaderPart;
	import aerys.minko.render.shader.parts.lighting.attenuation.DPShadowMapAttenuationShaderPart;
	import aerys.minko.render.shader.parts.lighting.attenuation.DistanceAttenuationShaderPart;
	import aerys.minko.render.shader.parts.lighting.attenuation.HardConicAttenuationShaderPart;
	import aerys.minko.render.shader.parts.lighting.attenuation.MatrixShadowMapAttenuationShaderPart;
	import aerys.minko.render.shader.parts.lighting.attenuation.SmoothConicAttenuationShaderPart;
	import aerys.minko.render.shader.parts.lighting.contribution.InfiniteShaderPart;
	import aerys.minko.render.shader.parts.lighting.contribution.LocalizedShaderPart;
	import aerys.minko.scene.node.light.AmbientLight;
	import aerys.minko.scene.node.light.DirectionalLight;
	import aerys.minko.scene.node.light.PointLight;
	import aerys.minko.scene.node.light.SpotLight;
	import aerys.minko.type.enum.ShadowMappingType;
	
	/**
	 * This shader part compute the lighting contribution of all lights
	 * 
	 * @author Romain Gilliotte
	 */	
	public class LightingShaderPart extends ShaderPart
	{
		private var _infinitePart					: InfiniteShaderPart;
		private var _localizedPart					: LocalizedShaderPart;
		private var _matrixShadowMapPart			: MatrixShadowMapAttenuationShaderPart;
		private var _distanceAttenuationPart		: DistanceAttenuationShaderPart;
		private var _dpShadowMapAttenuationPart		: DPShadowMapAttenuationShaderPart;
		private var _cubeShadowMapAttenuationPart	: CubeShadowMapAttenuationShaderPart;
		private var _smoothConicAttenuationPart		: SmoothConicAttenuationShaderPart;
		private var _hardConicAttenuationPart		: HardConicAttenuationShaderPart;
				
		public function LightingShaderPart(main : Shader)
		{
			super(main);
			
			_infinitePart					= new InfiniteShaderPart(main);
			_localizedPart					= new LocalizedShaderPart(main);
			_matrixShadowMapPart			= new MatrixShadowMapAttenuationShaderPart(main);
			_distanceAttenuationPart		= new DistanceAttenuationShaderPart(main);
			_dpShadowMapAttenuationPart		= new DPShadowMapAttenuationShaderPart(main);
			_cubeShadowMapAttenuationPart	= new CubeShadowMapAttenuationShaderPart(main);
			_smoothConicAttenuationPart		= new SmoothConicAttenuationShaderPart(main);
			_hardConicAttenuationPart		= new HardConicAttenuationShaderPart(main);
		}
		
		public function getLightingColor(position	: SFloat,
										 uv			: SFloat, 
										 normal		: SFloat) : SFloat
		{
			// compute positions and normals once, to make compiler work easier
			var worldPosition				: SFloat = localToWorld(position);
			var worldNormal					: SFloat = normalize(deltaLocalToWorld(normal));
			var interpolatedWorldPosition	: SFloat = interpolate(worldPosition);
//			var interpolatedWorldNormal		: SFloat = normalize(interpolate(deltaLocalToWorld(normal)));
			var mNormal						: SFloat = interpolate(float4(deltaLocalToWorld(normal), 1));
			var interpolatedWorldNormal		: SFloat = normalize(mNormal.xyz);
			
			// declare accumulator
			var lightValue					: SFloat = float3(0, 0, 0);
			var lightContribution			: SFloat;

			// process static light mapping
			if (meshBindings.propertyExists(LightingProperties.LIGHTMAP))
			{
				var lightMap : SFloat = meshBindings.getTextureParameter(LightingProperties.LIGHTMAP);
				
				lightContribution = sampleTexture(lightMap, interpolate(uv)).xyz;
				
				if (meshBindings.propertyExists(LightingProperties.LIGHTMAP_MULTIPLIER))
					lightContribution.scaleBy(meshBindings.getParameter(LightingProperties.LIGHTMAP_MULTIPLIER, 1));
				
				lightValue.incrementBy(lightContribution);
			}

			// process dynamic lighting
			
			var meshGroup	: uint = meshBindings.getConstant(LightingProperties.GROUP, 1);

			for (var lightId : uint = 0; sceneBindings.propertyExists('lightGroup' + lightId); ++lightId)
			{
				var lightGroup : uint = uint(sceneBindings.getConstant('lightGroup' + lightId));

				if ((lightGroup & meshGroup) == 0)
					continue;
				
				lightContribution = getLightContribution(
					lightId, 
					worldPosition, worldNormal, 
					interpolatedWorldPosition, interpolatedWorldNormal
				);
				
				lightValue.incrementBy(lightContribution);
			}
			
			return float4(lightValue, 1);
		}
		
		private function getLightContribution(lightId					: uint,
											  worldPosition				: SFloat,
											  worldNormal				: SFloat,
											  interpolatedWorldPosition	: SFloat,
											  interpolatedWorldNormal	: SFloat) : SFloat
		{
			var lightColor			: SFloat = sceneBindings.getParameter('lightColor' + lightId, 3);
			var lightContribution	: SFloat;
			var lightType			: uint = sceneBindings.getConstant('lightType' + lightId);
			
			switch (lightType)
			{
				case AmbientLight.TYPE:
					lightContribution = getAmbientLightContribution(lightId);
					break;
				
				case DirectionalLight.TYPE:
					lightContribution = getDirectionalLightContribution(
						lightId, 
						worldPosition, worldNormal, 
						interpolatedWorldPosition, interpolatedWorldNormal
					);
					break;
				
				case PointLight.TYPE:
					lightContribution = getPointLightContribution(
						lightId, 
						worldPosition, worldNormal, 
						interpolatedWorldPosition, interpolatedWorldNormal
					);
					break;
				
				case SpotLight.TYPE:
					lightContribution = getSpotLightContribution(
						lightId, 
						worldPosition, worldNormal, 
						interpolatedWorldPosition, interpolatedWorldNormal
					);
					break;
					
				default:
					throw new Error('Unsupported light type: ' + lightType);
			}
			
			return multiply(lightColor, lightContribution);
		}
		
		private function getAmbientLightContribution(lightId : uint) : SFloat
		{
			var lightAmbient : SFloat = sceneBindings.getParameter('lightAmbient' + lightId, 1);
			
			if (meshBindings.propertyExists(LightingProperties.AMBIENT_MULTIPLIER))
				lightAmbient.scaleBy(sceneBindings.getParameter(LightingProperties.AMBIENT_MULTIPLIER, 1));
			
			return lightAmbient;
		}
		
		private function getDirectionalLightContribution(lightId					: uint,
														 worldPosition				: SFloat,
														 worldNormal				: SFloat,
														 interpolatedWorldPosition	: SFloat,
														 interpolatedWorldNormal	: SFloat) : SFloat
		{
			var lightHasDiffuse		: Boolean	= sceneBindings.getConstant('lightDiffuseEnabled' + lightId);
			var lightHasSpecular	: Boolean	= sceneBindings.getConstant('lightSpecularEnabled' + lightId);
			var lightShadowCasting	: uint		= sceneBindings.getConstant('lightShadowCastingType' + lightId);
			var meshReceiveShadows	: Boolean	= meshBindings.propertyExists(LightingProperties.RECEIVE_SHADOWS);
			var computeShadows		: Boolean	= lightShadowCasting != ShadowMappingType.NONE && meshReceiveShadows;
			
			var contribution	: SFloat = float(0);
			
			if (lightHasDiffuse)
				contribution.incrementBy(_infinitePart.getDiffuseTerm(
					lightId, 
					worldPosition, worldNormal, 
					interpolatedWorldPosition, interpolatedWorldNormal
				));
			
			if (lightHasSpecular)
				contribution.incrementBy(_infinitePart.getSpecularTerm(
					lightId, 
					worldPosition, worldNormal, 
					interpolatedWorldPosition, interpolatedWorldNormal
				));
			
			if (computeShadows)
				contribution.scaleBy(
					_matrixShadowMapPart.getAttenuationFactor(
						lightId, 
						worldPosition, worldNormal, 
						interpolatedWorldPosition, interpolatedWorldNormal
					)
				);
			
			return contribution;
		}
		
		private function getPointLightContribution(lightId						: uint,
												   worldPosition				: SFloat,
												   worldNormal					: SFloat,
												   interpolatedWorldPosition	: SFloat,
												   interpolatedWorldNormal		: SFloat) : SFloat
		{
			var lightHasDiffuse		: Boolean	= sceneBindings.getConstant('lightDiffuseEnabled' + lightId);
			var lightHasSpecular	: Boolean	= sceneBindings.getConstant('lightSpecularEnabled' + lightId);
			var lightShadowCasting	: uint		= sceneBindings.getConstant('lightShadowCastingType' + lightId);
			var lightIsAttenuated	: Boolean	= sceneBindings.getConstant('lightAttenuationEnabled' + lightId);
			var meshReceiveShadows	: Boolean	= meshBindings.propertyExists(LightingProperties.RECEIVE_SHADOWS);
			var computeShadows		: Boolean	= lightShadowCasting != ShadowMappingType.NONE && meshReceiveShadows;
			
			var contribution		: SFloat	= float(0);
			
			if (lightHasDiffuse)
				contribution.incrementBy(_localizedPart.getDiffuseTerm(
					lightId, 
					worldPosition, worldNormal, 
					interpolatedWorldPosition, interpolatedWorldNormal
				));
			
			if (lightHasSpecular)
				contribution.incrementBy(_localizedPart.getSpecularTerm(
					lightId, 
					worldPosition, worldNormal, 
					interpolatedWorldPosition, interpolatedWorldNormal
				));
			
			if (lightIsAttenuated)
				contribution.scaleBy(_distanceAttenuationPart.getAttenuationFactor(
					lightId, 
					worldPosition, worldNormal, 
					interpolatedWorldPosition, interpolatedWorldNormal
				));
			
			if (computeShadows)
			{
				var useCubeMap : Boolean = sceneBindings.propertyExists('lightCubeDepthMap');
				
				if (useCubeMap)
					contribution.scaleBy(_cubeShadowMapAttenuationPart.getAttenuationFactor(
						lightId, 
						worldPosition, worldNormal, 
						interpolatedWorldPosition, interpolatedWorldNormal
					));
				else
					contribution.scaleBy(_dpShadowMapAttenuationPart.getAttenuationFactor(
						lightId, 
						worldPosition, worldNormal, 
						interpolatedWorldPosition, interpolatedWorldNormal
					));
			}
			
			return contribution;
		}
		
		private function getSpotLightContribution(lightId					: uint,
												  worldPosition				: SFloat,
												  worldNormal				: SFloat,
												  interpolatedWorldPosition	: SFloat,
												  interpolatedWorldNormal	: SFloat) : SFloat
		{
			
			var lightHasDiffuse		: Boolean	= sceneBindings.getConstant('lightDiffuseEnabled' + lightId);
			var lightHasSpecular	: Boolean	= sceneBindings.getConstant('lightSpecularEnabled' + lightId);
			var lightShadowCasting	: uint		= sceneBindings.getConstant('lightShadowCastingType' + lightId);
			var lightIsAttenuated	: Boolean	= sceneBindings.getConstant('lightAttenuationEnabled' + lightId);
			var meshReceiveShadows	: Boolean	= meshBindings.propertyExists(LightingProperties.RECEIVE_SHADOWS);
			var computeShadows		: Boolean	= lightShadowCasting != ShadowMappingType.NONE && meshReceiveShadows;
			
			var lightHasHardEdge	: Boolean	= 
				sceneBindings.getConstant('lightInnerRadius' + lightId) == sceneBindings.getConstant('lightOuterRadius' + lightId);
			
			var contribution		: SFloat	= float(0);
			
			if (lightHasDiffuse)
				contribution.incrementBy(_localizedPart.getDiffuseTerm(
					lightId,
					worldPosition, worldNormal,
					interpolatedWorldPosition, interpolatedWorldNormal
				));
			
			if (lightHasSpecular)
				contribution.incrementBy(_localizedPart.getSpecularTerm(
					lightId,
					worldPosition, worldNormal,
					interpolatedWorldPosition, interpolatedWorldNormal
				));
			
			if (lightIsAttenuated)
				contribution.scaleBy(_distanceAttenuationPart.getAttenuationFactor(
					lightId,
					worldPosition, worldNormal,
					interpolatedWorldPosition, interpolatedWorldNormal
				));
			
			if (lightHasHardEdge)
				contribution.scaleBy(_hardConicAttenuationPart.getAttenuationFactor(
					lightId,
					worldPosition, worldNormal,
					interpolatedWorldPosition, interpolatedWorldNormal
				));
			else
				contribution.scaleBy(_smoothConicAttenuationPart.getAttenuationFactor(
					lightId,
					worldPosition, worldNormal,
					interpolatedWorldPosition, interpolatedWorldNormal
				));
			
			if (computeShadows)
				contribution.scaleBy(
					_matrixShadowMapPart.getAttenuationFactor(
						lightId, 
						worldPosition, worldNormal, 
						interpolatedWorldPosition, interpolatedWorldNormal
					)
				);
			
			return contribution;
		}
	}
}
