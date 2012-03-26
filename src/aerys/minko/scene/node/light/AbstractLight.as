package aerys.minko.scene.node.light
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.scene.node.AbstractSceneNode;
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.scene.node.Scene;
	import aerys.minko.type.Signal;
	import aerys.minko.type.data.DataBindings;
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
			_changed	= new Signal('AbstractLight.changed');
			
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
			// /!\ This happens AFTER being removed from scene.
			// Calling scene.getDescendantsByType does not return current light.
			
			super.removedFromSceneHandler(child, scene);
			
			var sceneBindings	: DataBindings = scene.bindings;
			
			// retrieve all lights
			var lights			: Vector.<ISceneNode>	= scene.getDescendantsByType(AbstractLight);
			var numLights		: uint					= lights.length;
			
			// remove myself from scene bindings
			sceneBindings.remove(this);
			
			// if we are not the light with the greater id, we need to swap ids with another light
			if (_lightId != numLights)
				for (var lightId : uint = 0; lightId < numLights; ++lightId)
				{
					var light : AbstractLight = AbstractLight(lights[lightId]);
					
					if (light._lightId == numLights)
					{
						sceneBindings.remove(light);
						light.setLightId(_lightId);
						sceneBindings.add(light);
						break;
					}
				}
			
		}
	}
}
