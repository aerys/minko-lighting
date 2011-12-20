package aerys.minko.scene.node.reflection
{
	import aerys.minko.scene.action.ReflectionSurfaceAction;
	import aerys.minko.scene.node.AbstractScene;
	import aerys.minko.scene.node.ITransformableScene;
	import aerys.minko.scene.node.mesh.IMesh;
	import aerys.minko.scene.node.mesh.modifier.NormalMeshModifier;
	import aerys.minko.scene.node.mesh.primitive.QuadMesh;
	import aerys.minko.type.math.Matrix4x4;
	
	public class ReflectionSurface extends AbstractScene implements ITransformableScene
	{
		public function get size() : uint
		{
			return _size;
		}
		
		public function get transform() : Matrix4x4
		{
			return _transform;
		}
		
		public function get mesh() : IMesh
		{
			return _mesh;
		}
		
		public function set mesh(v : IMesh) : void
		{
			_mesh = v;
		}
		
		private var _size		: uint;
		private var _mesh		: IMesh;
		private var _transform	: Matrix4x4;
		
		public function ReflectionSurface(size : uint)
		{
			super();
			
			actions.push(ReflectionSurfaceAction.reflectionSurfaceAction);
			
			_mesh		= new NormalMeshModifier(QuadMesh.doubleSidedQuadMesh);
			_size		= size;
			_transform	= new Matrix4x4();
		}
	}
}
