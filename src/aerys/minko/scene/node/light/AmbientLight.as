package aerys.minko.scene.node.light
{
	import aerys.minko.scene.visitor.data.LightData;
	import aerys.minko.scene.visitor.data.IWorldData;
	import aerys.minko.scene.visitor.data.TransformManager;

	public class AmbientLight extends AbstractLight
	{
		protected var _ambient : Number;
		
		public function get ambient() : Number
		{
			return _ambient; 
		}
		
		public function AmbientLight(color		: uint		= 0xFFFFFF, 
									 ambient	: Number	= .4)
		{
			super(color);
			
			_ambient = ambient;
		}
		
		override public function getData(transformManager : TransformManager) : IWorldData
		{
			if (isNaN(_ambient) || _ambient == 0)
				return null;
			
			var ld : LightData = LIGHT_DATA.create(true);
			ld.reset();
			ld.type				= LightData.TYPE_AMBIENT;
			ld.color			= _color;
			ld.ambient			= _ambient;
			ld.shadowMapSize	= 0;
			
			return ld;
		}
	}
}
