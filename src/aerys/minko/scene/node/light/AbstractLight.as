package aerys.minko.scene.node.light
{
	import aerys.minko.scene.action.LightAction;
	import aerys.minko.scene.action.transform.PopTransformAction;
	import aerys.minko.scene.action.transform.PushTransformAction;
	import aerys.minko.scene.node.AbstractScene;
	import aerys.minko.scene.node.ITransformableScene;
	import aerys.minko.type.math.Matrix4x4;
	
	public class AbstractLight extends AbstractScene implements ITransformableScene
	{
		protected var _transform	: Matrix4x4;
		protected var _color		: uint;
		protected var _group		: uint;
		
		public function get transform() : Matrix4x4	{ return _transform; }
		public function get color()	: uint	{ return _color; }
		public function get group() : uint	{ return _group; }
		
		public function set color(v : uint) : void 	{ _color = v; }
		public function set group(v : uint) : void	{ _group = v; }
		
		public function AbstractLight(color : uint, group : uint)
		{
			_color		= color;
			_group		= group;
			_transform	= new Matrix4x4();
			
			actions.push(
				PushTransformAction.pushTransformAction,
				LightAction.lightAction,
				PopTransformAction.popTransformAction
			);
		}
	}
}
