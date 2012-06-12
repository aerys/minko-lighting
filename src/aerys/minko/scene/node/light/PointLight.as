package aerys.minko.scene.node.light
{
	import aerys.minko.render.resource.texture.CubeTextureResource;
	import aerys.minko.render.resource.texture.ITextureResource;
	import aerys.minko.render.resource.texture.TextureResource;
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.scene.node.Scene;
	import aerys.minko.type.data.DataBindings;
	import aerys.minko.type.enum.ShadowMappingType;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Vector4;

	public class PointLight extends AbstractLight
	{
		public static const TYPE : uint = 2;
		
		private static const MAP_NAMES : Vector.<String> = new <String>[
			'shadowMapCube',
			'shadowMapDualParaboloid0',
			'shadowMapDualParaboloid1'
		];
		
		private static const TMP_VECTOR		: Vector4 = new Vector4();
		
		private static const FRUSTUM_POINTS	: Vector.<Vector4>	= new <Vector4>[
			new Vector4(-1, -1, 0, 1),
			new Vector4(-1, -1, 1, 1),
			new Vector4(-1, +1, 0, 1),
			new Vector4(-1, +1, 1, 1),
			new Vector4(+1, -1, 0, 1),
			new Vector4(+1, -1, 1, 1),
			new Vector4(+1, +1, 0, 1),
			new Vector4(+1, +1, 1, 1)
		];
		
		private var _worldPosition	: Vector4;
		private var _projection		: Matrix4x4;
		
		public function get diffuse() : Number
		{
			return getProperty('diffuse') as Number;
		}
		
		public function get specular() : Number
		{
			return getProperty('specular') as Number;
		}
		
		public function get shininess() : Number
		{
			return getProperty('shininess') as Number;
		}
		
		public function get attenuationDistance() : Number
		{
			return getProperty('attenuationDistance') as Number;
		}
		
		public function set diffuse(v : Number)	: void
		{
			setProperty('diffuse', v);
			
			if (getProperty('diffuseEnabled') != (v != 0))
				setProperty('diffuseEnabled', v != 0);
		}
		
		public function set specular(v : Number) : void
		{
			setProperty('specular', v);
			
			if (getProperty('specularEnabled') != (v != 0))
				setProperty('specularEnabled', v != 0);
		}
		
		public function set shininess(v : Number) : void
		{
			setProperty('shininess', v);
		}
		
		public function set attenuationDistance(v : Number) : void
		{
			setProperty('attenuationDistance', v);
			
			if (getProperty('attenuationEnabled') != (v != 0))
				setProperty('attenuationEnabled', v != 0);
		}
		
		override public function set shadowCastingType(v : uint) : void
		{
			var shadowMapSize	: uint = this.shadowMapSize;
			var shadowMap		: ITextureResource;
			
			// start by clearing current shadow maps.
			for each (var mapName : String in MAP_NAMES)
			{
				shadowMap = getProperty(mapName) as ITextureResource;
				if (shadowMap !== null)
				{
					shadowMap.dispose();
					removeProperty(mapName);
				}
			}
			
			switch (v)
			{
				case ShadowMappingType.NONE:
					setProperty('shadowCastingType', ShadowMappingType.NONE);
					break;
				
				case ShadowMappingType.DUAL_PARABOLOID:
					if (!((shadowMapSize & (~shadowMapSize + 1)) == shadowMapSize
						&& shadowMapSize <= 2048))
						throw new Error(shadowMapSize + ' is an invalid size for dual paraboloid shadow maps');
					
					// set textures and shadowmaptype
					shadowMap = new TextureResource(shadowMapSize, shadowMapSize);
					setProperty('shadowMapDPFront', shadowMap);
					shadowMap = new TextureResource(shadowMapSize, shadowMapSize);
					setProperty('shadowMapDPBack', shadowMap);
					setProperty('shadowCastingType', ShadowMappingType.DUAL_PARABOLOID);
					break;
				
				case ShadowMappingType.CUBE:
					if (!((shadowMapSize & (~shadowMapSize + 1)) == shadowMapSize
						&& shadowMapSize <= 1024))
						throw new Error(shadowMapSize + ' is an invalid size for cubic shadow maps');
					
					shadowMap = new CubeTextureResource(shadowMapSize);
					setProperty('shadowMapCube', shadowMap);
					setProperty('shadowCastingType', ShadowMappingType.CUBE);
					break;
				
				default: 
					throw new ArgumentError('Invalid shadow casting type.');
			}
		}
				
		public function PointLight(color				: uint		= 0xFFFFFFFF,
								   diffuse				: Number	= .6,
								   specular				: Number	= .8,
								   shininess			: Number	= 64,
								   attenuationDistance	: Number	= 0,
								   emissionMask			: uint		= 0x1,
								   shadowCastingType	: uint		= 0,
								   shadowMapSize		: uint		= 512)
		{
			_worldPosition				= new Vector4();
			_projection					= new Matrix4x4();				
			
			super(color, emissionMask, shadowCastingType, shadowMapSize, TYPE); 
			
			this.diffuse				= diffuse;
			this.specular				= specular;
			this.shininess				= shininess;
			this.attenuationDistance	= attenuationDistance;
			
			setProperty('worldPosition', _worldPosition);
			setProperty('projection', _projection);
			
			if ([ShadowMappingType.NONE, 
				 ShadowMappingType.DUAL_PARABOLOID, 
				 ShadowMappingType.CUBE].indexOf(shadowCastingType) == -1)
				throw new Error('Invalid ShadowMappingType.');
		}
		
		override protected function addedToSceneHandler(child:ISceneNode, scene:Scene):void
		{
			super.addedToSceneHandler(child, scene);
			
			scene.bindings.addCallback('screenToWorld', cameraScreenToWorldChangedHandler);
		}
		
		override protected function removedFromSceneHandler(child:ISceneNode, scene:Scene):void
		{
			super.removedFromSceneHandler(child, scene);
			
			scene.bindings.removeCallback('screenToWorld', cameraScreenToWorldChangedHandler);
		}
		
		override protected function transformChangedHandler(transform	 : Matrix4x4, 
															propertyName : String) : void
		{
			super.transformChangedHandler(transform, propertyName);
			
			localToWorld.getTranslation(_worldPosition);
		}
		
		private function cameraScreenToWorldChangedHandler(dataBindings : DataBindings,
														   propertyName	: String,
														   newValue		: Matrix4x4) : void
		{
			if (!(root is Scene))
				return;
			
			var screenToWorld	: Matrix4x4 = 
				Scene(root).bindings.getProperty('screenToWorld') as Matrix4x4;
			
			if (screenToWorld == null)
			{
				// No camera on scene, we cannot compute a valid projection matrix.
				// For now we default to identity
				_projection.identity();
			}
			else
			{
				var lightWorldPosition	: Vector4	= localToWorld.getTranslation();
				var zNear				: Number	= Number.MAX_VALUE;
				var zFar				: Number	= Number.MIN_VALUE;
				
				// create bounding box in light space of view frustum, but do not consider light rotation
				for (var pointId : uint = 0; pointId < 8; ++pointId)
				{
					screenToWorld.transformVector(FRUSTUM_POINTS[pointId], TMP_VECTOR);
					TMP_VECTOR.scaleBy(1 / TMP_VECTOR.w);
					worldToLocal.transformVector(TMP_VECTOR, TMP_VECTOR);
					
					var squaredDistance : Number = TMP_VECTOR.lengthSquared;
					zFar < squaredDistance  && (zFar  = squaredDistance);
				}
				
				zNear	= 0.1;
				zFar	= Math.sqrt(zFar);
				
				// if attenuation is enabled, at d = distance * 10, 
				// we can only see 1% of the light emitted, so we can lower the zFar
				var attenuationEnabled	: Boolean	= getProperty('attenuationEnabled');
				var attenuationDistance	: Number	= this.attenuationDistance;
				
				if (attenuationEnabled && zFar > 10 * attenuationDistance)
					zFar = 10 * attenuationDistance;
				
				var fd	: Number = 1. / Math.tan(Math.PI / 4);
				var m33	: Number = 1. / (zFar - zNear);
				var m43	: Number = -zNear / (zFar - zNear);
				
				setProperty('zNear', zNear);
				setProperty('zFar', zFar);
				_projection.initialize(fd, 0, 0, 0, 0, fd, 0, 0, 0, 0, m33, 1, 0, 0, m43, 0);
			}
		}
		
		override public function clone(cloneControllers : Boolean = false) : ISceneNode
		{
			var light : PointLight = new PointLight(
				color, diffuse, specular, shininess, 
				attenuationDistance, emissionMask, 
				shadowCastingType, shadowMapSize
			);		
			
			light.name = this.name;
			light.transform.copyFrom(this.transform);
			
			return light;
		}
	}
}
