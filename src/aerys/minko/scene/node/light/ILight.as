package aerys.minko.scene.node.light
{
	import aerys.minko.scene.data.IWorldData;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.TransformData;
	import aerys.minko.scene.node.IScene;

	public interface ILight extends IScene
	{
		function get color() : uint;
		
		function getLightData(transformData : TransformData) : LightData;
	}
}
