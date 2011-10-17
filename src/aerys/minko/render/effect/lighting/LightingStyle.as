package aerys.minko.render.effect.lighting
{
	import aerys.minko.render.effect.Style;

	public final class LightingStyle
	{
		public static const LIGHTS_ENABLED			: int = Style.getStyleId("light lights enabled");
		public static const GROUP					: int = Style.getStyleId("light group");
		
		public static const LIGHTMAP				: int = Style.getStyleId("light map");
		public static const LIGHTMAP_MULTIPLIER		: int = Style.getStyleId("light map multiplier");
		
		public static const AMBIENT_MULTIPLIER		: int = Style.getStyleId("light ambient");
		public static const DIFFUSE_MULTIPLIER		: int = Style.getStyleId("light diffuse");
		public static const SPECULAR_MULTIPLIER		: int = Style.getStyleId("light specular");
		public static const SHININESS_MULTIPLIER	: int = Style.getStyleId("light shininess");
		
		public static const SHADOWS_ENABLED			: int = Style.getStyleId("light shadows enabled");
		public static const SHADOWS_BIAS			: int = Style.getStyleId("light shadows bias");
		public static const CAST_SHADOWS			: int = Style.getStyleId("light cast shadows");
		public static const RECEIVE_SHADOWS			: int = Style.getStyleId("light receive shadows");
	}
}
