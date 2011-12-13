package aerys.minko.render.shader.parts.lighting.attenuation
{
	import aerys.minko.render.shader.ActionScriptShaderPart;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.type.stream.format.VertexComponent;
	
	public class SmoothConicAttenuationShaderPart extends ActionScriptShaderPart implements IAttenuationShaderPart
	{
		public function getDynamicFactor(lightId	: uint,
										 position	: SValue = null) : SValue
		{
			position ||= getVertexAttribute(VertexComponent.XYZ);
			
			var interpolatedPos		: SValue = interpolate(position);
			
			var lightPosition		: SValue = getWorldParameter(3, LightData, LightData.LOCAL_POSITION, lightId);
			var lightDirection		: SValue = getWorldParameter(3, LightData, LightData.LOCAL_DIRECTION, lightId);
			var factor1				: SValue = getWorldParameter(1, LightData, LightData.RADIUS_INTERPOLATION_1, lightId);
			var factor2				: SValue = getWorldParameter(1, LightData, LightData.RADIUS_INTERPOLATION_2, lightId);
			
			var lightToPoint		: SValue = subtract(interpolatedPos, lightPosition);
			var lightAngleCosine	: SValue = dotProduct3(lightDirection, normalize(lightToPoint));
			
			return saturate(add(factor1, multiply(factor2, lightAngleCosine)));
		}
		
		public function getStaticFactor(lightData	: LightData,
										position	: SValue = null) : SValue
		{
			position ||= getVertexAttribute(VertexComponent.XYZ);
			
			var interpolatedPos		: SValue = interpolate(position);
			
			var lightPosition		: SValue = float3(lightData.localPosition);
			var lightDirection		: SValue = float3(lightData.localDirection);
			var factor1				: SValue = float(lightData.radiusInterpolation1);
			var factor2				: SValue = float(lightData.radiusInterpolation2);
			
			var lightToPoint		: SValue = subtract(interpolatedPos, lightPosition);
			var lightAngleCosine	: SValue = dotProduct3(lightDirection, normalize(lightToPoint));
			
			return saturate(add(factor1, multiply(factor2, lightAngleCosine)));
		}
		
		public function getStaticDataHash(lightData : LightData) : String
		{
			return lightData.localPosition.toString()
				+ lightData.localDirection.toString()
				+ lightData.radiusInterpolation1.toString()
				+ lightData.radiusInterpolation2.toString();
		}
	}
}

