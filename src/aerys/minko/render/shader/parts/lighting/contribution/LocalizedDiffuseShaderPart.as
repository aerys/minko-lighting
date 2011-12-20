package aerys.minko.render.shader.parts.lighting.contribution
{
	import aerys.minko.render.shader.ActionScriptShader;
	import aerys.minko.render.shader.ActionScriptShaderPart;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	import aerys.minko.type.stream.format.VertexComponent;
	
	import flash.utils.Dictionary;
	
	public class LocalizedDiffuseShaderPart extends ActionScriptShaderPart implements IContributionShaderPart
	{
		public function LocalizedDiffuseShaderPart(main : ActionScriptShader)
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
			
			position ||= getVertexAttribute(VertexComponent.XYZ);
			normal	 ||= getVertexAttribute(VertexComponent.NORMAL);
			
			var interpolatedPos		: SValue = interpolate(position);
			var interpolatedNormal	: SValue = normalize(interpolate(normal));
			
			var lightPosition		: SValue = getWorldParameter(3, LightData, LightData.LOCAL_POSITION, lightId);
			var lightDiffuse		: SValue = getWorldParameter(1, LightData, LightData.LOCAL_DIFFUSE, lightId);
			
			var lightDirection		: SValue = normalize(subtract(lightPosition, interpolatedPos));
			var lambertProduct		: SValue = saturate(dotProduct3(lightDirection, interpolatedNormal));
			
			return multiply(lightDiffuse, lambertProduct);
		}
		
		public function getDynamicDataHash(lightData: LightData) : String
		{
			return uint(lightData.diffuse == 0).toString();
		}
		
		public function getStaticTerm(lightId		: uint,
									  lightData : LightData,
									  position	: SValue = null,
									  normal	: SValue = null) : SValue
		{
			if (lightData.diffuse == 0)
				return null;
			
			position ||= getVertexAttribute(VertexComponent.XYZ);
			normal	 ||= getVertexAttribute(VertexComponent.NORMAL);
			
			var interpolatedPos		: SValue = interpolate(position);
			var interpolatedNormal	: SValue = normalize(interpolate(normal));
			
			var lightPosition	: SValue = getWorldParameter(3, LightData, LightData.LOCAL_POSITION, lightId);
			var lightDiffuse	: SValue = float(lightData.localDiffuse);
			
			var lightDirection	: SValue = normalize(subtract(lightPosition, interpolatedPos));
			var lambertProduct	: SValue = saturate(dotProduct3(lightDirection, interpolatedNormal));
			
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
