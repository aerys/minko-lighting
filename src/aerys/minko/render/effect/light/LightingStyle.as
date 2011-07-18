package aerys.minko.render.effect.light
{
	import aerys.minko.render.effect.Style;

	public final class LightingStyle
	{
		public static const LIGHT_ENABLED	: int = Style.getStyleId("light enabled");
		
		public static const AMBIENT			: int = Style.getStyleId("lighted_ambient");
		public static const DIFFUSE			: int = Style.getStyleId("lighted_diffuse");
		
		public static const SPECULAR		: int = Style.getStyleId("lighted_specular");
		public static const SHININESS		: int = Style.getStyleId("lighted_shininess");
		
		public static const CAST_SHADOWS	: int = Style.getStyleId("lighted_cast_shadows");
		public static const RECEIVE_SHADOWS	: int = Style.getStyleId("lighted_receive_shadows");
	}
}
