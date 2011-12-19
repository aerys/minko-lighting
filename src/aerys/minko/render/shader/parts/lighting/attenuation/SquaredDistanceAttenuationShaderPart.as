package aerys.minko.render.shader.parts.lighting.attenuation
{
	import aerys.minko.render.shader.ActionScriptShader;
	import aerys.minko.render.shader.ActionScriptShaderPart;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.type.stream.format.VertexComponent;
	
	public class SquaredDistanceAttenuationShaderPart extends ActionScriptShaderPart implements IAttenuationShaderPart
	{
		public function SquaredDistanceAttenuationShaderPart(main : ActionScriptShader)
		{
			super(main);
		}
		
		public function getDynamicFactor(lightId 	: uint,
										 position	: SValue = null) : SValue
		{
			position ||= getVertexAttribute(VertexComponent.XYZ);
			
			var interpolatedPos		: SValue = interpolate(position);
			
			var lightPosition		: SValue = getWorldParameter(3, LightData, LightData.LOCAL_POSITION, lightId);
			var lightSquareDistance : SValue = getWorldParameter(1, LightData, LightData.SQUARE_LOCAL_DISTANCE, lightId);
			
			var lightToPoint		: SValue = subtract(interpolatedPos, lightPosition);
			var squareDistance		: SValue = dotProduct3(lightToPoint, lightToPoint);
			
			return saturate(divide(lightSquareDistance, squareDistance));
		}
		
		public function getStaticFactor(lightData : LightData,
										position	: SValue = null) : SValue
		{
			position ||= getVertexAttribute(VertexComponent.XYZ);
			
			var interpolatedPos		: SValue = interpolate(position);
			
			var lightPosition		: SValue = float3(lightData.localPosition);
			var lightSquareDistance : SValue = float(lightData.squareLocalDistance);
			
			var lightToPoint		: SValue = subtract(interpolatedPos, lightPosition);
			var squareDistance		: SValue = dotProduct3(lightToPoint, lightToPoint);
			
			return saturate(divide(lightSquareDistance, squareDistance));
		}
		
		public function getStaticDataHash(lightData : LightData) : String
		{
			return lightData.localPosition.toString() + lightData.squareLocalDistance;
		}
		
	}
}
