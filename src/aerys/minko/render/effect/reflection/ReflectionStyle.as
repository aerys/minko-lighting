package aerys.minko.render.effect.reflection
{
	import aerys.minko.scene.visitor.data.Style;

	public final class ReflectionStyle
	{
		public static const REFLECTION_ENABLED	: int	= Style.getStyleId("ref_enabled");
		public static const RGBA				: int	= Style.getStyleId("ref_rgba");
		public static const ENVIRONMENT_MAP		: int	= Style.getStyleId("ref_environmentMap");
		public static const BLENDING			: int	= Style.getStyleId("ref_blending");
	}
}
