package aerys.minko.scene.node.light
{
	import aerys.minko.ns.minko;
	import aerys.minko.scene.data.IWorldData;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.TransformData;

	use namespace minko;
	
	public class AmbientLight extends AbstractLight
	{
		protected var _ambient : Number;
		
		public function get ambient() : Number
		{
			return _ambient; 
		}
		
		public function AmbientLight(color		: uint		= 0xFFFFFF, 
									 ambient	: Number	= .4,
									 group		: uint		= 0x1)
		{
			super(color, group);
			
			_ambient = ambient;
		}
		
		override public function getLightData(transformData : TransformData) : LightData
		{
			if (isNaN(_ambient) || _ambient == 0)
				return null;
			
			var ld : LightData = LIGHT_DATA.create(true) as LightData;
			
			ld.reset();
			ld._type			= LightData.TYPE_AMBIENT;
			ld._group			= _group;
			ld._color			= _color;
			ld._ambient			= _ambient;
			ld._shadowMapSize	= 0;
			
			return ld;
		}
	}
}
