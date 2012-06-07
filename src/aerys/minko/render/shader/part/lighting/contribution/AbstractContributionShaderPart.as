package aerys.minko.render.shader.part.lighting.contribution
{
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.part.lighting.LightAwareShaderPart;

	public class AbstractContributionShaderPart extends LightAwareShaderPart
	{
		public function AbstractContributionShaderPart(main : Shader)
		{
			super(main);
		}
		
		/**
		 * Creates the shader subgraph to compute the diffuse value of a given light.
		 * 
		 * Computing in tangent space is computationally more expensive, both in CPU and GPU, than the other methods
		 * but allow to both bump and parallax mapping.
		 * 
		 * @param lightId The id of the localized light (PointLight or SpotLight)
		 * @return Shader subgraph representing the diffuse value of this light. 
		 */
		public function computeDiffuseInTangentSpace(lightId : uint) : SFloat
		{
			throw new Error('Must be overriden');
		}
		
		/**
		 * Creates the shader subgraph to compute the diffuse value of a given light.
		 * 
		 * Computing lights in local space is computationally more expensive on the CPU, because the light
		 * position will need to be converted in the CPU for each mesh and at each frame.
		 * 
		 * The cost of each light will be in O(number of meshes) on the CPU.
		 * However, this is the way that will lead to the smaller shaders, and is therefor recomended when used
		 * in small scenes with many lights.
		 * 
		 * @param lightId The id of the localized light (PointLight or SpotLight)
		 * @return Shader subgraph representing the diffuse value of this light. 
		 */
		public function computeDiffuseInLocalSpace(lightId : uint) : SFloat
		{
			throw new Error('Must be overriden');
		}
		
		/**
		 * Creates the shader subgraph to compute the diffuse value of a given light.
		 * 
		 * Computing lights in world space is cheaper on the CPU, because no extra computation is
		 * needed, but will cost one extra matrix multiplication on the GPU (to obtain the world position
		 * or every fragment). 
		 * 
		 * @param lightId The id of the light
		 * @return Shader subgraph representing the diffuse value of this light. 
		 */
		public function computeDiffuseInWorldSpace(lightId : uint) : SFloat
		{
			throw new Error('Must be overriden');
		}
		
		/**
		 * Creates the shader subgraph to compute the specular value of a given light.
		 * 
		 * 
		 * @param lightId
		 * @return 
		 * 
		 */		
		public function computeSpecularInTangentSpace(lightId : uint) : SFloat
		{
			throw new Error('Must be overriden');
		}
		
		public function computeSpecularInLocalSpace(lightId : uint) : SFloat
		{
			throw new Error('Must be overriden');
		}
		
		public function computeSpecularInWorldSpace(lightId : uint) : SFloat
		{
			throw new Error('Must be overriden');
		}
		
		/**
		 * Compute final diffuse value from light direction and normal.
		 * Both requested vector can be in any space (tangent, local, light, view or whatever) but must be in the same space.
		 * Also they must be recheable in the fragment shader (they must be constant, or already interpolated)
		 * 
		 * @param lightId
		 * @param fsLightDirection
		 * @param fsNormal
		 * @return 
		 */		
		protected function diffuseFromVectors(lightId			: uint,
											  fsLightDirection	: SFloat,
											  fsNormal			: SFloat) : SFloat
		{
			var fsLambertProduct	: SFloat = saturate(dotProduct3(fsLightDirection, fsNormal));
			var cDiffuse			: SFloat = getLightParameter(lightId, 'diffuse', 1);
			
			if (meshBindings.propertyExists(LightingProperties.DIFFUSE_MULTIPLIER))
				cDiffuse.scaleBy(meshBindings.getParameter(LightingProperties.DIFFUSE_MULTIPLIER, 1));
			
			return multiply(cDiffuse, fsLambertProduct);
		}
		
		/**
		 * Compute final specular value from light direction, normal, and camera direction.
		 * All three requested vector can be in any space (tangent, local, light, view or whatever) but must all be in the same sapce.
		 * Also they must be recheable in the fragment shader (they must be constant, or already interpolated)
		 * 
		 * @param lightId
		 * @param fsLightDirection
		 * @param fsNormal
		 * @param fsCameraDirection
		 * @return 
		 */		
		protected function specularFromVectors(lightId				: uint, 
											   fsLightDirection		: SFloat, 
											   fsNormal				: SFloat, 
											   fsCameraDirection	: SFloat) : SFloat
		{
			var fsLightReflectedDirection	: SFloat = reflect(fsLightDirection, fsNormal);
			var fsLambertProduct			: SFloat = saturate(negate(dotProduct3(fsLightReflectedDirection, fsCameraDirection)));
			
			var cLightSpecular	: SFloat = getLightParameter(lightId, 'specular', 1);
			var cLightShininess	: SFloat = getLightParameter(lightId, 'shininess', 1);
			
			if (meshBindings.propertyExists(LightingProperties.SPECULAR_MULTIPLIER))
				cLightSpecular.scaleBy(meshBindings.getParameter(LightingProperties.SPECULAR_MULTIPLIER, 1));
			
			if (meshBindings.propertyExists(LightingProperties.SHININESS_MULTIPLIER))
				cLightShininess.scaleBy(meshBindings.getParameter(LightingProperties.SHININESS_MULTIPLIER, 1));
			
			return multiply(cLightSpecular, power(fsLambertProduct, cLightShininess));
		}
	}
}
