package aerys.minko.scene.node.light
{
	import aerys.minko.scene.data.IWorldData;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.LocalData;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Vector4;

	public class SpotLight extends PointLight
	{
		protected var _direction			: Vector4
		protected var _innerRadius			: Number;
		protected var _outerRadius			: Number;
		

		public function get direction()	: Vector4 
		{
			return _direction; 
		}
		
		public function get innerRadius():Number
		{
			return _innerRadius;
		}
		
		public function get outerRadius():Number
		{
			return _outerRadius;
		}
		
		public function set direction(v : Vector4) : void
		{
			_direction = v;
		}
		
		public function set innerRadius(value:Number):void
		{
			_innerRadius = value;
		}

		public function set outerRadius(value:Number):void
		{
			_outerRadius = value;
		}
		
		public function SpotLight(color				: uint		= 0xFFFFFF,
								  diffusion			: Number	= .6,
								  specular			: Number	= .8,
								  shininess			: Number	= 64,
								  position			: Vector4 	= null,
								  distance			: Number	= 0,
								  direction			: Vector4	= null,
								  outerRadius		: Number	= .4,
								  innerRadius		: Number	= .4,
								  shadowMapSize		: uint		= 0)
		{
			super(color, diffusion, specular, shininess, position, distance);
			
			_direction				= direction || new Vector4(0., 0., 1.);
			_innerRadius			= innerRadius;
			_outerRadius			= outerRadius;
			_shadowMapSize			= shadowMapSize;
		}
		
		override public function getLightData(localData : LocalData) : LightData
		{
			if ((isNaN(_diffuse) || _diffuse == 0) &&
				(isNaN(_specular) || _specular == 0))
				return null;
			
			// compute world space position & direction
			var worldMatrix : Matrix4x4	= localData.world;
			var worldPosition : Vector4 = worldMatrix.multiplyVector(_position);
			var worldDirection: Vector4 = worldMatrix.deltaMultiplyVector(_direction).normalize();
			
			var ld : LightData = LIGHT_DATA.create(true) as LightData;
			
			ld.reset();
			ld.type				= LightData.TYPE_SPOT;
			ld.position			= worldPosition;
			ld.direction		= worldDirection;
			ld.color			= _color;
			ld.outerRadius		= _outerRadius;
			ld.distance			= _distance;
			ld.diffuse			= _diffuse;
			ld.specular			= _specular;
			ld.shininess		= _shininess;
			ld.innerRadius		= _innerRadius;
			ld.shadowMapSize	= _shadowMapSize;
			
			return ld;
		}
	}
}