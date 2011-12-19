package aerys.minko.render.shader.parts.lighting.type
{
	import aerys.minko.render.shader.ActionScriptShader;
	import aerys.minko.render.shader.ActionScriptShaderPart;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.render.shader.parts.lighting.attenuation.MatrixShadowMapAttenuationShaderPart;
	import aerys.minko.render.shader.parts.lighting.contribution.InfiniteDiffuseShaderPart;
	import aerys.minko.render.shader.parts.lighting.contribution.InfiniteSpecularShaderPart;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	
	import flash.utils.Dictionary;
	
	public class DirectionalLightShaderPart extends ActionScriptShaderPart
	{
		private var _infiniteDiffusePart	: InfiniteDiffuseShaderPart				= null;
		private var _infiniteSpecularPart	: InfiniteSpecularShaderPart			= null;
		private var _matrixShadowMapPart	: MatrixShadowMapAttenuationShaderPart	= null;
		
		public function DirectionalLightShaderPart(main : ActionScriptShader)
		{
			super(main);
			
			_infiniteDiffusePart = new InfiniteDiffuseShaderPart(main);
			_infiniteSpecularPart = new InfiniteSpecularShaderPart(main);
			_matrixShadowMapPart = new MatrixShadowMapAttenuationShaderPart(main);
		}
		
		public function getLightContribution(lightId		: uint,
											 lightData		: LightData,
											 receiveShadows	: Boolean,
											 position		: SValue = null,
											 normal			: SValue = null) : SValue
		{
			position ||= interpolate(vertexPosition);
			normal	 ||= normalize(interpolate(vertexNormal));
			
			var contribution : SValue = float(0);
			
			var diffuse : SValue = _infiniteDiffusePart.getDynamicTerm(lightId, lightData, position, normal);
			if (diffuse != null)
				contribution.incrementBy(diffuse);
			
			var specular : SValue = _infiniteSpecularPart.getDynamicTerm(lightId, lightData, position, normal);
			if (specular != null)
				contribution.incrementBy(specular);
			
			if (diffuse == null && specular == null)
				return null;
			
			if (receiveShadows)
				contribution.scaleBy(_matrixShadowMapPart.getDynamicFactor(lightId, position));
			
			return contribution;
		}
		
		public function getLightHash(lightData : LightData) : String
		{
			return _infiniteDiffusePart.getDynamicDataHash(lightData) + '|' + _infiniteSpecularPart.getDynamicDataHash(lightData);
		}
		
		override public function getDataHash(styleData		: StyleData, 
											 transformData	: TransformData, 
											 worldData		: Dictionary) : String
		{
			throw new Error('Use getLightHash instead');
		}
		
	}
}
