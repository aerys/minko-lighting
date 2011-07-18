package aerys.minko.scene.node.light
{
	import aerys.minko.scene.node.IScene;
	import aerys.minko.scene.node.IWorldObject;

	public interface ILight extends IScene, IWorldObject
	{
		function get color() : uint;
	}
}
