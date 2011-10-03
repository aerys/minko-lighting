package aerys.minko.scene.data
{
	import aerys.minko.ns.minko;
	import aerys.minko.render.effect.lighting.LightingStyle;
	import aerys.minko.type.math.ConstVector4;
	import aerys.minko.type.math.Frustum;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Vector4;
	
	import flash.utils.Dictionary;
	
	public final class LightData implements IWorldData
	{
		use namespace minko;
		
		private static const TMP_VECTOR						: Vector4 = new Vector4();
		
		// types
		public static const TYPE_DISABLED					: uint = 0x0;
		public static const TYPE_AMBIENT					: uint = 0x1;
		public static const TYPE_DIRECTIONAL				: uint = 0x2;
		public static const TYPE_POINT						: uint = 0x3;
		public static const TYPE_SPOT						: uint = 0x4;
		
		// Data getter names
		public static const TYPE							: String = 'type';
		public static const COLOR							: String = 'color';
		public static const AMBIENT							: String = 'ambient';
		public static const DIFFUSE							: String = 'diffuse';
		public static const SPECULAR						: String = 'specular';
		public static const SHININESS						: String = 'shininess';
		public static const POSITION						: String = 'position';
		public static const DIRECTION						: String = 'direction';
		public static const DISTANCE						: String = 'distance';
		public static const OUTER_RADIUS					: String = 'outerRadius';
		public static const INNER_RADIUS					: String = 'innerRadius';
		
		// Precomputed data getter names
		public static const OUTER_RADIUS_COSINE				: String = 'outerRadiusCosine';
		public static const INNER_RADIUS_COSINE				: String = 'innerRadiusCosine';
		public static const RADIUS_INTERPOLATION_1			: String = 'radiusInterpolation1';
		public static const RADIUS_INTERPOLATION_2			: String = 'radiusInterpolation2';
		public static const RED								: String = 'red';
		public static const GREEN							: String = 'green';
		public static const BLUE							: String = 'blue';
		
		// Local precomputed data getter names
		public static const LOCAL_POSITION					: String = 'localPosition';
		public static const LOCAL_DIRECTION					: String = 'localDirection';
		
		public static const LOCAL_DISTANCE					: String = 'localDistance';
		public static const SQUARE_LOCAL_DISTANCE			: String = 'squareLocalDistance';
		
		public static const PREMULTIPLIED_AMBIENT			: String = 'premultipliedAmbient';
		public static const PREMULTIPLIED_DIFFUSE			: String = 'premultipliedDiffuse';
		public static const PREMULTIPLIED_SPECULAR			: String = 'premultipliedSpecular';
		public static const PREMULTIPLIED_SHININESS			: String = 'premultipliedShininess';
		
		public static const PREMULTIPLIED_AMBIENT_COLOR		: String = 'premultipliedAmbientColor';
		public static const PREMULTIPLIED_DIFFUSE_COLOR		: String = 'premultipliedDiffuseColor';
		public static const PREMULTIPLIED_SPECULAR_COLOR	: String = 'premultipliedSpecularColor';
		
		// Postcomputed data getter names
		public static const VIEW							: String = 'view';
		public static const PROJECTION						: String = 'projection';
		public static const LOCAL_TO_DEPTH					: String = 'localToDepth';
		public static const LOCAL_TO_VIEW					: String = 'localToView';
		public static const LOCAL_TO_SCREEN					: String = 'localToScreen';
		public static const SCREEN_TO_UV					: String = 'screenToUv';
		public static const LOCAL_TO_UV						: String = 'localToUv';
		
		protected var _styleStack			: StyleData;
		protected var _transformData			: TransformData;
		protected var _worldData			: Object;
		
		// Light definition
		minko var _type						: uint	 = 0x0;
		minko var _color					: uint;
		minko var _group					: uint;
		minko var _ambient					: Number;
		minko var _diffuse					: Number;
		minko var _specular					: Number;
		minko var _shininess				: Number;
		minko var _position					: Vector4;
		minko var _distance					: Number;
		minko var _direction				: Vector4;
		minko var _innerRadius				: Number;
		minko var _outerRadius				: Number;
		minko var _shadowMapSize			: uint;
		
		// Local precomputed data
		minko var _localPosition						: Vector4;
		minko var _localPosition_worldInverseVersion	: uint;
		
		minko var _localDirection						: Vector4;
		minko var _localDirection_worldInverseVersion	: uint;
		
		minko var _localDistance						: Number;
		minko var _localDistance_worldInverseVersion	: uint;
		
		minko var _view									: Matrix4x4;
		minko var _view_positionVersion 				: uint;
		minko var _view_directionVersion				: uint;
		
		minko var _localToView							: Matrix4x4;
		minko var _localToView_worldVersion				: uint;
		minko var _localToView_viewVersion				: uint;
		
		minko var _localToDepth							: Vector4;
		minko var _localToDepth_localToViewVersion		: uint;
		
		minko var _localToScreen						: Matrix4x4;
		minko var _localToScreen_localToViewVersion		: uint;
		minko var _localToScreen_projectionVersion 		: uint;
		
		minko var _projection							: Matrix4x4;
		minko var _projection_outerRadius				: Number;
		
		minko var _screenToUv							: Matrix4x4;
		minko var _screenToUv_shadowMapSize				: uint;
		
		minko var _localToUv							: Matrix4x4;
		minko var _localToUv_localToScreenVersion		: uint;
		
		minko var _localAmbientXColor					: Vector4;
		minko var _localDiffuseXColor					: Vector4;
		minko var _localSpecularXColor					: Vector4;
		
		public final function get type() : uint
		{
			return _type;
		}
		
		public final function get color() : uint
		{
			return _color;
		}
		
		public final function get group() : uint
		{
			return _group;
		}
				
		public final function get ambient() : Number
		{
			return _ambient;
		}
		
		public final function get diffuse() : Number
		{
			return _diffuse;
		}
		
		public final function get specular() : Number
		{
			return _specular;
		}
		
		public final function get shininess() : Number
		{
			return _shininess;
		}
		
		public final function get position() : Vector4
		{
			return _position;
		}
		
		public final function get distance() : Number
		{
			return _distance;
		}
		
		public final function get direction() : Vector4
		{
			return _direction;
		}
		
		public final function get innerRadius() : Number
		{
			return _innerRadius;
		}
		
		public final function get outerRadius() : Number
		{
			return _outerRadius;
		}
		
		public final function get innerRadiusCosine() : Number
		{
			return Math.cos(_innerRadius);
		}
		
		public final function get outerRadiusCosine() : Number
		{
			return Math.cos(_outerRadius);
		}
		
		public function get shadowMapSize() : uint 
		{
			return _shadowMapSize;
		}
		
		public final function get red() : Number
		{
			return ((_color >> 16) & 0xFF) / 255.0;
		}
		
		public final function get green() : Number
		{
			return ((_color >> 8) & 0xFF) / 255.0;
		}
		
		public final function get blue() : Number
		{
			return (_color & 0xFF) / 255.0;
		}
		
		public function get castShadows() : Boolean
		{
			return _shadowMapSize != 0;
		}

		public function get premultipliedAmbient() : Number
		{
			return (_styleStack.get(LightingStyle.AMBIENT_MULTIPLIER, 1) as Number) * _ambient;
		}

		public function get premultipliedDiffuse() : Number
		{
			return (_styleStack.get(LightingStyle.DIFFUSE_MULTIPLIER, 1) as Number) * _diffuse;
		}

		public function get premultipliedSpecular() : Number
		{
			return (_styleStack.get(LightingStyle.SPECULAR_MULTIPLIER, 1) as Number) * _specular;
		}

		public function get premultipliedShininess() : Number
		{
			return (_styleStack.get(LightingStyle.SHININESS_MULTIPLIER, 1) as Number) * _shininess;
		}

		public function get localPosition() : Vector4
		{
			var worldInverseMatrix : Matrix4x4 = _transformData.worldInverse;
			
			if (_localPosition_worldInverseVersion != worldInverseMatrix.version)
			{
				_localPosition = worldInverseMatrix.transformVector(_position, _localPosition);
				_localPosition_worldInverseVersion = worldInverseMatrix.version;
			}
			
			return _localPosition;
		}

		public function get localDistance():Number
		{
			var worldInverseMatrix : Matrix4x4 = _transformData.worldInverse;
			
			if (_localDistance_worldInverseVersion != worldInverseMatrix.version)
			{
				TMP_VECTOR.set(_distance, 0, 0, 0);
				worldInverseMatrix.deltaTransformVector(TMP_VECTOR, TMP_VECTOR)
				_localDistance = TMP_VECTOR.length;
			}
			
			return _localDistance;
		}

		public final function get squareLocalDistance() : Number
		{
			var localDistanceValue : Number = localDistance;
			return localDistanceValue * localDistanceValue;
		}

		public function get localDirection():Vector4
		{
			var invertedWorldMatrix : Matrix4x4 = _transformData.worldInverse;
			
			if (_localDirection_worldInverseVersion != invertedWorldMatrix.version)
			{
				_localDirection = invertedWorldMatrix
					.deltaTransformVector(_direction, _localDirection)
					.normalize();
				_localDirection_worldInverseVersion = invertedWorldMatrix.version;
			}
			
			return _localDirection;
		}

		public final function get premultipliedAmbientColor() : Vector4
		{
			var localAmbientValue	: Number = premultipliedAmbient;
			
			_localAmbientXColor ||= new Vector4();
			_localAmbientXColor.set(
				red * localAmbientValue,
				green * localAmbientValue,
				blue * localAmbientValue,
				1
			);
			
			return _localAmbientXColor;
		}
		
		public final function get premultipliedDiffuseColor() : Vector4
		{
			var localDiffuseValue	: Number = premultipliedDiffuse;
			
			_localDiffuseXColor ||= new Vector4();
			_localDiffuseXColor.set(
				red * localDiffuseValue,
				green * localDiffuseValue,
				blue * localDiffuseValue,
				1
			);
			return _localDiffuseXColor;
		}
		
		public final function get premultipliedSpecularColor() : Vector4
		{
			var localSpecularValue	: Number = premultipliedSpecular;
			
			_localSpecularXColor ||= new Vector4();
			_localSpecularXColor.set(
				red * localSpecularValue,
				green * localSpecularValue,
				blue * localSpecularValue,
				1
			);
			
			return _localSpecularXColor;
		}
		
		public final function get radiusInterpolation1() : Number
		{
			var innerRadiusCosineValue : Number = innerRadiusCosine;
			var outerRadiusCosineValue : Number = outerRadiusCosine;
			
			return 1 + (innerRadiusCosineValue / (outerRadiusCosineValue - innerRadiusCosineValue))
		}
		
		public final function get radiusInterpolation2() : Number
		{
			var innerRadiusCosineValue : Number = innerRadiusCosine;
			var outerRadiusCosineValue : Number = outerRadiusCosine;
			
			return 1 / (innerRadiusCosineValue - outerRadiusCosineValue);
		}
		
		public function get view() : Matrix4x4
		{
			if (_view_positionVersion != _position.version ||
				_view_directionVersion != _direction.version)
			{
				var lookAt : Vector4 = new Vector4();
				lookAt.set(_position.x, _position.y, _position.z);
				lookAt.add(_direction);
				
				_view = Matrix4x4.lookAtLH(position, lookAt, ConstVector4.Y_AXIS, _view);
				_view_positionVersion	= _position.version;
				_view_directionVersion	= _direction.version;
			}
			
			return _view;
		}
		
		public function get projection() : Matrix4x4
		{
			if (_projection_outerRadius != _outerRadius)
			{
				_projection = Matrix4x4.perspectiveFoVLH(2 * _outerRadius, 1, 0.1, 100, _projection);
				_projection_outerRadius = _outerRadius;
			}
			
			return _projection;
		}
		
		public function get localToView() : Matrix4x4
		{
			var worldMatrix	: Matrix4x4 = _transformData.world;
			var viewMatrix	: Matrix4x4 = view;
			
			if (_localToView_worldVersion != worldMatrix.version ||
				_localToView_viewVersion != viewMatrix.version)
			{
				_localToView = Matrix4x4.multiply(viewMatrix, worldMatrix, _localToView);
				_localToView_worldVersion	= worldMatrix.version;
				_localToView_viewVersion	= viewMatrix.version;
			}
			
			return _localToView;
		}
		
		/**
		 * fixme, memory leak
		 */
		public function get localToDepth() : Vector4
		{
			var localToViewMatrix : Matrix4x4 = localToView;
			
			if (_localToDepth_localToViewVersion != localToViewMatrix.version)
			{
				var line3 : Vector.<Number> = localToViewMatrix.getRawData(null, 0, false);
				_localToDepth ||= new Vector4();
				_localToDepth.set(line3[8], line3[9], line3[10], line3[11]);
			}
			
			return _localToDepth;
		}
		
		public function get localToScreen() : Matrix4x4
		{
			var localToViewMatrix	: Matrix4x4 = localToView;
			var projectionMatrix	: Matrix4x4 = projection;
			
			if (_localToScreen_localToViewVersion != localToViewMatrix.version ||
				_localToScreen_projectionVersion != projectionMatrix.version)
			{
				_localToScreen = Matrix4x4.multiply(projectionMatrix, localToViewMatrix, _localToScreen);
				_localToScreen_localToViewVersion	= localToViewMatrix.version;
				_localToScreen_projectionVersion	= projectionMatrix.version;
			}
			return _localToScreen;
		}
		
		public function get screentoUv() : Matrix4x4
		{
			if (_screenToUv_shadowMapSize != _shadowMapSize)
			{
				var offset : Number = 0.5 + (0.5 / _shadowMapSize);
				_screenToUv = new Matrix4x4(
					0.5,		0.0,		0.0,	0.0,
					0.0, 		-0.5,		0.0,	0.0,
					0.0,		0.0,		1.0,	0.0,
					offset, 	offset,		0.0, 	1.0
				);
			}
			
			return _screenToUv;
		}
		
		public function get localToUv() : Matrix4x4
		{
			var localToScreenMatrix : Matrix4x4 = localToScreen;
			var screenToUvMatrix	: Matrix4x4 = screentoUv;
			
			if (_localToUv_localToScreenVersion != localToScreenMatrix.version)
			{
				_localToUv = Matrix4x4.multiply(screenToUvMatrix, localToScreenMatrix, _localToUv);
				_localToUv_localToScreenVersion = localToScreenMatrix.version;
			}
			
			return _localToUv;
		}
		
		public final function set type(value:uint):void
		{
			_type = value;
		}
		
		public final function set color(value : uint) : void
		{
			_color	= value;
		}
		
		public final function set group(value : uint) : void
		{
			_group = value;
		}
		
		public final function set ambient(value : Number) : void
		{
			_ambient = value;
		}
		
		public final function set diffuse(value : Number) : void
		{
			_diffuse = value;
		}
		
		public final function set specular(value : Number) : void
		{
			_specular = value;
		}
		
		public final function set shininess(value : Number) : void
		{
			_shininess = value;
		}
		
		public final function set position(value : Vector4) : void
		{
			_position = value;
		}

		public final function set distance(value : Number) : void
		{
			_distance = value;
		}

		public final function set direction(value : Vector4) : void
		{
			_direction = value;
		}

		public final function set innerRadius(value : Number) : void
		{
			_innerRadius = value;
		}
		
		public final function set outerRadius(value : Number) : void
		{
			_outerRadius = value;
		}
		
		public final function set shadowMapSize(v : uint) : void
		{
			_shadowMapSize = v;
		}
		
		public function LightData() 
		{
			reset();
		}
		
		public final function setDataProvider(styleStack	: StyleData,
											  transformData		: TransformData,
											  worldData		: Dictionary) : void
		{
			_styleStack	= styleStack;
			_transformData	= transformData;
			_worldData	= worldData;
		}
		
		public final function invalidate() : void
		{
		}
		
		public final function reset() : void
		{
			var maxUint : uint = uint.MAX_VALUE;
			
			_localPosition_worldInverseVersion	= maxUint;
			_localDirection_worldInverseVersion	= maxUint;
			_localDistance_worldInverseVersion	= maxUint;
			
			_view_positionVersion 				= maxUint;
			_view_directionVersion				= maxUint;
			
			_localToView_worldVersion			= maxUint;
			_localToView_viewVersion			= maxUint;
			
			_localToScreen_localToViewVersion	= maxUint;
			_localToDepth_localToViewVersion	= maxUint;
			_localToScreen_projectionVersion 	= maxUint;
			
			_projection_outerRadius				= maxUint;
			
			_localToUv_localToScreenVersion		= maxUint;
			
			_screenToUv_shadowMapSize			= maxUint;
		}
	}
}