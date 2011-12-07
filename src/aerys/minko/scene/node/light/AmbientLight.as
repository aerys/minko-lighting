package aerys.minko.scene.node.light
{
	public class AmbientLight extends AbstractLight
	{
		public static const TYPE : uint = 1;
		
		protected var _ambient : Number;
		
		public function get ambient() : Number { return _ambient; }
		
		public function set ambient(v : Number) : void { _ambient = v; }
		
		public function AmbientLight(color		: uint		= 0xFFFFFF, 
									 ambient	: Number	= .4,
									 group		: uint		= 0x1)
		{
			super(color, group);
			
			_ambient = ambient;
		}
	}
}
