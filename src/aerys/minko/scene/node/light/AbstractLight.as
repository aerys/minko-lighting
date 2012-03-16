package aerys.minko.scene.node.light
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.scene.node.AbstractSceneNode;
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.scene.node.Scene;
	import aerys.minko.type.Signal;
	import aerys.minko.type.data.IDataProvider;
	
	use namespace minko_lighting;
	
	public class AbstractLight extends AbstractSceneNode implements IDataProvider
	{
		private var _changed			: Signal;
		
		protected var _lightId			: uint;
		protected var _dataDescriptor	: Object;
		
		protected var _color			: uint;
		protected var _group			: uint;
		protected var _locked			: Boolean;
		
		public function get dataDescriptor() : Object
		{
			return _dataDescriptor;
		}
		
		public function get changed() : Signal
		{ 
			return _changed;
		}
		
		public function get locked() : Boolean
		{
			return _locked;
		}
		
		minko_lighting function get lightId() : uint
		{
			return _lightId;
		}
		
		public function get type() : uint
		{
			throw new Error('Must be overriden');
		}
		
		public function get shadowCastingType() : uint
		{
			throw new Error('Must be overriden'); 
		}
		
		public function get group() : uint
		{
			return _group;
		}
		
		public function get color() : uint
		{
			return _color;
		}
		
		public function set color(v : uint)	: void
		{
			_color	= v;
			changed.execute(this, 'color');
		}
		
		public function set group(v : uint) : void
		{
			_group = v;
			changed.execute(this, 'group');
		}
		
		public function AbstractLight(color : uint, group : uint)
		{
			_changed	= new Signal();
			
			_color		= color;
			_group		= group;
		}

		public function lock() : void
		{
			_locked = true;
		}
		
		public function unlock() : void
		{
			_locked = false;
		}
		
		protected function setLightId(lightId : uint) : void
		{
			throw new Error('Must be overriden');
		}
		
		override protected function addedToSceneHandler(child : ISceneNode, scene : Scene):void
		{
			super.addedToSceneHandler(child, scene);
			
			var lights		: Vector.<ISceneNode>	= scene.getDescendantsByType(AbstractLight);
			var numLights	: uint					= lights.length;
			
			setLightId(numLights - 1);
			
			scene.bindings.add(this);
		}
		
		override protected function removedFromSceneHandler(child : ISceneNode, scene : Scene):void
		{
			super.removedFromSceneHandler(child, scene);
			
			scene.bindings.remove(this);
			
			var lights		: Vector.<ISceneNode>	= scene.getDescendantsByType(AbstractLight);
			var numLights	: uint					= lights.length;
			var numLightsM1	: uint					= numLights - 1;
			
			for (var lightId : uint = 0; lightId < numLights; ++lightId)
			{
				var light : AbstractLight = AbstractLight(lights[lightId]);
				if (light._lightId == numLightsM1)
				{
					light.setLightId(_lightId);
					break;
				}
			}
			
			_changed.execute(this, null);
		}
	}
}
