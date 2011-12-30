package aerys.minko.render.effect.lighting
{
	import aerys.minko.render.effect.IEffectPass;
	import aerys.minko.render.effect.IRenderingEffect;
	import aerys.minko.render.effect.lighting.offscreen.CubeShadowMapShader;
	import aerys.minko.render.effect.lighting.offscreen.DepthPass;
	import aerys.minko.render.effect.lighting.offscreen.MatrixShadowMapShader;
	import aerys.minko.render.effect.lighting.offscreen.ParaboloidShadowMapShader;
	import aerys.minko.render.effect.lighting.onscreen.LightingPass;
	import aerys.minko.render.resource.IResource;
	import aerys.minko.render.resource.texture.CubicTextureResource;
	import aerys.minko.render.shader.ActionScriptShader;
	import aerys.minko.render.target.AbstractRenderTarget;
	import aerys.minko.render.target.CubicTextureRenderTarget;
	import aerys.minko.render.target.TextureRenderTarget;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	import aerys.minko.scene.data.WorldDataList;
	import aerys.minko.scene.node.light.ConstDirectionalLight;
	import aerys.minko.scene.node.light.ConstPointLight;
	import aerys.minko.scene.node.light.ConstSpotLight;
	
	import flash.utils.Dictionary;
	
	public class LightingEffect implements IRenderingEffect
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
		
		private var _renderTarget	: AbstractRenderTarget	= null;
		
		public function LightingEffect(renderTarget	: AbstractRenderTarget = null)
		{
			_renderTarget = renderTarget;
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
			var hash		: String		= '';
			var lights		: WorldDataList	= WorldDataList(worldData[LightData]);
			var lightCount	: uint			= lights ? lights.length : 0;
			
			for (var lightId : uint = 0; lightId < lightCount; ++lightId)
			{
				var light : LightData = LightData(lights.getItem(lightId));
				hash += light.shadowMapSize.toString(16) + '|';
			}
			
			return hash;
		}
		
		protected function updatePasses(worldData : Dictionary) : void
		{
			var depthMaps : Vector.<IResource> = new Vector.<IResource>();
			
			_passes.length = 0;
			
			resetTargetUseCounter();
			
			var lights		: WorldDataList	= WorldDataList(worldData[LightData]);
			var lightCount	: uint			= lights ? lights.length : 0;
			
			var currentPriority : uint = 2;
			for (var lightId : uint = 0; lightId < lightCount; ++lightId)
			{
				var lightData : LightData = LightData(lights.getItem(lightId));
				if (lightData.castShadows)
					currentPriority = createShadowPasses(lightId, lightData, _passes, depthMaps, currentPriority);
			}
			
			disposeOldTargets();
			
			_passes.push(new LightingPass(depthMaps, 0, _renderTarget));
		}
		
		protected function createShadowPasses(lightId			: uint,
											  lightData			: LightData,
											  passes			: Vector.<IEffectPass>,
											  depthMaps			: Vector.<IResource>,
											  currentPriority	: uint) : uint
		{
			var shadowMap	: TextureRenderTarget;
			var pass		: IEffectPass;
			var depthShader	: ActionScriptShader;
			var lightType	: uint = lightData.type;
			var i			: uint;
			
			if (lightType == ConstDirectionalLight.TYPE || lightType == ConstSpotLight.TYPE)
			{
				shadowMap	= getTextureRenderTarget(lightData.shadowMapSize);
				depthShader	= new MatrixShadowMapShader(lightId);
				pass		= new DepthPass(depthShader, currentPriority++, shadowMap);
				_passes.push(pass);
				depthMaps.push(shadowMap.textureResource);
			}
			else if (lightType == ConstPointLight.TYPE)
			{
				if (lightData.useParaboloidShadows)
				{
					for (i = 0; i < 2; ++i)
					{
						shadowMap	= getTextureRenderTarget(lightData.shadowMapSize);
						depthShader	= new ParaboloidShadowMapShader(lightId, i == 0);
						pass		= new DepthPass(depthShader, currentPriority++, shadowMap);
						_passes.push(pass);
						depthMaps.push(shadowMap.textureResource);
					}
				}
				else
				{
					var cubicTextureResource	: CubicTextureResource = new CubicTextureResource(lightData.shadowMapSize);
					var cubicShadowMap			: CubicTextureRenderTarget;
					depthMaps.push(cubicTextureResource);
					
					for (i = 0; i < 6; ++i)
					{
						cubicShadowMap	= new CubicTextureRenderTarget(cubicTextureResource, i, 0xbb0000);
						depthShader		= new CubeShadowMapShader(lightId, i);
						pass			= new DepthPass(depthShader, currentPriority++, cubicShadowMap);
						_passes.push(pass);
					}
				}
			}
			else
			{
				throw new Error('Unsupported light type');
			}
			
			return currentPriority;
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