package aerys.minko.render.shader.parts.lighting.contribution
{
	import aerys.minko.render.shader.ActionScriptShader;
	import aerys.minko.render.shader.ActionScriptShaderPart;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.scene.data.CameraData;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	import aerys.minko.type.stream.format.VertexComponent;
	
	import flash.utils.Dictionary;
	
	public class LocalizedSpecularShaderPart extends ActionScriptShaderPart implements IContributionShaderPart
	{
		public function LocalizedSpecularShaderPart(main : ActionScriptShader)
		{
			super(main);
		}
		
		public function getDynamicTerm(lightId		: uint,
									   lightData	: LightData,
									   position		: SValue = null,
									   normal		: SValue = null) : SValue
		{
			if (lightData.specular == 0)
				return null;
			
			position ||= getVertexAttribute(VertexComponent.XYZ);
			normal	 ||= getVertexAttribute(VertexComponent.NORMAL);
			
			var interpolatedPos		: SValue = interpolate(position);
			var interpolatedNormal	: SValue = normalize(interpolate(normal));
			
			var cameraPosition		: SValue = getWorldParameter(3, CameraData, CameraData.LOCAL_POSITION);
			var lightPosition		: SValue = getWorldParameter(3, LightData, LightData.LOCAL_POSITION, lightId);
			var lightSpecular		: SValue = getWorldParameter(1, LightData, LightData.LOCAL_SPECULAR, lightId);
			var lightShininess		: SValue = getWorldParameter(1, LightData, LightData.LOCAL_SHININESS, lightId);
			
			var lightDirection		: SValue = normalize(subtract(interpolatedPos, lightPosition));
			var viewDirection		: SValue = normalize(subtract(cameraPosition, interpolatedPos));
			var lightReflection		: SValue = reflect(lightDirection, interpolatedNormal);
			
			var lambertProduct		: SValue = saturate(dotProduct3(lightReflection, viewDirection));
			
			return multiply(lightSpecular, power(lambertProduct, lightShininess));
		}
		
		public function getDynamicDataHash(lightData: LightData) : String
		{
			return uint(lightData.specular == 0).toString();
		}
		
		public function getStaticTerm(lightData : LightData,
									  position	: SValue = null,
									  normal	: SValue = null) : SValue
		{
			if (lightData.specular == 0)
				return null;
			
			position ||= getVertexAttribute(VertexComponent.XYZ);
			normal	 ||= getVertexAttribute(VertexComponent.NORMAL);
			
			var interpolatedPos		: SValue = interpolate(position);
			var interpolatedNormal	: SValue = normalize(interpolate(normal));
			
			var cameraPosition		: SValue = getWorldParameter(3, CameraData, CameraData.LOCAL_POSITION);
			
			var lightPosition		: SValue = float3(lightData.localPosition);
			var lightSpecular		: SValue = float(lightData.localSpecular);
			var lightShininess		: SValue = float(lightData.localShininess);
			
			var lightDirection		: SValue = normalize(subtract(lightPosition, interpolatedPos));
			var viewDirection		: SValue = normalize(subtract(interpolatedPos, cameraPosition));
			var lightReflection		: SValue = reflect(lightDirection, interpolatedNormal);
			
			var lambertProduct		: SValue = saturate(negate(dotProduct3(lightReflection, viewDirection)));
			
			return multiply(lightSpecular, power(lambertProduct, lightShininess));
		}
		
		public function getStaticDataHash(lightData : LightData) : String
		{
			return lightData.localPosition.toString() 
				+ lightData.localSpecular.toString() 
				+ lightData.localShininess.toString();
		}
		
		override public function getDataHash(styleData		: StyleData, 
											 transformData	: TransformData, 
											 worldData		: Dictionary) : String
		{
			throw new Error('Use getDynamicDataHash or getStaticDataHash.');
		}
	}
}