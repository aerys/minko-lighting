package aerys.minko.render.effect.lighting
{
	import aerys.minko.ns.minko_lighting;

	public final class LightingProperties
	{
		public static const RECEPTION_MASK			: String = 'lightReceptionMask';
		
		public static const LIGHTMAP				: String = 'lightMap';
		public static const LIGHTMAP_MULTIPLIER		: String = 'lightMapMultiplier';
		
		public static const AMBIENT_MULTIPLIER		: String = 'lightAmbientMultiplier';
		public static const DIFFUSE_MULTIPLIER		: String = 'lightDiffuseMultiplier';
		public static const SPECULAR_MULTIPLIER		: String = 'lightSpecularMultiplier';
		public static const SHININESS_MULTIPLIER	: String = 'lightShininessMultiplier';
		
		public static const NORMAL_MAPPING_TYPE		: String = 'lightNormalMappingType';
		public static const NORMAL_MAP				: String = 'lightNormalMap';
		public static const HEIGHT_MAP				: String = 'lightHeightMap'; 
		
		public static const SHADOWS_BIAS			: String = 'lightShadowsBias';
		public static const CAST_SHADOWS			: String = 'lightCastShadows';
		public static const RECEIVE_SHADOWS			: String = 'lightReceiveShadows';
		
		minko_lighting static function getNameFor(lightId		: uint,
												  propertyName	: String) : String
		{
			return 'light_' + propertyName + '_' + lightId;
		}
		
		minko_lighting static function getPropertyFor(name : String) : String
		{
			return name.substring('light_'.length, name.lastIndexOf('_'));
		}
	}
}
