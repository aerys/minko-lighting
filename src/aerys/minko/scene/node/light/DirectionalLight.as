package aerys.minko.scene.node.light
{
	public class DirectionalLight extends ConstDirectionalLight
	{
		public static const TYPE : uint = 6;
		
		override public function get type() : uint
		{
			return TYPE;
		}
		
		public function set color		(v : uint)		: void { _color		= v; }
		public function set diffuse		(v : Number)	: void { _diffuse	= v; }
		public function set specular	(v : Number)	: void { _specular	= v; }
		public function set shininess	(v : Number)	: void { _shininess	= v; }
		
		public function DirectionalLight(color			: uint		= 0xFFFFFF, 
										 diffuse		: Number	= .6, 
										 specular		: Number	= .8, 
										 shininess		: Number	= 64, 
										 group			: uint		= 0x1, 
										 shadowMapSize	: uint		= 0)
		{
			super(color, diffuse, specular, shininess, group, shadowMapSize);
		}
	}
}
