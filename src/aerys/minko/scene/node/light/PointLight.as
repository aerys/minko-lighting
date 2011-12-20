package aerys.minko.scene.node.light
{
	public class PointLight extends ConstPointLight
	{
		public static const TYPE : uint = 7;
		
		override public function get type() : uint
		{
			return TYPE;
		}
		
		public function set color		(v : uint)		: void { _color		= v; }
		public function set distance	(v : Number)	: void { _distance	= v; }
		public function set diffuse		(v : Number)	: void { _diffuse	= v; }
		public function set specular	(v : Number)	: void { _specular	= v; }
		public function set shininess	(v : Number)	: void { _shininess = v; }
		
		public function PointLight(color				: uint		= 0xFFFFFF, 
								   diffuse				: Number	= .6, 
								   specular				: Number	= .8, 
								   shininess			: Number	= 64, 
								   distance				: Number	= 0, 
								   group				: uint		= 0x1, 
								   shadowMapSize		: uint		= 0, 
								   useParaboloidShadows	: Boolean	= false)
		{
			super(color, diffuse, specular, shininess, distance, group, shadowMapSize, useParaboloidShadows);
		}
	}
}