package aerys.minko.scene.node.light
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.effect.lighting.offscreen.MatrixShadowMapPass;
	import aerys.minko.render.resource.texture.TextureResource;
	import aerys.minko.scene.node.Camera;
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.scene.node.Scene;
	import aerys.minko.type.data.DataBindings;
	import aerys.minko.type.data.IDataProvider;
	import aerys.minko.type.enum.ShadowMappingType;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Vector4;

	use namespace minko_lighting;
	
	public class SpotLight extends AbstractLight
	{
		public static const TYPE : uint = 4;
		
		private static const Z_AXIS : Vector4 = new Vector4(0, 0, 1);
		
		// light definition
		private var _diffuse				: Number;
		private var _specular				: Number;
		private var _shininess				: Number;
		private var _attenuationDistance				: Number;
		private var _innerRadius			: Number;
		private var _outerRadius			: Number;
		
		private var _shadowMap				: TextureResource;
		private var _depthMapShader			: MatrixShadowMapPass;
		
		// cached values
		private var _camera					: Camera;
		
		// computed values
		private var _worldPosition			: Vector4;
		private var _worldDirection			: Vector4;
		private var _projection				: Matrix4x4;
		private var _worldToScreen			: Matrix4x4;
		
		override public function get type() : uint
		{
			return TYPE;
		}
		
		override public function get shadowCastingType() : uint
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
		
		public function get attenuationDistance() : Number
		{
			return _attenuationDistance;
		}
		
		public function get attenuationEnabled() : Boolean
		{
			return _attenuationDistance != 0;
		}
		
		public function get innerRadius() : Number
		{
			return _innerRadius;
		}
		
		public function get outerRadius() : Number
		{
			return _outerRadius;
		}
		
		public function get shadowMap() : TextureResource
		{
			return _shadowMap;
		}
		
		public function get worldPosition() : Vector4
		{
			return _worldPosition;
		}
		
		public function get worldDirection() : Vector4
		{
			return _worldDirection;
		}
		
		public function get worldToLightScreen() : Matrix4x4
		{
			return _worldToScreen;
		}
		
		public function get projection() : Matrix4x4
		{
			return _projection;
		}
		
		public function set attenuationDistance(v : Number) : void
		{
			_attenuationDistance = v;
			
			if (!_locked)
				changed.execute(this, 'distance');
		}
		
		public function set diffuse(v : Number) : void
		{
			_diffuse = v;
			
			if (!_locked)
				changed.execute(this, 'diffuse');
		}
		
		public function set specular(v : Number) : void
		{
			_specular = v;
			
			if (!_locked)
				changed.execute(this, 'specular');
		}
		
		public function set shininess(v : Number) : void
		{
			_shininess = v;
			
			if (!_locked)
				changed.execute(this, 'shininess');
		}
		
		public function set innerRadius(v : Number) : void
		{
			_innerRadius = v; 
			
			if (!_locked)
				changed.execute(this, 'innerRadius'); 
		}
		
		public function set outerRadius(v : Number) : void
		{
			_outerRadius = v;
			
			if (!_locked)
				changed.execute(this, 'outerRadius');
		}
		
		public function set shadowMapSize(v : uint) : void
		{
			// disable shadow mapping
			if (_shadowMap)
			{
				_shadowMap.dispose();
				_shadowMap		= null;
				_depthMapShader	= null;
			}
			
			if (v == 0)
			{
				// do nothing
			}
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
		
		public function SpotLight(color			: uint		= 0xFFFFFF,
								  diffuse		: Number	= .6,
								  specular		: Number	= .8,
								  shininess		: Number	= 64,
								  distance		: Number	= 0,
								  outerRadius	: Number	= .4,
								  innerRadius	: Number	= .4,
								  group			: uint		= 0x1,
								  shadowMapSize	: uint		= 0)
		{
			super(color, group);
			
			_locked = true;
			
			this.attenuationDistance	= distance;
			this.diffuse				= diffuse;
			this.specular				= specular;
			this.shininess				= shininess;
			this.innerRadius			= innerRadius;
			this.outerRadius			= outerRadius;
			this.shadowMapSize			= shadowMapSize;
			
			_locked = false;
		}
		
		override protected function addedToSceneHandler(child : ISceneNode, scene : Scene) : void
		{
			super.addedToSceneHandler(child, scene);
			
			scene.childAdded.add(onChildAddedToScene);
			scene.childRemoved.add(onChildRemovedFromScene);
			
			updateCamera();
		}
		
		override protected function removedFromSceneHandler(child : ISceneNode, scene : Scene) : void
		{
			super.removedFromSceneHandler(child, scene);
			
			scene.childAdded.remove(onChildAddedToScene);
			scene.childRemoved.remove(onChildRemovedFromScene);
			
			updateCamera();
		}
		
		override protected function transformChangedHandler(transform : Matrix4x4, propertyName : String) : void
		{
			super.transformChangedHandler(transform, propertyName);
			
			_worldPosition	= localToWorld.getTranslation(_worldPosition);
			_worldDirection	= localToWorld.deltaTransformVector(Z_AXIS, _worldDirection);
			_worldDirection.normalize();
			
			if (_projection != null)
				_worldToScreen	= Matrix4x4.multiply(projection, worldToLocal, _worldToScreen);
		}
		
		private function onChildAddedToScene(scene : Scene, child : ISceneNode) : void
		{
			if (child is Camera)
				updateCamera();
		}
		
		private function onChildRemovedFromScene(scene : Scene, child : ISceneNode) : void
		{
			if (child == _camera)
				updateCamera();
		}
		
		private function updateCamera() : void
		{
			if (_camera)
			{
				_camera.changed.remove(onCameraChange);
				_camera.transform.changed.remove(onCameraChange);
				_camera = null;
			}
			
			if (root is Scene)
			{
				var scene : Scene = Scene(root);
				if (scene != null)
				{
					var cameras : Vector.<ISceneNode> = scene.getDescendantsByType(Camera);
					if (cameras.length != 0)
					{
						_camera = Camera(cameras[0]);
						_camera.changed.add(onCameraChange);
						_camera.transform.changed.add(onCameraChange);
						
						onCameraChange(null, null);
					}
				}
			}
		}
		
		private function onCameraChange(item : IDataProvider, fieldName : String) : void
		{
			// retrieve camera frustum and transform matrix
			var cameraLocalToWorld	: Matrix4x4			= _camera.localToWorld;
			var cameraFrustumPoints	: Vector.<Vector4>	= _camera.frustum.points;
			
			// compute zNear & zFar, depending on camera frustum
			var tmpVector			: Vector4	= new Vector4();
			var zNear				: Number	= Number.POSITIVE_INFINITY;
			var zFar				: Number	= Number.NEGATIVE_INFINITY;
			
			for (var pointId : uint = 0; pointId < 8; ++pointId)
			{
				// transform frustum point to light space
				Vector4.copy(cameraFrustumPoints[pointId], tmpVector);
				cameraLocalToWorld.transformVector(tmpVector, tmpVector);
				worldToLocal.transformVector(tmpVector, tmpVector);
				
				// compare to current zFar and zNear
				var frustumDepth : Number = tmpVector.z;
				
				if (frustumDepth > zFar)
					zFar = tmpVector.z;
				
				if (frustumDepth < zNear)
					zNear = tmpVector.z;
			}
			
			// if attenuation is enabled, at d = distance * 10, 
			// we can only see 1% of the light emitted, so we can lower the zFar
			if (_attenuationDistance != 0 && zFar > _attenuationDistance * 10)
				zFar = _attenuationDistance * 10;
			
			// we enforce a maximal factor of 10000 between the 2 values, 
			// to avoid having too little precision (as the cost of losing shadows near the light)
			if (zNear * 10000 < zFar)
				zNear = zFar / 10000;
			
			// update world to screen and projection
			_projection = Matrix4x4.perspectiveFoV(_outerRadius, 1, zNear, zFar, _projection);
			_worldToScreen = Matrix4x4.multiply(_projection, worldToLocal, _worldToScreen);
		}
		
		override protected function setLightId(lightId : uint) : void
		{
			_dataDescriptor = new Object();
			
			_dataDescriptor['lightType' + lightId]					= 'type';
			_dataDescriptor['lightGroup' + lightId]					= 'group';
			_dataDescriptor['lightColor' + lightId]					= 'color';
			
			_dataDescriptor['lightDiffuse' + lightId]				= 'diffuse';
			_dataDescriptor['lightDiffuseEnabled' + lightId]		= 'diffuseEnabled';
			_dataDescriptor['lightSpecular' + lightId]				= 'specular';
			_dataDescriptor['lightSpecularEnabled' + lightId]		= 'specularEnabled';
			_dataDescriptor['lightShininess' + lightId]				= 'shininess';
			_dataDescriptor['lightAttenuationDistance' + lightId]	= 'attenuationDistance';
			_dataDescriptor['lightAttenuationEnabled' + lightId]	= 'attenuationEnabled';
			
			_dataDescriptor['lightInnerRadius' + lightId]			= 'innerRadius';
			_dataDescriptor['lightOuterRadius' + lightId]			= 'outerRadius';
			
			_dataDescriptor['lightShadowCastingType' + lightId]		= 'shadowCastingType';
			_dataDescriptor['lightWorldPosition' + lightId]			= 'worldPosition';
			_dataDescriptor['lightWorldDirection' + lightId]		= 'worldDirection';
			_dataDescriptor['lightWorldToLight' + lightId]			= 'worldToLocal';
			_dataDescriptor['lightWorldToLightScreen' + lightId]	= 'worldToLightScreen';
		}
	}
}
