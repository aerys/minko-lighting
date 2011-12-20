package aerys.minko.scene.node.light
{
	public class ConstSpotLight extends AbstractLight
	{
		public static const TYPE : uint = 4;

		protected var _distance			: Number;
		protected var _diffuse			: Number;
		protected var _specular			: Number;
		protected var _shininess		: Number;
		protected var _innerRadius		: Number;
		protected var _outerRadius		: Number;
		protected var _shadowMapSize	: uint;
		
		override public function get type() : uint
		{
			return TYPE;
		}
		
		public function get distance()		: Number	{ return _distance;			}
		public function get diffuse()		: Number	{ return _diffuse;			}
		public function get specular()		: Number	{ return _specular;			} 
		public function get shininess()		: Number	{ return _shininess;		}
		public function get innerRadius()	: Number	{ return _innerRadius;		}
		public function get outerRadius()	: Number	{ return _outerRadius;		}
		public function get shadowMapSize()	: uint		{ return _shadowMapSize;	}
		
		public function set shadowMapSize	(v : uint) 		: void { _shadowMapSize	= v; }
		
		public function ConstSpotLight(color			: uint		= 0xFFFFFF,
									   diffuse			: Number	= .6,
									   specular			: Number	= .8,
									   shininess		: Number	= 64,
									   distance			: Number	= 0,
									   outerRadius		: Number	= .4,
									   innerRadius		: Number	= .4,
									   group			: uint		= 0x1,
									   shadowMapSize	: uint		= 0)
		{
			super(color, group);
			
			_distance				= distance;
			_diffuse				= diffuse;
			_specular				= specular;
			_shininess				= shininess;
			_innerRadius			= innerRadius;
			_outerRadius			= outerRadius;
			_shadowMapSize			= shadowMapSize;
		}
	}
}