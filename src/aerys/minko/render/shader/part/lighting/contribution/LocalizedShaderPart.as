package aerys.minko.render.shader.part.lighting.contribution
{
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.part.ShaderPart;
	import aerys.minko.render.shader.part.lighting.LightAwareShaderPart;
	import aerys.minko.type.enum.SamplerFiltering;
	
	public class LocalizedShaderPart extends AbstractContributionShaderPart
	{
		public function LocalizedShaderPart(main : Shader)
		{
			super(main);
		}

		/**
		 * @inherit
		 */
		override public function computeDiffuseInTangentSpace(lightId : uint) : SFloat
		{
			// compute light direction
			var cLocalLightPosition		: SFloat = worldToLocal(getLightParameter(lightId, 'worldPosition', 4));
			var vsLocalLightDirection	: SFloat = subtract(vsLocalPosition, cLocalLightPosition);
			var fsTangentLightDirection	: SFloat = normalize(interpolate(deltaLocalToTangent(vsLocalLightDirection)));
			
			return diffuseFromVectors(lightId, fsTangentLightDirection, fsTangentNormal);
		}
		
		/**
		 * @inherit
		 */
		override public function computeDiffuseInLocalSpace(lightId : uint) : SFloat
		{
			throw new Error('Implement me');
		}
		
		/**
		 * @inherit
		 */
		override public function computeDiffuseInWorldSpace(lightId : uint) : SFloat
		{
			// compute light direction
			var cLightWorldPosition		: SFloat = getLightParameter(lightId, 'worldPosition', 4);
			var fsLocalLightDirection	: SFloat = normalize(subtract(fsWorldPosition, cLightWorldPosition));
			
			return diffuseFromVectors(lightId, fsLocalLightDirection, fsLocalNormal);
		}
		
		/**
		 * @inherit
		 */
		override public function computeSpecularInTangentSpace(lightId : uint) : SFloat
		{
			// compute camera direction
			var cLocalCameraPosition				: SFloat = worldToLocal(sceneBindings.getParameter('cameraPosition', 4));
			var vsLocalCameraDirection				: SFloat = normalize(subtract(cLocalCameraPosition, vsLocalPosition));
			var fsTangentCameraDirection			: SFloat = interpolate(deltaLocalToTangent(vsLocalCameraDirection));
			
			// compute reflected light direction
			var cLocalLightPosition					: SFloat = worldToLocal(getLightParameter(lightId, 'worldPosition', 4));
			var vsLocalLightDirection				: SFloat = normalize(subtract(vsLocalPosition, cLocalLightPosition.xyz));
			var fsTangentLightDirection				: SFloat = interpolate(deltaLocalToTangent(vsLocalLightDirection));
			
			return specularFromVectors(lightId, fsTangentLightDirection, fsTangentNormal, fsTangentCameraDirection);
		}
		
		/**
		 * @inherit
		 */
		override public function computeSpecularInLocalSpace(lightId : uint) : SFloat
		{
			throw new Error('Implement me');
		}
		
		/**
		 * @inherit
		 */
		override public function computeSpecularInWorldSpace(lightId : uint) : SFloat
		{
			// compute camera direction
			var cWorldCameraPosition			: SFloat = sceneBindings.getParameter('cameraPosition', 4);
			var fsWorldCameraDirection			: SFloat = normalize(subtract(cWorldCameraPosition, fsWorldPosition));
			
			// compute reflected light direction
			var cWorldLightPosition				: SFloat = getLightParameter(lightId, 'worldPosition', 4);
			var fsWorldLightDirection			: SFloat = normalize(subtract(fsWorldPosition, cWorldLightPosition));
			
			return specularFromVectors(lightId, fsWorldLightDirection, fsWorldNormal, fsWorldCameraDirection);
		}
	}
}
