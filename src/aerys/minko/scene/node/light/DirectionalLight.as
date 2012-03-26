package aerys.minko.scene.node.light
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.effect.lighting.offscreen.MatrixShadowMapPass;
	import aerys.minko.render.resource.texture.TextureResource;
	import aerys.minko.scene.node.Scene;
	import aerys.minko.type.data.DataBindings;
	import aerys.minko.type.enum.ShadowMappingType;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Vector4;

	use namespace minko_lighting;
	
	public class DirectionalLight extends AbstractLight
	{
		public static const TYPE : uint = 2;
		
		private static const Z_AXIS : Vector4 = new Vector4(0, 0, 1);
		
		protected var _diffuse			: Number;
		protected var _specular			: Number;
		protected var _shininess		: Number;
		
		protected var _direction		: Vector4;
		protected var _worldDirection	: Vector4;
		
		protected var _shadowMap		: TextureResource;
		protected var _depthMapShader	: MatrixShadowMapPass;
		
		override public function get type()					: uint
		{
			return TYPE;
		}
		
		override public function get shadowCastingType()	: uint
		{
			return _shadowMap != null ? ShadowMappingType.MATRIX : ShadowMappingType.NONE;
		}
		
		minko_lighting function get depthMapShader() : MatrixShadowMapPass
		{
			return _depthMapShader;
		}
		
		public function get diffuse() : Number
		{
			return _diffuse;
		}
		
		public function get diffuseEnabled() : Boolean
		{
			return _diffuse != 0;
		}
		
		public function get specular() : Number
		{
			return _specular;
		}
		
		public function get specularEnabled() : Boolean
		{
			return _specular != 0;
		}
		
		public function get shininess() : Number
		{
			return _shininess;
		}
		
		public function get shadowMap() : TextureResource
		{
			return _shadowMap;
		}
		
		public function get direction() : Vector4
		{
			return _direction;
		}
		
		public function get worldDirection() : Vector4
		{
			return _worldDirection;
		}
		
		//		public function get projection() : Matrix4x4
		//		{
		//			var cameraData	: CameraData		= _worldData[CameraData];
		//			var frustum 	: Frustum			= cameraData.frustrum;
		//			var points		: Vector.<Vector4>	= frustum.points;
		//			
		//			var zNear		: Number			= Number.POSITIVE_INFINITY;
		//			var zFar		: Number			= Number.NEGATIVE_INFINITY;
		//			var left		: Number			= Number.POSITIVE_INFINITY;
		//			var right		: Number			= Number.NEGATIVE_INFINITY;
		//			var bottom		: Number			= Number.POSITIVE_INFINITY;
		//			var top			: Number			= Number.NEGATIVE_INFINITY;
		//			
		//			for (var pointId : uint = 0; pointId < 8; ++pointId)
		//			{
		//				Vector4.copy(points[pointId], TMP_VECTOR);
		//				CameraData(_worldData[CameraData]).viewToWorld.transformVector(TMP_VECTOR, TMP_VECTOR);
		//				worldToLight.transformVector(TMP_VECTOR, TMP_VECTOR);
		//				
		//				(TMP_VECTOR.x > right)	&& (right	= TMP_VECTOR.x);
		//				(TMP_VECTOR.x < left)	&& (left	= TMP_VECTOR.x);
		//				(TMP_VECTOR.y > top)	&& (top		= TMP_VECTOR.y);
		//				(TMP_VECTOR.y < bottom)	&& (bottom	= TMP_VECTOR.y);
		//				(TMP_VECTOR.z > zFar)	&& (zFar	= TMP_VECTOR.z);
		//				(TMP_VECTOR.z < zNear)	&& (zNear	= TMP_VECTOR.z);
		//			}
		//			
		//			Matrix4x4.orthoOffCenterLH(left, right, bottom, top, zNear, zFar, _projection);
		//		}
		
		
		public function set diffuse(v : Number)	: void
		{
			var oldDiffuse : Number = _diffuse;
			
			_diffuse = v;
			
			if (!_locked)
			{
				changed.execute(this, 'diffuse');
				if ((oldDiffuse == 0 && _diffuse != 0) ||
					(oldDiffuse != 0 && _diffuse == 0))
					changed.execute(this, 'specularEnabled');
			}
		}
		
		public function set specular(v : Number) : void
		{
			var oldSpecular : Number = _specular;
			
			_specular = v;
			
			if (!_locked)
			{
				changed.execute(this, 'specular');
				if ((oldSpecular == 0 && _specular != 0) ||
					(oldSpecular != 0 && _specular == 0))
					changed.execute(this, 'specularEnabled');
			}
		}
		
		public function set shininess(v : Number) : void
		{
			_shininess = v;
			
			if (!_locked)
				changed.execute(this, 'shininess');
		}
		
		public function set shadowMapSize(v : uint) : void
		{
			// disable shadow mapping
			if (v == 0)
			{
				_depthMapShader = null;
				
				if (_shadowMap)
				{
					_shadowMap.dispose();
					_shadowMap = null;
				}
			}
			// enable shadow mapping
			else if ((v & (~v + 1)) == v && v <= 2048)
			{
				_shadowMap = new TextureResource()
				_shadowMap.setSize(v, v);
				
				_depthMapShader = 
					new MatrixShadowMapPass(_lightId, 0, new RenderTarget(v, v, _shadowMap));
			}
			else
			{
				throw new ArgumentError('Invalid shadow map size. Must be either 0 to disable shadows,' +
					' or power of 2 lesser than 2048');
			}
		}
		
		public function DirectionalLight(color			: uint		= 0xFFFFFF,
									 	 diffuse		: Number	= .6,
										 specular		: Number	= .8,
										 shininess		: Number	= 64,
										 group			: uint		= 0x1,
										 shadowMapSize	: uint		= 0)
		{
			_locked = true;
			
			super(color, group);
			
			this.diffuse		= diffuse;
			this.specular		= specular;
			this.shininess		= shininess;
			this.shadowMapSize	= shadowMapSize;
			
			// update transform dependant variables.
			// is this done properly for abstractscenenode? (ie, not
			// waiting the first modification to update 
			// localToWorld/worldToLocal, but also do it on 
			// construction and added)
			transformChangedHandler(transform, null);
			
			_locked = false;
		}
		
		override protected function transformChangedHandler(transform		: Matrix4x4, 
															propertyName	: String) : void
		{
			super.transformChangedHandler(transform, propertyName);
			
			_direction		= transform.deltaTransformVector(Z_AXIS, _direction);
			_worldDirection	= localToWorld.deltaTransformVector(Z_AXIS, _worldDirection);
			
			_direction.normalize();
			_worldDirection.normalize();
		}
		
		override protected function setLightId(lightId : uint) : void
		{
			_lightId = lightId;
			
			_dataDescriptor = new Object();
			
			_dataDescriptor['lightGroup' + lightId]				= 'group';
			_dataDescriptor['lightColor' + lightId]				= 'color';
			_dataDescriptor['lightType' + lightId]				= 'type'; 
			_dataDescriptor['lightDiffuseEnabled' + lightId]	= 'diffuseEnabled';
			_dataDescriptor['lightDiffuse' + lightId]			= 'diffuse';
			_dataDescriptor['lightSpecularEnabled' + lightId]	= 'specularEnabled';
			_dataDescriptor['lightSpecular' + lightId]			= 'specular';
			_dataDescriptor['lightShininess' + lightId]			= 'shininess';
			_dataDescriptor['lightShadowCastingType' + lightId]	= 'shadowCastingType';
			
			_dataDescriptor['lightDirection' + lightId]			= 'direction';
			_dataDescriptor['lightWorldDirection' + lightId]	= 'worldDirection';
		}
	}
}
