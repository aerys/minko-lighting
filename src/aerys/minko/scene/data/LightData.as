package aerys.minko.scene.data
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.render.effect.lighting.LightingStyle;
	import aerys.minko.render.shader.node.operation.builtin.Multiply4x4;
	import aerys.minko.scene.node.light.AmbientLight;
	import aerys.minko.scene.node.light.ConstDirectionalLight;
	import aerys.minko.scene.node.light.ConstPointLight;
	import aerys.minko.scene.node.light.ConstSpotLight;
	import aerys.minko.type.math.ConstVector4;
	import aerys.minko.type.math.Frustum;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Vector4;
	
	import flash.utils.Dictionary;
	
	use namespace minko_lighting;
	
	/**
	 * This class is able to represent any type of light in worldData.
	 * 
	 * @author Romain Gilliotte <romain.gilliotte@aerys.in>
	 */	
	public final class LightData implements IWorldData
	{
		private static const TMP_VECTOR : Vector4 = new Vector4();
		
		private var _styleStack			: StyleData;
		private var _transformData		: TransformData;
		private var _worldData			: Object;
		
		/////////////////////////////////////////////////////////////////
		// Light definition
		/////////////////////////////////////////////////////////////////
		
		public static const TYPE			: String = 'type';
		public static const GROUP			: String = 'group';
		public static const COLOR			: String = 'color';
		public static const LIGHT_TO_WORLD	: String = 'lightToWorld';
		public static const AMBIENT			: String = 'ambient';
		public static const DIFFUSE			: String = 'diffuse';
		public static const SPECULAR		: String = 'specular';
		public static const SHININESS		: String = 'shininess';
		public static const DISTANCE		: String = 'distance';
		public static const OUTER_RADIUS	: String = 'outerRadius';
		public static const INNER_RADIUS	: String = 'innerRadius';
		
		minko_lighting var _type					: uint;
		minko_lighting var _group					: uint;
		minko_lighting var _color					: uint;
		minko_lighting var _lightToWorld			: Matrix4x4;
		minko_lighting var _ambient					: Number;
		minko_lighting var _diffuse					: Number;
		minko_lighting var _specular				: Number;
		minko_lighting var _shininess				: Number;
		minko_lighting var _distance				: Number;
		minko_lighting var _innerRadius				: Number;
		minko_lighting var _outerRadius				: Number;
		minko_lighting var _shadowMapSize			: uint;
		minko_lighting var _useParaboloidShadows	: Boolean;
		
		public function get type()					: uint		{ return _type;					}
		public function get group()					: uint		{ return _group;				}
		public function get color()					: uint		{ return _color;				}
		public function get lightToWorld()			: Matrix4x4	{ return _lightToWorld;			}
		public function get ambient()				: Number	{ return _ambient;				}
		public function get diffuse()				: Number	{ return _diffuse;				}
		public function get specular()				: Number	{ return _specular;				}
		public function get shininess()				: Number	{ return _shininess;			}
		public function get distance()				: Number	{ return _distance;				}
		public function get innerRadius()			: Number	{ return _innerRadius;			}
		public function get outerRadius()			: Number	{ return _outerRadius;			}
		public function get shadowMapSize()			: uint		{ return _shadowMapSize;		}
		public function get useParaboloidShadows()	: Boolean	{ return _useParaboloidShadows;	}
		
		/////////////////////////////////////////////////////////////////
		// Light computed data (with no cache)
		/////////////////////////////////////////////////////////////////
		
		public static const RED						: String = 'red';
		public static const GREEN					: String = 'green';
		public static const BLUE					: String = 'blue';
		public static const OUTER_RADIUS_COSINE		: String = 'outerRadiusCosine';
		public static const INNER_RADIUS_COSINE		: String = 'innerRadiusCosine';
		public static const RADIUS_INTERPOLATION_1	: String = 'radiusInterpolation1';
		public static const RADIUS_INTERPOLATION_2	: String = 'radiusInterpolation2';
		public static const LOCAL_AMBIENT			: String = 'localAmbient';
		public static const LOCAL_DIFFUSE			: String = 'localDiffuse';
		public static const LOCAL_SPECULAR			: String = 'localSpecular';
		public static const LOCAL_SHININESS			: String = 'localShininess';
		public static const SQUARE_DISTANCE			: String = 'squareDistance';
		public static const LOCAL_DISTANCE			: String = 'localDistance';
		public static const SQUARE_LOCAL_DISTANCE	: String = 'squareLocalDistance';
		
		public function get castShadows()	: Boolean	{ return _shadowMapSize != 0;	}
		
		public function get red()			: Number	{ return ((_color >> 16) & 0xFF) / 255.0;	}
		public function get green() 		: Number	{ return ((_color >> 8) & 0xFF) / 255.0;	}
		public function get blue()			: Number	{ return (_color & 0xFF) / 255.0;			}
		
		public final function get innerRadiusCosine() : Number
		{
			return Math.cos(_innerRadius);	
		}
		
		public final function get outerRadiusCosine() : Number 
		{
			return Math.cos(_outerRadius);	
		}
		
		public final function get radiusInterpolation1() : Number
		{
			return 1 - innerRadiusCosine * radiusInterpolation2;
		}
		
		public final function get radiusInterpolation2() : Number
		{
			return - 1 / (outerRadiusCosine - innerRadiusCosine);
		}
		
		public function get localAmbient() : Number
		{
			return _ambient * Number(_styleStack.get(LightingStyle.AMBIENT_MULTIPLIER, 1));
		}
		
		public function get localDiffuse() : Number
		{
			return _diffuse * Number(_styleStack.get(LightingStyle.DIFFUSE_MULTIPLIER, 1));
		}
		
		public function get localSpecular() : Number
		{
			return _specular * Number(_styleStack.get(LightingStyle.SPECULAR_MULTIPLIER, 1));
		}
		
		public function get localShininess() : Number
		{
			return _shininess * Number(_styleStack.get(LightingStyle.SHININESS_MULTIPLIER, 1));
		}
		
		public function get localDistance() : Number
		{
			return _distance * _lightToWorld.scaleX * _transformData.worldToLocal.scaleX;
		}
		
		public function get squareLocalDistance() : Number
		{
			return Math.pow(localDistance, 2);
		}
		
		/////////////////////////////////////////////////////////////////
		// Light computed Data
		/////////////////////////////////////////////////////////////////
		
		/**
		 * Position & Direction
		 */
		
		public static const POSITION		: String = 'position';
		public static const DIRECTION		: String = 'direction';
		public static const LOCAL_POSITION	: String = 'localPosition';
		public static const LOCAL_DIRECTION	: String = 'localDirection';
		
		private var _position		: Vector4;
		private var _direction		: Vector4;
		private var _localPosition	: Vector4;
		private var _localDirection	: Vector4;
		
		public function get position() : Vector4
		{
			_lightToWorld.transformVector(ConstVector4.ZERO, _position);
			return _position;
		}
		
		public function get localPosition() : Vector4
		{
			_transformData.worldToLocal.transformVector(position, _localPosition);
			return _localPosition;
		}
		
		public function get direction() : Vector4
		{
			_lightToWorld.deltaTransformVector(ConstVector4.Z_AXIS, _direction);
			_direction.normalize();
			return _direction;
		}
		
		public function get localDirection() : Vector4
		{
			_transformData.worldToLocal.deltaTransformVector(direction, _localDirection);
			_localDirection.normalize();
			return _localDirection;
		}
		
		/**
		 * Transformation Matrices
		 */
		
		public static const WORLD_TO_LIGHT	: String = 'worldToLight';
		public static const LOCAL_TO_LIGHT	: String = 'localToLight';

		private var _worldToLight	: Matrix4x4;
		private var _localToLight	: Matrix4x4;

		public function get worldToLight() : Matrix4x4
		{
//			Matrix4x4.invert(_lightToWorld, _worldToLight);
//			return _worldToLight;
			Vector4.add(position, direction, TMP_VECTOR)
			return Matrix4x4.lookAtLH(position, TMP_VECTOR, ConstVector4.Y_AXIS);
		}
		
		public function get localToLight() : Matrix4x4
		{
			Matrix4x4.multiply(worldToLight, _transformData.localToWorld, _localToLight);
			return _localToLight;
		}
		
		/**
		 * Projection Matrices (for shadows)
		 */
		
		public static const PROJECTION		: String = 'projection';
		public static const LOCAL_TO_SCREEN	: String = 'localToScreen';
		public static const SCREEN_TO_UV	: String = 'screenToUv';
		public static const LOCAL_TO_UV		: String = 'localToUv';

		private var _projection		: Matrix4x4;
		private var _localToScreen	: Matrix4x4;
		private var _screenToUv		: Matrix4x4;
		private var _localToUv		: Matrix4x4;
		
		public function get projection() : Matrix4x4
		{
			switch (_type)
			{
				case AmbientLight.TYPE:				throw new Error('Ambient Lights cannot project');
				case ConstDirectionalLight.TYPE:	computeDirectionalProjection(); break;
				case ConstPointLight.TYPE:			throw new Error('Point Lights cannot project');
				case ConstSpotLight.TYPE:			computeSpotProjection(); break;
			}
			
			return _projection;
		}
		
		public function get localToScreen() : Matrix4x4
		{
			Matrix4x4.multiply(projection, localToLight, _localToScreen);
			return _localToScreen;
		}
		
		public function get screentoUv() : Matrix4x4
		{
			var offset : Number = 0.5 + (0.5 / _shadowMapSize);
			
			_screenToUv.identity();
			_screenToUv.appendScale(0.5, -0.5, 1);
			_screenToUv.appendTranslation(offset, offset, 0);
			
			return _screenToUv;
		}
		
		public function get localToUv() : Matrix4x4
		{
			Matrix4x4.multiply(screentoUv, localToScreen, _localToUv);
			return _localToUv;
		}
		
		public function LightData() 
		{
			_ambient		= NaN;
			_color			= NaN;
			_diffuse		= NaN;
			_direction		= new Vector4();
			_distance		= NaN;
			_group			= NaN;
			_innerRadius	= NaN;
			_lightToWorld	= new Matrix4x4();
			_localDirection	= new Vector4();
			_localPosition	= new Vector4();
			_localToLight	= new Matrix4x4();
			_localToScreen	= new Matrix4x4();
			_localToUv		= new Matrix4x4();
			_outerRadius	= NaN;
			_position		= new Vector4();
			_projection		= new Matrix4x4();
			_screenToUv		= new Matrix4x4();
			_shadowMapSize	= NaN;
			_shininess		= NaN;
			_specular		= NaN;
			_type			= NaN;
			_worldToLight	= new Matrix4x4();
		}
		
		public function setDataProvider(styleStack		: StyleData,
										transformData	: TransformData,
										worldData		: Dictionary) : void
		{
			_styleStack		= styleStack;
			_transformData	= transformData;
			_worldData		= worldData;
		}
		
		public function invalidate() : void
		{
		}
		
		public function reset() : void
		{
		}
		
		private function computeDirectionalProjection() : void
		{
			var cameraData	: CameraData		= _worldData[CameraData];
			var frustum 	: Frustum			= cameraData.frustrum;
			var points		: Vector.<Vector4>	= frustum.points;
			
			var zNear		: Number			= Number.POSITIVE_INFINITY;
			var zFar		: Number			= Number.NEGATIVE_INFINITY;
			var left		: Number			= Number.POSITIVE_INFINITY;
			var right		: Number			= Number.NEGATIVE_INFINITY;
			var bottom		: Number			= Number.POSITIVE_INFINITY;
			var top			: Number			= Number.NEGATIVE_INFINITY;
			
			for (var pointId : uint = 0; pointId < 8; ++pointId)
			{
				Vector4.copy(points[pointId], TMP_VECTOR);
				CameraData(_worldData[CameraData]).cameraToWorld.transformVector(TMP_VECTOR, TMP_VECTOR);
				worldToLight.transformVector(TMP_VECTOR, TMP_VECTOR);
				
				(TMP_VECTOR.x > right)	&& (right	= TMP_VECTOR.x);
				(TMP_VECTOR.x < left)	&& (left	= TMP_VECTOR.x);
				(TMP_VECTOR.y > top)	&& (top		= TMP_VECTOR.y);
				(TMP_VECTOR.y < bottom)	&& (bottom	= TMP_VECTOR.y);
				(TMP_VECTOR.z > zFar)	&& (zFar	= TMP_VECTOR.z);
				(TMP_VECTOR.z < zNear)	&& (zNear	= TMP_VECTOR.z);
			}
			
			Matrix4x4.orthoOffCenterLH(left, right, bottom, top, zNear, zFar, _projection);
		}
		
		private function computeSpotProjection() : void
		{
			var viewInverse		: Matrix4x4			= CameraData(_worldData[CameraData]).cameraToWorld;
			var worldToLight	: Matrix4x4			= this.worldToLight;
			
			// compute zNear & zFar, depending on camera frustum
			var points			: Vector.<Vector4>	= _worldData[CameraData].frustum.points;
			var zNear			: Number			= Number.POSITIVE_INFINITY;
			var zFar			: Number			= Number.NEGATIVE_INFINITY;
			
			for (var pointId : uint = 0; pointId < 8; ++pointId)
			{
				Vector4.copy(points[pointId], TMP_VECTOR);
				viewInverse.transformVector(TMP_VECTOR, TMP_VECTOR);
				worldToLight.transformVector(TMP_VECTOR, TMP_VECTOR);
				
				(TMP_VECTOR.z > zFar)	&& (zFar	= TMP_VECTOR.z);
				(TMP_VECTOR.z < zNear)	&& (zNear	= TMP_VECTOR.z);
			}
				
			// if attenuation is enabled, at d = distance * 10, 
			// we can only see 1% of the light emitted, so we can still lower the zFar
			if (_distance != 0 && zFar > _distance * 10)
				zFar = _distance * 10;
			
			// a cone light doesn't see behind.
			if (zNear < 5)
				zNear = 5;
			
			Matrix4x4.perspectiveFoVLH(_outerRadius, 1, zNear, zFar, _projection);
		}
	}
}