package aerys.minko.scene.node.light
{
	import aerys.minko.ns.minko;
	import aerys.minko.scene.data.IWorldData;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.LocalData;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Vector4;
	
	use namespace minko;
	
	public class DirectionalLight extends AbstractLight
	{
		protected var _direction 		: Vector4;
		protected var _diffuse			: Number;
		protected var _specular			: Number;
		protected var _shininess		: Number;
		protected var _shadowMapSize	: uint;
		
		public function get shadowMapSize() : uint
		{
			return _shadowMapSize;
		}

		public function set shadowMapSize(value : uint) : void
		{
			_shadowMapSize = value;
		}

		public function set diffuse(value : Number) : void
		{
			_diffuse = value;
		}

		public function set specular(value : Number) : void
		{
			_specular = value;
		}

		public function set shininess(value : Number) : void
		{
			_shininess = value;
		}

		public function get direction()	: Vector4
		{
			return _direction; 
		}
		
		public function get diffuse() : Number	
		{
			return _diffuse; 
		}
				
		public function get specular() : Number	
		{ 
			return _specular; 
		}
		
		public function get shininess() : Number
		{
			return _shininess; 
		}
		
		public function DirectionalLight(color			: uint		= 0xFFFFFF,
										 diffuse		: Number	= .6,
										 specular		: Number	= .8,
										 shininess		: Number	= 64,
										 direction		: Vector4 	= null,
										 group			: uint		= 0x1)
		{
			super(color, group);
			
			_direction		= direction ? direction.normalize() : new Vector4(0., -1., 0);
			_diffuse		= diffuse;
			_specular		= specular;
			_shininess		= shininess;
			_shadowMapSize	= 0;
		}
		
		override public function getLightData(localData : LocalData) : LightData
		{
			if ((isNaN(_diffuse) || _diffuse == 0) && (isNaN(_specular) || _specular == 0))
				return null;
			
			// compute world space direction
			var worldMatrix		: Matrix4x4	= localData.world;
			var worldDirection	: Vector4	= worldMatrix.deltaMultiplyVector(_direction).normalize();
			var ld 				: LightData = LIGHT_DATA.create(true) as LightData;
			
			ld.reset();
			ld._type			= LightData.TYPE_DIRECTIONAL;
			ld._group			= _group;
			ld._direction		= worldDirection;
			ld._color			= _color;
			ld._diffuse			= _diffuse;
			ld._specular		= _specular;
			ld._shininess		= _shininess;
			ld._shadowMapSize	= _shadowMapSize;
			
			return ld;
		}
	}
}
