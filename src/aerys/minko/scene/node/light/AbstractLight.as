package aerys.minko.scene.node.light
{
	import aerys.minko.scene.action.WorldObjectAction;
	import aerys.minko.scene.data.IWorldData;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.LocalData;
	import aerys.minko.scene.node.AbstractScene;
	import aerys.minko.type.Factory;
	
	public class AbstractLight extends AbstractScene implements ILight
	{
		protected static const LIGHT_DATA : Factory	= Factory.getFactory(LightData);
		
		protected var _color	: uint;
		
		public function get color()		: uint		{ return _color; }
		public function set color(v : uint) : void { _color = v; }
		
		public function get isSingle() : Boolean
		{
			return false;
		}
		
		public function getData(localData : LocalData) : IWorldData
		{
			throw new Error('Must be overriden');
		}
		
		public function AbstractLight(color : uint = 0xFFFFFF) 
		{
			_color = color;
			
			actions[0] = WorldObjectAction.worldObjectAction;
		}
		
	}
}
