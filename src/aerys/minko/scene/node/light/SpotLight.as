package aerys.minko.scene.node.light
{
	public class SpotLight extends ConstSpotLight
	{
		public static const TYPE : uint = 8;
		
		override public function get type() : uint
		{
			return TYPE;
		}
		
		public function set color			(v : uint)		: void { _color			= v; }
		public function set distance		(v : Number)	: void { _distance		= v; }
		public function set diffuse			(v : Number)	: void { _diffuse		= v; }
		public function set specular		(v : Number)	: void { _specular		= v; }
		public function set shininess		(v : Number)	: void { _shininess 	= v; }
		public function set innerRadius		(v : Number)	: void { _innerRadius	= v; }
		public function set outerRadius		(v : Number)	: void { _outerRadius	= v; }
		
		public function SpotLight(color			: uint		= 0xFFFFFF, 
								  diffuse		: Number	= .6, 
								  specular		: Number	= .8, 
								  shininess		: Number	= 64, 
								  distance		: Number	= 0, 
								  outerRadius	: Number	= .4, 
								  innerRadius	: Number	= .4, 
								  group			: uint		= 0x1, 
								  shadowMapSize	: uint		= 0)
		{
			super(color, diffuse, specular, shininess, distance, outerRadius, innerRadius, group, shadowMapSize);
		}
	}
}