package aerys.minko.render.effect.reflection
{
	import aerys.minko.render.effect.IEffect;
	import aerys.minko.render.effect.IEffectPass;
	import aerys.minko.render.effect.IRenderingEffect;
	import aerys.minko.render.effect.AbstractSinglePassEffect;
	import aerys.minko.render.effect.SinglePassRenderingEffect;
	import aerys.minko.render.effect.reflection.offscreen.PlanarReflectionMapPass;
	import aerys.minko.render.effect.reflection.offscreen.PlanarReflectionMapShader;
	import aerys.minko.render.effect.reflection.onscreen.ReflectionPass;
	import aerys.minko.render.resource.IResource;
	import aerys.minko.render.target.TextureRenderTarget;
	import aerys.minko.scene.data.ReflectionData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	import aerys.minko.scene.data.WorldDataList;
	
	import flash.utils.Dictionary;
	
	public class ReflectionEffect implements IRenderingEffect
	{
		/**
		 * Contains render target used to render shadow maps 
		 */
		protected var _buffers		: Array	= new Array();
		
		/**
		 * Used to mark used buffers 
		 */		
		protected var _usedBuffers	: Array	= new Array();
		
		protected var _lastHash		: String;
		protected var _passes		: Vector.<IEffectPass>;
		
		public function ReflectionEffect()
		{
			_passes = new Vector.<IEffectPass>();
		}
		
		public function getPasses(styleData		: StyleData, 
								  transformData	: TransformData, 
								  worldData		: Dictionary) : Vector.<IEffectPass>
		{
			var hash : String = createHash(worldData);
			if (!_lastHash || _lastHash != hash)
			{
				updatePasses(worldData);
				_lastHash = hash;
			}
			
			return _passes;
		}
		
		protected function createHash(worldData : Dictionary) : String
		{
			var hash			: String		= '';
			var reflections		: WorldDataList	= WorldDataList(worldData[ReflectionData]);
			var reflectionCount	: uint			= reflections ? reflections.length : 0;
			
			for (var reflectionId : uint = 0; reflectionId < reflectionCount; ++reflectionId)
			{
				var reflection : ReflectionData = ReflectionData(reflections.getItem(reflectionId));
				hash += reflection.size.toString(16) + '|';
			}
			
			return hash;
		}
		
		protected function updatePasses(worldData : Dictionary) : void
		{
			var reflectionMaps : Vector.<IResource> = new Vector.<IResource>();
			
			_passes.length = 0;
			
			resetTargetUseCounter();
			
			var reflections		: WorldDataList	= WorldDataList(worldData[ReflectionData]);
			var reflectionCount	: uint			= reflections ? reflections.length : 0;
			
			var currentPriority : uint = 2;
			for (var reflectionId : uint = 0; reflectionId < reflectionCount; ++reflectionId)
			{
				var reflectionData : ReflectionData = ReflectionData(reflections.getItem(reflectionId));
				
				var reflectionMap		: TextureRenderTarget	= getTextureRenderTarget(reflectionData.size);
				var pass		 		: AbstractSinglePassEffect		= new PlanarReflectionMapPass(reflectionId, currentPriority++, reflectionMap);
				
				_passes.push(pass);
				reflectionMaps.push(reflectionMap.textureResource);
			}
			
			disposeOldTargets();
			
			_passes.push(new ReflectionPass(reflectionMaps));
		}
		
		protected function resetTargetUseCounter() : void
		{
			_usedBuffers.length = 0;
		}
		
		protected function getTextureRenderTarget(resolution : uint) : TextureRenderTarget
		{
			if (!_buffers[resolution])
				_buffers[resolution] = new Array();
			
			var renderTarget		: TextureRenderTarget;
			var renderTargets		: Array = _buffers[resolution];
			var renderTargetCount	: uint	= renderTargets.length;
			
			for (var renderTargetId : uint = 0; renderTargetId < renderTargetCount; ++renderTargetId)
			{
				renderTarget = renderTargets[renderTargetId];
				if (_usedBuffers.indexOf(renderTarget) != -1)
					continue;
				
				_usedBuffers.push(renderTarget);
				return renderTarget;
			}
			
			renderTarget = new TextureRenderTarget(resolution, resolution, 0xffffff);
			renderTargets.push(renderTarget);
			_usedBuffers.push(renderTarget);
			
			return renderTarget;
		}
		
		protected function disposeOldTargets() : void
		{
			for (var resolution : Object in _buffers)
			{
				var renderTargets : Array = _buffers[uint(resolution)];
				var renderTargetCount : uint = renderTargets.length;
				for (var renderTargetId : uint = 0; renderTargetId < renderTargetCount; ++renderTargetId)
				{
					var renderTarget : TextureRenderTarget = renderTargets[renderTargetId];
					if (_usedBuffers.indexOf(renderTarget) == -1)
					{
						renderTarget.textureResource.dispose();
						renderTargets.splice(renderTargetId, 1);
						--renderTargetId;
						--renderTargetCount;
					}
				}
			}
		}
		
	}
}