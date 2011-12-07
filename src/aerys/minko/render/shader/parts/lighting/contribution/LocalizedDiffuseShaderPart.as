package aerys.minko.render.shader.parts.lighting.contribution
{
	import aerys.minko.render.shader.ActionScriptShaderPart;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	
	import flash.utils.Dictionary;
	
	public class LocalizedDiffuseShaderPart extends ActionScriptShaderPart implements IContributionShaderPart
	{
		public function getDynamicTerm(lightId		: uint,
									   lightData	: LightData,
									   position		: SValue = null,
									   normal		: SValue = null) : SValue
		{
			if (lightData.diffuse == 0)
				return null;
			
			position ||= interpolate(position);
			normal	 ||= normalize(interpolate(normal));
			
			var lightPosition	: SValue = getWorldParameter(3, LightData, LightData.LOCAL_POSITION, lightId);
			var lightDiffuse	: SValue = getWorldParameter(1, LightData, LightData.LOCAL_DIFFUSE, lightId);
			
			var lightDirection	: SValue = normalize(subtract(lightPosition, position));
			var lambertProduct	: SValue = saturate(dotProduct3(lightDirection, normal));
			
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
			
			position ||= interpolate(position);
			normal	 ||= normalize(interpolate(normal));
			
			var lightPosition	: SValue = float3(lightData.localPosition);
			var lightDiffuse	: SValue = float(lightData.localDiffuse);
			
			var lightDirection	: SValue = normalize(subtract(lightPosition, position));
			var lambertProduct	: SValue = saturate(negate(dotProduct3(lightDirection, normal)));
			
			return multiply(lightDiffuse, lambertProduct);
		}
		
		public function getStaticDataHash(lightData : LightData) : String
		{
			return lightData.localPosition.toString() + lightData.localDiffuse.toString();
		}
		
		override public function getDataHash(styleData		: StyleData, 
											 transformData	: TransformData, 
											 worldData		: Dictionary) : String
		{
			throw new Error('Use getDynamicDataHash or getStaticDataHash.');
		}
	}
}
