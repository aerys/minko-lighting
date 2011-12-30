package aerys.minko.scene.data
{
	import aerys.minko.ns.minko_reflection;
	import aerys.minko.type.math.ConstVector4;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Plane;
	import aerys.minko.type.math.Vector4;
	
	import flash.geom.Matrix3D;
	import flash.utils.Dictionary;
	
	use namespace minko_reflection;
	
	public class ReflectionData implements IWorldData
	{
		private static const TMP_VECTOR		: Vector4	= new Vector4();
		private static const SCREEN_TO_UV	: Matrix4x4	= new Matrix4x4(
			0.5,		0.0,		0.0,	0.0,
			0.0, 		-0.5,		0.0,	0.0,
			0.0,		0.0,		1.0,	0.0,
			0.5, 		0.5,		0.0, 	1.0
		);
		
		private var _transformData			: TransformData;
		private var _worldData				: Dictionary;
		private var _styleStack				: StyleData;
		
		/////////////////////////////////////////////////////////////////
		// Reflection definition
		/////////////////////////////////////////////////////////////////
		
		public static const SIZE	: String = 'size';
		public static const PLANE	: String = 'plane';
		
		private var _type			: uint;
		private var _size			: uint;
		private var _plane			: Plane;
		
		public function get type()	: int	{ return _type;		}
		public function get size()	: uint	{ return _size;		}
		public function get plane()	: Plane	{ return _plane;	}
		
		minko_reflection function set type(v : int)	 : void { _type = v; }
		minko_reflection function set size(v : uint) : void { _size = v; }
		
		/////////////////////////////////////////////////////////////////
		// Reflection computed data
		/////////////////////////////////////////////////////////////////
		
		public static const WORLD_TO_VIEW	: String = 'worldToView';
		public static const LOCAL_TO_VIEW	: String = 'localToView';
		public static const LOCAL_TO_SCREEN	: String = 'localToScreen';
		public static const LOCAL_TO_UV		: String = 'localToUv';
		public static const LOCAL_TO_PLANE	: String = 'localToPlane';
		public static const CAMERA_SIDE		: String = 'cameraSide';
		
		private var _worldToView	: Matrix4x4;
		private var _localToView	: Matrix4x4;
		private var _localToScreen	: Matrix4x4;
		private var _screenToUv		: Matrix4x4;
		private var _localToUv		: Matrix4x4;
		private var _localToPlane	: Matrix4x4;
		
		public function get worldToView() : Matrix4x4
		{
			var camData	: CameraData = CameraData(_worldData[CameraData]);
			
			var rCamPos : Vector4 = _plane.reflect(camData.position);
			var rCamDir : Vector4 = _plane.deltaReflect(camData.direction);
			var rCamUp	: Vector4 = _plane.deltaReflect(camData.up);
			
			rCamDir.add(rCamPos);
			
			return Matrix4x4.lookAtLH(rCamPos, rCamDir, rCamUp, _worldToView);
		}
		
		public function get localToView() : Matrix4x4
		{
			var localToWorld : Matrix4x4 = _transformData.localToWorld;
			Matrix4x4.multiply(worldToView, localToWorld, _localToView);
			
			return _localToView;
		}
		
		public function get projection() : Matrix4x4
		{
			var camData	: CameraData = CameraData(_worldData[CameraData]);
			return camData.projection;
		}
		
		public function get localToScreen() : Matrix4x4
		{
			Matrix4x4.multiply(projection, localToView, _localToScreen);
			return _localToScreen;
		}
		
		public function get localToUv() : Matrix4x4
		{
			Matrix4x4.multiply(SCREEN_TO_UV, localToScreen, _localToUv);
			return _localToUv;
		}
		
		public function get worldToPlane() : Matrix4x4
		{
			var planeOrigin : Vector4 = new Vector4(_plane.a * _plane.d, _plane.b * _plane.d, _plane.c * _plane.d);
			var planeDirection : Vector4 = new Vector4(_plane.a, _plane.b, _plane.c);
			
			planeDirection.add(planeOrigin);
			return Matrix4x4.lookAtLH(planeOrigin, planeDirection, ConstVector4.Y_AXIS);
		}
		
		public function get localToPlane() : Matrix4x4
		{
			var localToWorld : Matrix4x4 = _transformData.localToWorld;
			Matrix4x4.multiply(worldToPlane, localToWorld, _localToPlane);
			
			return _localToPlane;
		}
		
		public function get cameraSide() : Number
		{
			var camData	: CameraData	= CameraData(_worldData[CameraData]);
			var camPos	: Vector4		= camData.position;
			
			var newCamPos	: Vector4		= worldToPlane.transformVector(camPos);
			
			return newCamPos.z;
		}
		
		public function ReflectionData()
		{
			_plane			= new Plane();
			_worldToView	= new Matrix4x4();
			_localToView	= new Matrix4x4();
			_localToScreen	= new Matrix4x4();
			_screenToUv		= new Matrix4x4();
			_localToUv		= new Matrix4x4();
			_localToPlane	= new Matrix4x4();
		}
		
		public function setDataProvider(styleStack		: StyleData, 
										transformData	: TransformData, 
										worldData		: Dictionary) : void
		{
			_transformData	= transformData;
			_worldData		= worldData;
			_styleStack		= styleStack;
		}
		
		public function invalidate() : void
		{
		}
		
		public function reset() : void
		{
		}
	}
}
