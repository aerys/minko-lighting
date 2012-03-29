package aerys.minko.scene.node.light
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.scene.node.Scene;
	import aerys.minko.type.data.DataBindings;
	import aerys.minko.type.data.DataProvider;
	import aerys.minko.type.enum.ShadowMappingType;

	use namespace minko_lighting;
	
	public class AmbientLight extends AbstractLight
	{
		public static const TYPE : uint = 1;
		
		private var _ambient : Number;
		
		override public function get type() : uint
		{
			return TYPE;
		}
		
		override public function get shadowCastingType() : uint
		{
			return ShadowMappingType.NONE;
		}
		
		public function get ambient() : Number
		{
			return _ambient;
		}
		
		public function set ambient(v : Number)	: void
		{
			_ambient = v;
			
			if (!_locked)
				changed.execute(this, 'ambient');
		}
		
		public function AmbientLight(color		: uint		= 0xFFFFFF, 
									 ambient	: Number	= .4,
									 group		: uint		= 0x1)
		{
			super(color, group);
			
			_dataDescriptor	= new Object();
			_ambient		= ambient;
		}
		
		override protected function setLightId(lightId : uint) : void
		{
			_lightId = lightId;
			
			_dataDescriptor = new Object();
			
			_dataDescriptor['lightType' + lightId]		= 'type';
			_dataDescriptor['lightColor' + lightId]		= 'color';
			_dataDescriptor['lightGroup' + lightId]		= 'group';
			_dataDescriptor['lightAmbient' + lightId]	= 'ambient';
			
			_lightId = lightId;
		}
		
		override public function clone(cloneControllers:Boolean=false):ISceneNode
		{
			var light : AmbientLight = new AmbientLight(
				this.color,
				this.ambient,
				this.group);
			
			light.name = this.name;
			light.transform.copyFrom(this.transform);
			
			return light;
		}
	}
}
