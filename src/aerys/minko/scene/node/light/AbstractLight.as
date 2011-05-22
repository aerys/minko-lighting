package aerys.minko.scene.node.light
{
	import aerys.common.Factory;
	import aerys.minko.scene.visitor.data.LightData;
	import aerys.minko.scene.node.AbstractScene;
	import aerys.minko.scene.visitor.data.IWorldData;
	import aerys.minko.scene.visitor.data.TransformManager;
	
	public class AbstractLight extends AbstractScene implements ILight
	{
		protected static const LIGHT_DATA : Factory	= Factory.getFactory(LightData);
		
		protected var _color	: uint;
		
		public function get color()		: uint		{ return _color; }
		
		public function get isSingle() : Boolean
		{
			return false;
		}
		
		public function getData(transformManager : TransformManager) : IWorldData
		{
			throw new Error('Must be overriden');
		}
		
		public function AbstractLight(color : uint = 0xFFFFFF) 
		{
			_color = color;
		}
		
	}
}
