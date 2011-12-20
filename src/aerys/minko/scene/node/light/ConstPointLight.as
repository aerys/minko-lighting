package aerys.minko.scene.node.light
{
	public class ConstPointLight extends AbstractLight
	{
		public static const TYPE : uint = 3;

		protected var _distance				: Number;
		protected var _diffuse				: Number;
		protected var _specular				: Number;
		protected var _shininess			: Number;
		protected var _shadowMapSize		: uint;
		protected var _useParaboloidShadows	: Boolean;
		
		override public function get type() : uint
		{
			return TYPE;
		}
		
		public function get distance()				: Number	{ return _distance;				}
		public function get diffuse()				: Number	{ return _diffuse;				}
		public function get specular()				: Number	{ return _specular;				} 
		public function get shininess()				: Number	{ return _shininess;			}
		public function get shadowMapSize()			: uint		{ return _shadowMapSize;		}
		public function get useParaboloidShadows()	: Boolean	{ return _useParaboloidShadows;	}

		public function set shadowMapSize		(v : uint) 		: void { _shadowMapSize = v;		}
		public function set useParaboloidShadows(v : Boolean)	: void { _useParaboloidShadows = v;	}
		
		public function ConstPointLight(color				: uint		= 0xFFFFFF,
								   diffuse				: Number	= .6,
								   specular				: Number	= .8,
								   shininess			: Number	= 64,
								   distance				: Number	= 0,
								   group				: uint		= 0x1,
								   shadowMapSize		: uint		= 0,
								   useParaboloidShadows	: Boolean	= false)
		{
			super(color, group); 
			
			_distance				= distance;
			_diffuse				= diffuse;
			_specular				= specular;
			_shininess				= shininess;
			_shadowMapSize			= shadowMapSize;
			_useParaboloidShadows	= useParaboloidShadows;
		}
	}
}
