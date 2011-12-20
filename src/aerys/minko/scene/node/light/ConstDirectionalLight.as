package aerys.minko.scene.node.light
{
	public class ConstDirectionalLight extends AbstractLight
	{
		public static const TYPE : uint = 2;

		protected var _diffuse			: Number;
		protected var _specular			: Number;
		protected var _shininess		: Number;
		protected var _shadowMapSize	: uint;
		
		override public function get type() : uint
		{
			return TYPE;
		}
		
		public function get diffuse()		: Number	{ return _diffuse;			}
		public function get specular()		: Number	{ return _specular;			}
		public function get shininess()		: Number	{ return _shininess;		}
		public function get shadowMapSize()	: uint		{ return _shadowMapSize;	}
		
		public function set shadowMapSize(v : uint) : void { _shadowMapSize = v;	}
		
		public function ConstDirectionalLight(color			: uint		= 0xFFFFFF,
											  diffuse		: Number	= .6,
											  specular		: Number	= .8,
											  shininess		: Number	= 64,
											  group			: uint		= 0x1,
											  shadowMapSize	: uint		= 0)
		{
			super(color, group);
			
			_diffuse		= diffuse;
			_specular		= specular;
			_shininess		= shininess;
			_shadowMapSize	= shadowMapSize;
		}
	}
}
