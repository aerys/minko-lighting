package aerys.minko.render.shader.parts.lighting.contribution
{
	import aerys.minko.render.shader.ActionScriptShader;
	import aerys.minko.render.shader.ActionScriptShaderPart;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	
	import flash.utils.Dictionary;

	public class InfiniteDiffuseShaderPart extends ActionScriptShaderPart implements IContributionShaderPart
	{
		public function InfiniteDiffuseShaderPart(main : ActionScriptShader)
		{
			super(main);
		}
		
		public function getDynamicTerm(lightId		: uint, 
									   lightData	: LightData,
									   position		: SValue = null,
									   normal		: SValue = null) : SValue
		{
			if (lightData.diffuse == 0)
				return null;
			
			normal ||= normalize(interpolate(vertexNormal));
			
			var lightDirection		: SValue = getWorldParameter(3, LightData, LightData.LOCAL_DIRECTION, lightId);
			var lightDiffuse		: SValue = getWorldParameter(1, LightData, LightData.LOCAL_DIFFUSE, lightId);
			
			var lambertProduct		: SValue = saturate(negate(dotProduct3(lightDirection, normal)));
			
			return multiply(lightDiffuse, lambertProduct);
		}
		
		public function getDynamicDataHash(lightData: LightData) : String
		{
			return uint(lightData.diffuse == 0).toString();
		}
		
		public function getStaticTerm(lightData : LightData,
									  position	: SValue = null,
									  normal	: SValue = null) : SValue
		{
			if (lightData.diffuse == 0)
				return null;
			
			normal ||= normalize(interpolate(vertexNormal));
			
			var lightDirection		: SValue = float3(lightData.localDirection);
			var lightDiffuse		: SValue = float(lightData.localDiffuse);
			
			var lambertProduct		: SValue = saturate(negate(dotProduct3(lightDirection, normal)));
			
			return multiply(lightDiffuse, lambertProduct);
		}
		
		public function getStaticDataHash(lightData : LightData) : String
		{
			return lightData.localDirection.toString() + lightData.diffuse.toString();
		}
		
		override public function getDataHash(styleData		: StyleData, 
											 transformData	: TransformData, 
											 worldData		: Dictionary) : String
		{
			throw new Error('Use getDynamicDataHash or getStaticDataHash.');
		}
	}
}
