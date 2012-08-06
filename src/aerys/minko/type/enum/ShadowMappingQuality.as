package aerys.minko.type.enum
{
	public class ShadowMappingQuality
	{
		public static const HARD				: uint = 0;
		public static const LOW					: uint = 1 << 1;
		public static const LOW_DOUBLE			: uint = 1 << 1 | 1;
		public static const MEDIUM				: uint = 2 << 1;
		public static const MEDIUM_DOUBLE		: uint = 2 << 1 | 1;
		public static const HIGH				: uint = 3 << 1;
		public static const HIGH_DOUBLE			: uint = 3 << 1 | 1;
	}
}
