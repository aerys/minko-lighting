package aerys.minko.scene.node.reflection
{
	import aerys.minko.scene.node.AbstractScene;
	import aerys.minko.scene.node.ITransformableScene;
	import aerys.minko.type.math.Matrix4x4;
	
	public class ReflectionCenter extends AbstractScene implements ITransformableScene
	{
		private var _transform : Matrix4x4;
		
		public function get transform():Matrix4x4
		{
			return _transform;
		}
		
		public function ReflectionCenter()
		{
			_transform = new Matrix4x4();
		}
		
	}
}