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
		
		protected var _lightId			: int;
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
			_changed		= new Signal('AbstractLight.changed');
			_dataDescriptor	= new Object();
			_color			= color;
			_group			= group;
			_lightId		= -1;
		}

		public function lock() : void
		{
			_locked = true;
		}
		
		public function unlock() : void
		{
			_locked = false;
		}

		protected function setLightId(lightId		: int, 
									  sceneBindings	: DataBindings) : void
		{
			throw new Error('Must be overriden');
		}
		
		override protected function addedToSceneHandler(child : ISceneNode, scene : Scene):void
		{
			// this happens AFTER being added to scene
			super.addedToSceneHandler(child, scene);
			
			sortLights(scene);
		}
		
		override protected function removedFromSceneHandler(child : ISceneNode, scene : Scene):void
		{
			// This happens AFTER being removed from scene.
			super.removedFromSceneHandler(child, scene);
			
			setLightId(-1, scene.bindings);
			sortLights(scene);
		}
		
		private static function sortLights(scene : Scene) : void
		{
			var sceneBindings	: DataBindings			= scene.bindings;
			var lights			: Vector.<ISceneNode>	= scene.getDescendantsByType(AbstractLight);
			var numLights		: uint					= lights.length;
			
			lights.sort(compare);
			
			for (var lightId : uint = 0; lightId < numLights; ++lightId)
				AbstractLight(lights[lightId]).setLightId(lightId, sceneBindings);
		}
		
		private static function compare(light1 : AbstractLight, light2 : AbstractLight) : uint
		{
			return light2.type - light1.type;
		}
	}
}
