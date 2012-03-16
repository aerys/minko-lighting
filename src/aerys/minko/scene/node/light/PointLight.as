package aerys.minko.scene.node.light
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.render.resource.texture.ITextureResource;
	import aerys.minko.render.shader.ActionScriptShader;
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.scene.node.Scene;
	import aerys.minko.type.data.DataBindings;
	import aerys.minko.type.enum.ShadowMappingType;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Vector4;

	use namespace minko_lighting;
	
	public class PointLight extends AbstractLight
	{
		private static const ZERO : Vector4 = new Vector4(0, 0, 0, 0);
		
		public static const TYPE : uint = 3;
		
		private var _distance			: Number;
		private var _diffuse			: Number;
		private var _specular			: Number;
		private var _shininess			: Number;
		
		private var _shadowMappingType	: uint;
		private var _depthMaps			: Vector.<ITextureResource>;
		private var _depthMapShaders	: Vector.<ActionScriptShader>;
		
		private var _position			: Vector4;
		private var _worldPosition		: Vector4;
		
		override public function get type() : uint
		{
			return TYPE;
		}
		
		override public function get shadowCastingType() : uint
		{
			return _shadowMappingType;
		}
		
		minko_lighting function get depthMaps() : Vector.<ITextureResource>
		{
			return _depthMaps;
		}
		
		minko_lighting function get depthMapShaders() : Vector.<ActionScriptShader>
		{
			return _depthMapShaders;
		}
		
		public function get diffuse() : Number
		{
			return _diffuse;
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
			return _distance;
		}
		
		public function get attenuationEnabled() : Boolean
		{
			return _distance != 0;
		}
		
		public function get position() : Vector4
		{
			return _position;
		}
		
		public function get worldPosition() : Vector4
		{
			return _worldPosition;
		}
		
		public function get diffuseEnabled() : Boolean
		{
			return _diffuse != 0;
		}
		
		
		public function set diffuse(v : Number) : void
		{
			_diffuse = v; 
			changed.execute(this, 'diffuse');
		}
		
		public function set specular(v : Number) : void
		{
			_specular = v;
			changed.execute(this, 'specular');
		}
		
		public function set shininess(v : Number) : void
		{
			_shininess = v;
			changed.execute(this, 'shininess');
		}
		
		public function set attenuationDistance(v : Number) : void
		{
			_distance = v;
			changed.execute(this, 'distance');
		}
		
		public function set shadowCasting(v : uint) : void
		{
			if (v != ShadowMappingType.NONE)
				throw new Error('implement me');
		}
		
		public function set shadowMapSize(v : uint) : void
		{
		}
		
		public function PointLight(color				: uint		= 0xFFFFFF,
								   diffuse				: Number	= .6,
								   specular				: Number	= .8,
								   shininess			: Number	= 64,
								   attenuationDistance	: Number	= 0,
								   group				: uint		= 0x1,
								   shadowMapSize		: uint		= 0,
								   shadowCasting		: uint		= 0)
		{
			super(color, group); 
			
			_locked = true;
			
			this.diffuse				= diffuse;
			this.specular				= specular;
			this.shininess				= shininess;
			this.attenuationDistance	= attenuationDistance;
			this.shadowCasting			= shadowCasting;
			this.shadowMapSize			= shadowMapSize;
			
			
			// update transform dependant variables.
			// is this done properly for abstractscenenode? (ie, not
			// waiting the first modification to update 
			// localToWorld/worldToLocal, but also do it on 
			// construction and added)
			
			transformChangedHandler(transform, null);
			
			_locked = false;
		}
		
		override protected function transformChangedHandler(transform	 : Matrix4x4, 
															propertyName : String) : void
		{
			super.transformChangedHandler(transform, propertyName);
			
			_position		= transform.transformVector(ZERO, _position);
			_worldPosition	= localToWorld.transformVector(ZERO, _worldPosition);
		}
		
		override protected function setLightId(lightId : uint) : void
		{
			_dataDescriptor = new Object();
			
			_dataDescriptor['lightType' + lightId]					= 'type';
			_dataDescriptor['lightGroup' + lightId]					= 'group';
			_dataDescriptor['lightColor' + lightId]					= 'color';
			_dataDescriptor['lightDiffuse' + lightId]				= 'diffuse';
			_dataDescriptor['lightSpecular' + lightId]				= 'specular';
			_dataDescriptor['lightShininess' + lightId]				= 'shininess';
			_dataDescriptor['lightAttenuationDistance' + lightId]	= 'attenuationDistance';
			
			_dataDescriptor['lightDiffuseEnabled' + lightId]		= 'diffuseEnabled';
			_dataDescriptor['lightSpecularEnabled' + lightId]		= 'specularEnabled';
			_dataDescriptor['lightAttenuationEnabled' + lightId]	= 'attenuationEnabled';
			
			_dataDescriptor['lightPosition' + lightId]				= 'position';
			_dataDescriptor['lightWorldPosition' + lightId]			= 'worldPosition';
			_dataDescriptor['lightLightToWorld' + lightId]			= 'localToWorld';
			_dataDescriptor['lightWorldToLight' + lightId]			= 'worldToLocal';
			
			_lightId = lightId;
			changed.execute(this, 'lightId');
			changed.execute(this, 'dataDescriptor');
		}
	}
}
