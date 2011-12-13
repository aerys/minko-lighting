package aerys.minko.render.shader.parts.lighting.attenuation
{
	import aerys.minko.render.shader.ActionScriptShaderPart;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.type.stream.format.VertexComponent;
	
	public class HardConicAttenuationShaderPart extends ActionScriptShaderPart implements IAttenuationShaderPart
	{
		public function getDynamicFactor(lightId	: uint,
										 position	: SValue = null) : SValue
		{
			position ||= getVertexAttribute(VertexComponent.XYZ);
			
			var interpolatedPos		: SValue = interpolate(position);
			var lightPosition		: SValue = getWorldParameter(3, LightData, LightData.LOCAL_POSITION, lightId);
			var lightDirection		: SValue = getWorldParameter(3, LightData, LightData.LOCAL_DIRECTION, lightId);
			var lightRadiusCosine	: SValue = getWorldParameter(1, LightData, LightData.OUTER_RADIUS_COSINE, lightId);
			
			var lightToPoint		: SValue = subtract(interpolatedPos, lightPosition);
			var lightAngleCosine	: SValue = dotProduct3(lightDirection, normalize(lightToPoint));
			
			return ifGreaterEqual(lightAngleCosine, lightRadiusCosine);
		}
		
		public function getStaticFactor(lightData	: LightData,
										position	: SValue = null) : SValue
		{
			position ||= getVertexAttribute(VertexComponent.XYZ);
			
			var interpolatedPos		: SValue = interpolate(position);
			var lightPosition		: SValue = float3(lightData.localPosition);
			var lightDirection		: SValue = float3(lightData.localDirection);
			var lightRadiusCosine	: SValue = float(lightData.outerRadiusCosine);
			
			var lightToPoint		: SValue = subtract(interpolatedPos, lightPosition);
			var lightAngleCosine	: SValue = dotProduct3(lightDirection, normalize(lightToPoint));
			
			return ifGreaterEqual(lightAngleCosine, lightRadiusCosine);
		}
		
		public function getStaticDataHash(lightData : LightData) : String
		{
			return lightData.localPosition
				+ lightData.localDirection
				+ lightData.outerRadiusCosine;
		}
	}
}
