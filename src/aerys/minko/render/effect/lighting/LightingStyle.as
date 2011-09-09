package aerys.minko.render.effect.lighting
{
	import aerys.minko.render.effect.Style;

	public final class LightingStyle
	{
		public static const LIGHT_ENABLED			: int = Style.getStyleId("light enabled");
		public static const GROUP					: int = Style.getStyleId("light group");
		
		public static const LIGHTMAP				: int = Style.getStyleId("light map");
		public static const LIGHTMAP_MULTIPLIER		: int = Style.getStyleId("light map multiplier");
		
		public static const AMBIENT_MULTIPLIER		: int = Style.getStyleId("lighted ambient");
		public static const DIFFUSE_MULTIPLIER		: int = Style.getStyleId("lighted diffuse");
		public static const SPECULAR_MULTIPLIER		: int = Style.getStyleId("lighted specular");
		public static const SHININESS_MULTIPLIER	: int = Style.getStyleId("lighted shininess");
		public static const CAST_SHADOWS			: int = Style.getStyleId("lighted cast shadows");
		public static const RECEIVE_SHADOWS			: int = Style.getStyleId("lighted receive shadows");
	}
}
