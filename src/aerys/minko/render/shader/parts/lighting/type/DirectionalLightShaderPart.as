package aerys.minko.render.shader.parts.lighting.type
{
	import aerys.minko.render.shader.ActionScriptShaderPart;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.render.shader.parts.lighting.attenuation.MatrixShadowMapAttenuationShaderPart;
	import aerys.minko.render.shader.parts.lighting.contribution.InfiniteDiffuseShaderPart;
	import aerys.minko.render.shader.parts.lighting.contribution.InfiniteSpecularShaderPart;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	import aerys.minko.type.stream.format.VertexComponent;
	
	import flash.utils.Dictionary;
	
	public class DirectionalLightShaderPart extends ActionScriptShaderPart
	{
		private static const INFINITE_DIFFUSE	: InfiniteDiffuseShaderPart				= new InfiniteDiffuseShaderPart();
		private static const INFINITE_SPECULAR	: InfiniteSpecularShaderPart			= new InfiniteSpecularShaderPart();
		private static const MATRIX_SHADOW_MAP	: MatrixShadowMapAttenuationShaderPart	= new MatrixShadowMapAttenuationShaderPart();
		
		public function getLightContribution(lightId		: uint,
											 lightData		: LightData,
											 receiveShadows	: Boolean,
											 position		: SValue = null,
											 normal			: SValue = null) : SValue
		{
			position ||= getVertexAttribute(VertexComponent.XYZ);
			normal	 ||= getVertexAttribute(VertexComponent.NORMAL);
			
			var contribution : SValue = float(0);
			
			var diffuse : SValue = INFINITE_DIFFUSE.getDynamicTerm(lightId, lightData, position, normal);
			if (diffuse != null)
				contribution.incrementBy(diffuse);
			
			var specular : SValue = INFINITE_SPECULAR.getDynamicTerm(lightId, lightData, position, normal);
			if (specular != null)
				contribution.incrementBy(specular);
			
			if (diffuse == null && specular == null)
				return null;
			
			if (receiveShadows)
				contribution.scaleBy(MATRIX_SHADOW_MAP.getDynamicFactor(lightId, position));
			
			return contribution;
		}
		
		public function getLightHash(lightData : LightData) : String
		{
			return INFINITE_DIFFUSE.getDynamicDataHash(lightData) + '|' + INFINITE_SPECULAR.getDynamicDataHash(lightData);
		}
		
		override public function getDataHash(styleData		: StyleData, 
											 transformData	: TransformData, 
											 worldData		: Dictionary) : String
		{
			throw new Error('Use getLightHash instead');
		}
		
	}
}
