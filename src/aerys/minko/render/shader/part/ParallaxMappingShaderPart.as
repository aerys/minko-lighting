package aerys.minko.render.shader.part
{
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.part.lighting.LightAwareShaderPart;
	
	/**
	 * 
	 * @author Loic Bethmont
	 * @author Romain Gilliotte
	 */	
	public class ParallaxMappingShaderPart extends LightAwareShaderPart
	{
		private static const DEFAULT_STEEP_NSTEPS	: uint		= 20;
		private static const DEFAULT_BUMPSCALE		: Number	= 0.03;
		
		public function ParallaxMappingShaderPart(main : Shader)
		{
			super(main);
		}
		
		public function getSteepParallaxMappedUV(fsBaseUV : SFloat) : SFloat
		{
			// Retrieve attributes, constants, textures, config
			var numSteps	: uint		= meshBindings.getConstant(LightingProperties.PARALLAX_MAPPING_NBSTEPS, DEFAULT_STEEP_NSTEPS);
			
			var fsHeightMap	: SFloat	= meshBindings.getTextureParameter(LightingProperties.HEIGHT_MAP);
			var cBumpScale	: SFloat	= meshBindings.propertyExists(LightingProperties.PARALLAX_MAPPING_BUMP_SCALE) ? 
										  meshBindings.getParameter(LightingProperties.PARALLAX_MAPPING_BUMP_SCALE, 1) : 
										  float(DEFAULT_BUMPSCALE);
			
			// compute camera direction
			var cLocalCameraPosition		: SFloat = worldToLocal(sceneBindings.getParameter('cameraPosition', 4));
			var vsLocalCameraDirection		: SFloat = subtract(cLocalCameraPosition, vsLocalPosition);
			var fsTangentCameraDirection	: SFloat = normalize(interpolate(deltaLocalToTangent(vsLocalCameraDirection)));
			
			// init iteration data
			var height			: Number = 1.;
			var step			: Number = 1. / numSteps;
			
			var fsOffset		: SFloat = fsBaseUV;
			var fsDelta			: SFloat = multiply(divide(fsTangentCameraDirection.xy, fsTangentCameraDirection.z), divide(cBumpScale, numSteps));
			var fsNb			: SFloat = sampleTexture(fsHeightMap, fsOffset);
			var fsLoopRunning	: SFloat = float(1);
			
			// iterate on height map
			for (var stepId : uint = 0; stepId < numSteps; ++stepId)
			{
				height -= step;
				
				fsOffset.decrementBy(multiply(fsDelta, fsLoopRunning));
				fsNb = sampleTexture(fsHeightMap, fsOffset);
				
				fsLoopRunning = lessThan(fsNb.x, height);
			}
			
			return fsOffset;
		}
	}
}