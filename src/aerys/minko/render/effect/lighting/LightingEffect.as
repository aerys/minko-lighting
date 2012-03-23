package aerys.minko.render.effect.lighting
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.ns.minko_render;
	import aerys.minko.render.effect.Effect;
	import aerys.minko.render.effect.lighting.onscreen.LightingPass;
	import aerys.minko.render.shader.PassTemplate;
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.scene.node.Scene;
	import aerys.minko.scene.node.light.AbstractLight;
	import aerys.minko.scene.node.light.DirectionalLight;
	import aerys.minko.scene.node.light.PointLight;
	import aerys.minko.scene.node.light.SpotLight;
	import aerys.minko.type.enum.ShadowMappingType;
	
	public class LightingEffect extends Effect
	{
		use namespace minko_render;
		use namespace minko_lighting;
		
		private var _scene					: Scene;
		private var _renderingPass			: LightingPass;
		
		private var _watchedLights			: Vector.<AbstractLight>;
		private var _watchedLightsCastType	: Vector.<uint>;
		
		public function LightingEffect(scene : Scene)
		{
			_scene					= scene;
			_renderingPass			= new LightingPass();
			
			_watchedLights			= new Vector.<AbstractLight>();
			_watchedLightsCastType	= new Vector.<uint>();
			
			scene.childAdded.add(onSceneChildAdded);
			scene.childRemoved.add(onSceneChildRemoved);
			
			updatePasses();
		}
		
		private function updatePasses() : void
		{
			reset();
			initPasses();
			
			passesChanged.execute(this);
		}
		
		private function reset() : void
		{
			var numLights : uint = _watchedLights.length;
			
			for (var lightId : uint = 0; lightId < numLights; ++lightId)
				_watchedLights[lightId].changed.remove(onLightChanged);
			
			_passes.length					= 0;
			_watchedLights.length			= 0;
			_watchedLightsCastType.length	= 0;
		}
		
		private function initPasses() : void
		{
			var lights		: Vector.<ISceneNode>	= _scene.getDescendantsByType(AbstractLight);
			var numLights	: uint					= lights.length;
			var passId		: uint					= 0;
			
			for (var lightId : uint = 0; lightId < numLights; ++lightId)
			{
				var light				: AbstractLight	= AbstractLight(lights[lightId]);
				var shadowCastingType	: uint			= light.shadowCastingType;
					
				_watchedLights[lightId]			= light;
				_watchedLightsCastType[lightId]	= shadowCastingType;
				
				light.changed.add(onLightChanged);
				
				if (shadowCastingType != ShadowMappingType.NONE)
				{
					if (light is DirectionalLight)
						_passes[passId++] = DirectionalLight(light).depthMapShader;
					else if (light is SpotLight)
						_passes[passId++] = SpotLight(light).depthMapShader;
					else if (light is PointLight)
						for each (var pass : PassTemplate in PointLight(light).depthMapShaders)
							_passes[passId++] = pass;
				}
			}
			
			_passes[passId++] = _renderingPass;
		}
		
		private function onSceneChildAdded(scene	: Scene,
										   child	: ISceneNode) : void
		{
//			if (child is AbstractLight)
//				updatePasses();
		}
		
		private function onSceneChildRemoved(scene	: Scene,
											 child	: ISceneNode) : void
		{
//			if (child is AbstractLight)
//				updatePasses();
		}
		
		private function onLightChanged(light			: AbstractLight,
										propertyName	: String) : void
		{
			// for now, we recompile everything
//			switch (propertyName)
//			{
//				case 'depthMapShader':
//				case 'depthMapShaders':
//					updatePasses();
//					break;
//			}
		}
	}
}
