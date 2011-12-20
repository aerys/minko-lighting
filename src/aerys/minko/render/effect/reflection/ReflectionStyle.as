package aerys.minko.render.effect.reflection
{
	import aerys.minko.render.effect.Style;

	public final class ReflectionStyle
	{
		/**
		 * Enabled or disable reflections 
		 */		
		public static const ENABLED : int = Style.getStyleId("ref_enabled");
		
		/**
		 * final reflection multiplier (before blending)
		 */
		public static const RGBA : int = Style.getStyleId("ref_rgba");
		
		/**
		 * Texture or cubemap used to store the reflections
		 */		
		public static const MAP : int = Style.getStyleId("ref_environmentMap");
		
		/**
		 * How reflections should be blended
		 */		
		public static const BLENDING : int = Style.getStyleId("ref_blending");
		
		/**
		 * Which reflection map should be used, and how
		 * Special values are:
		 *  -4		: static blinn-newell reflection
		 *  -3		: static cube map reflection
		 * 	-2		: static probe reflection
		 *  -1		: do not receive reflections
		 *  n >= 0	: receive reflections from dynamic reflection n
		 */
		public static const RECEIVE : int = Style.getStyleId('ref receive');
		
		/**
		 * This item casts reflections on the following dynamic maps
		 * (this is a bitmask)
		 */		
		public static const CAST : int = Style.getStyleId('ref cast');
	}
}
