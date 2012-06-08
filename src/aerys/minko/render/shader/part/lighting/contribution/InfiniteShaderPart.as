package aerys.minko.render.shader.part.lighting.contribution
{
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.part.lighting.LightAwareShaderPart;

	public class InfiniteShaderPart extends AbstractContributionShaderPart
	{
		public function InfiniteShaderPart(main : Shader)
		{
			super(main);
		}
		
		/**
		 * @inherit
		 */
		override public function computeDiffuseInTangentSpace(lightId : uint) : SFloat
		{
			var cLightLocalDirection	: SFloat = deltaWorldToLocal(getLightParameter(lightId, 'worldDirection', 3));
			var fsTangentLightDirection	: SFloat = normalize(interpolate(deltaLocalToTangent(cLightLocalDirection)));
			
			return diffuseFromVectors(lightId, fsTangentLightDirection, fsTangentNormal);
		}
		
		/**
		 * @inherit
		 */
		override public function computeDiffuseInLocalSpace(lightId : uint) : SFloat
		{
			var cLocalLightDirection : SFloat = deltaWorldToLocal(getLightParameter(lightId, 'worldDirection', 3));
			
			return diffuseFromVectors(lightId, cLocalLightDirection, fsLocalNormal);
		}
		
		/**
		 * @inherit
		 */
		override public function computeDiffuseInWorldSpace(lightId : uint) : SFloat
		{
			var cWorldLightDirection : SFloat = getLightParameter(lightId, 'worldDirection', 3);
			
			return diffuseFromVectors(lightId, cWorldLightDirection, fsWorldNormal);
		}
		
		/**
		 * @inherit
		 */
		override public function computeSpecularInTangentSpace(lightId:uint):SFloat
		{
			var cLocalLightDirection		: SFloat = deltaWorldToLocal(getLightParameter(lightId, 'worldDirection', 3));
			var vsTangentLightDirection		: SFloat = deltaLocalToTangent(cLocalLightDirection);
			var fsTangentLightDirection		: SFloat = normalize(interpolate(vsTangentLightDirection));
			
			var cLocalCameraPosition		: SFloat = worldToLocal(this.cameraPosition);
			var vsLocalCameraDirection		: SFloat = subtract(vsLocalPosition, cLocalCameraPosition);
			var vsTangentCameraDirection	: SFloat = deltaLocalToTangent(vsLocalCameraDirection);
			var fsTangentCameraDirection	: SFloat = normalize(interpolate(vsTangentCameraDirection));
			
			return specularFromVectors(lightId, fsTangentLightDirection, fsTangentNormal, fsTangentCameraDirection);
		}
		
		/**
		 * @inherit
		 */		
		override public function computeSpecularInLocalSpace(lightId:uint):SFloat
		{
			var cLocalLightDirection	: SFloat = deltaWorldToLocal(getLightParameter(lightId, 'worldDirection', 3));
			
			var cLocalCameraPosition	: SFloat = worldToLocal(this.cameraPosition);
			var vsLocalCameraDirection	: SFloat = subtract(vsLocalPosition, cLocalCameraPosition);
			var fsLocalCameraDirection	: SFloat = interpolate(vsLocalCameraDirection);
			
			return specularFromVectors(lightId, cLocalLightDirection, fsLocalNormal, fsLocalCameraDirection);
		}
		
		/**
		 * @inherit
		 */
		override public function computeSpecularInWorldSpace(lightId : uint) : SFloat
		{
			var cWorldCameraPosition			: SFloat = this.cameraPosition;
			var fsWorldCameraDirection			: SFloat = normalize(subtract(fsWorldPosition, cWorldCameraPosition));
			
			var cLightWorldDirection			: SFloat = getLightParameter(lightId, 'worldDirection', 3);
			var fsWorldLightReflectedDirection	: SFloat = negate(reflect(cLightWorldDirection, fsWorldNormal));
			
			return specularFromVectors(lightId, fsWorldLightReflectedDirection, fsWorldNormal, fsWorldCameraDirection);
		}
		
	}
}
