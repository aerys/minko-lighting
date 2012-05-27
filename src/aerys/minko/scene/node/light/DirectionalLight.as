package aerys.minko.scene.node.light
{
	import aerys.minko.render.resource.texture.TextureResource;
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.scene.node.Scene;
	import aerys.minko.type.data.DataBindings;
	import aerys.minko.type.enum.ShadowMappingType;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Vector4;

	/**
	 * @author Romain Gilliotte
	 */
	public class DirectionalLight extends AbstractLight
	{
		public static const TYPE			: uint				= 1;
		
		private static const SCREEN_TO_UV	: Matrix4x4			= new Matrix4x4().appendScale(.5, -.5).appendTranslation(.5, .5);
		private static const Z_AXIS			: Vector4			= new Vector4(0, 0, 1);
		private static const TMP_VECTOR		: Vector4			= new Vector4();
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
		
		private var _position		: Vector4;
		private var _worldPosition	: Vector4;
		private var _direction		: Vector4;
		private var _worldDirection	: Vector4;
		private var _worldToScreen	: Matrix4x4;
		private var _worldToUV		: Matrix4x4;
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
		
		override public function set shadowCastingType(v : uint) : void
		{
			var shadowMapSize	: uint				= this.shadowMapSize;
			var shadowMap		: TextureResource	= getProperty('shadowMap') as TextureResource;
			
			if (shadowMap)
			{
				removeProperty('shadowMap');
				shadowMap.dispose(); 
			}
			
			switch (v)
			{
				case ShadowMappingType.NONE:
					setProperty('shadowCastingType', ShadowMappingType.NONE);
					break;
				
				case ShadowMappingType.MATRIX:
					if (!((shadowMapSize & (~shadowMapSize + 1)) == shadowMapSize
						&& shadowMapSize <= 2048))
						throw new Error(shadowMapSize + ' is an invalid size for a shadow map');
					
					shadowMap = new TextureResource(shadowMapSize, shadowMapSize);
					setProperty('shadowMap', shadowMap);
					setProperty('shadowCastingType', ShadowMappingType.MATRIX);
					break;
				
				default: 
					throw new ArgumentError('Invalid shadow casting type.');
			}
		}
		
		public function DirectionalLight(color			: uint		= 0xFFFFFF,
									 	 diffuse		: Number	= .6,
										 specular		: Number	= .8,
										 shininess		: Number	= 64,
										 emissionMask	: uint		= 0x1,
										 shadowCasting	: uint		= 0,
										 shadowMapSize	: uint		= 512)
		{
			_position			= new Vector4();
			_worldPosition		= new Vector4();
			_direction			= new Vector4();
			_worldDirection		= new Vector4();
			_worldToScreen		= new Matrix4x4();
			_worldToUV			= new Matrix4x4();
			_projection			= new Matrix4x4();
			
			super(color, emissionMask, shadowCasting, shadowMapSize, TYPE);
			
			this.diffuse		= diffuse;
			this.specular		= specular;
			this.shininess		= shininess;
			
			setProperty('position', _position);
			setProperty('worldPosition', _worldPosition);
			setProperty('direction', _direction);
			setProperty('worldDirection', _worldDirection);
			setProperty('worldToScreen', _worldToScreen);
			setProperty('worldToUV', _worldToUV);
			setProperty('projection', _projection);
			
			if ([ShadowMappingType.NONE, 
				ShadowMappingType.MATRIX].indexOf(shadowCasting) == -1)
				throw new Error('Invalid ShadowMappingType.');
		}
		
		override protected function addedToSceneHandler(child:ISceneNode, scene:Scene):void
		{
			super.addedToSceneHandler(child, scene);
			
			scene.bindings.getPropertyChangedSignal('screenToWorld')
						  .add(cameraScreenToWorldChangedHandler);
		}
		
		override protected function removedFromSceneHandler(child:ISceneNode, scene:Scene):void
		{
			super.removedFromSceneHandler(child, scene);
			
			scene.bindings.getPropertyChangedSignal('screenToWorld')
						  .remove(cameraScreenToWorldChangedHandler);
		}
		
		override protected function transformChangedHandler(transform		: Matrix4x4, 
															propertyName	: String) : void
		{
			super.transformChangedHandler(transform, propertyName);
			
			// compute position and world position.
			transform.getTranslation(_position);
			localToWorld.getTranslation(_worldPosition);
			
			// compute direction and world direction.
			_direction		= transform.deltaTransformVector(Z_AXIS, _direction);
			_worldDirection	= localToWorld.deltaTransformVector(Z_AXIS, _worldDirection);
			_direction.normalize();
			_worldDirection.normalize();
			
			// update world to screen/uv
			_worldToScreen.copyFrom(worldToLocal).prepend(_projection);
			_worldToUV.copyFrom(_worldToScreen).prepend(SCREEN_TO_UV);
		}
		
		protected function cameraScreenToWorldChangedHandler(sceneBindings	: DataBindings,
															 propertyName	: String,
															 screenToWorld	: Matrix4x4) : void
		{
			if (screenToWorld == null)
			{
				// No camera on scene, we cannot compute a valid projection matrix.
				// For now we default to identity
				_projection.identity();
			}
			else
			{
				// There is a camera in the scene
				// We convert the frustum into light space, and compute a projection
				// matrix that contains the whole frustum.
				
				var zNear	: Number = Number.POSITIVE_INFINITY;
				var zFar	: Number = Number.NEGATIVE_INFINITY;
				var left	: Number = Number.POSITIVE_INFINITY;
				var right	: Number = Number.NEGATIVE_INFINITY;
				var bottom	: Number = Number.POSITIVE_INFINITY;
				var top		: Number = Number.NEGATIVE_INFINITY;
				
				for (var pointId : uint = 0; pointId < 8; ++pointId)
				{
					screenToWorld.transformVector(FRUSTUM_POINTS[pointId], TMP_VECTOR);
					worldToLocal.transformVector(TMP_VECTOR, TMP_VECTOR);
					
					if (TMP_VECTOR.x > right)	right	= TMP_VECTOR.x;
					if (TMP_VECTOR.x < left)	left	= TMP_VECTOR.x;
					if (TMP_VECTOR.y > top)		top		= TMP_VECTOR.y;
					if (TMP_VECTOR.y < bottom)	bottom	= TMP_VECTOR.y;
					if (TMP_VECTOR.z > zFar)	zFar	= TMP_VECTOR.z;
					if (TMP_VECTOR.z < zNear)	zNear	= TMP_VECTOR.z;
				}
				
				_projection.orthoOffCenter(left, right, bottom, top, zNear, zFar);
			}
			
			_worldToScreen.copyFrom(worldToLocal).prepend(_projection);
			_worldToUV.copyFrom(_worldToScreen).prepend(SCREEN_TO_UV);
		}
		
		override public function clone(cloneControllers : Boolean = false) : ISceneNode
		{
			var light : DirectionalLight = 
				new DirectionalLight(color, diffuse, specular, shininess, emissionMask, shadowMapSize);
			
			light.name = this.name;
			light.transform.copyFrom(this.transform);
			
			return light;
		}
	}
}
