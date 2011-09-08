package aerys.minko.scene.node.light
{
	import aerys.minko.scene.action.LightAction;
	import aerys.minko.scene.data.IWorldData;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.LocalData;
	import aerys.minko.scene.node.AbstractScene;
	import aerys.minko.type.Factory;
	
	public class AbstractLight extends AbstractScene implements ILight
	{
		protected static const LIGHT_DATA : Factory	= Factory.getFactory(LightData);
		
		protected var _color	: uint;
		protected var _group	: uint;
		
		public function get color()	: uint	{ return _color; }
		public function get group() : uint	{ return _group; }
		
		public function set color(v : uint) : void 	{ _color = v; }
		public function set group(v : uint) : void	{ _group = v; }
		
		public function get isSingle() : Boolean
		{
			return false;
		}
		
		public function getLightData(localData : LocalData) : LightData
		{
			throw new Error();
		}
		
		public function AbstractLight(color : uint, group : uint)
		{
			_color = color;
			_group = group;
			
			actions[0] = new LightAction();
		}
	}
}
