package aerys.minko.render.effect.lighting
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.effect.Effect;
	import aerys.minko.render.effect.lighting.offscreen.CubeShadowMapShader;
	import aerys.minko.render.effect.lighting.offscreen.MatrixShadowMapShader;
	import aerys.minko.render.effect.lighting.offscreen.ParaboloidShadowMapShader;
	import aerys.minko.render.effect.lighting.onscreen.LightingShader;
	import aerys.minko.render.resource.texture.CubeTextureResource;
	import aerys.minko.render.resource.texture.TextureResource;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.part.projection.ParaboloidProjectionShaderPart;
	import aerys.minko.type.data.DataBindings;
	
	public class LightingEffect extends Effect
	{
		use namespace minko_lighting;
		
		private const SHADOW_FACTORIES : Vector.<Function> = new <Function>[
			manageNoShadowing,				// 0: ShadowMappingType.NONE
			manageMatrixShadowing,			// 1: ShadowMappingType.MATRIX
			manageDualParaboloidShadowing,	// 2: ShadowMappingType.DUAL_PARABOLOID
			manageCubicShadowing			// 3: ShadowMappingType.CUBIC
		];
		
		private var _sceneBindings		: DataBindings;
		private var _renderingPass		: LightingShader;
		private var _watchedProperties	: Vector.<String>;
		
		public function LightingEffect(sceneBindings : DataBindings)
		{
			_renderingPass		= new LightingShader();
			_watchedProperties	= new Vector.<String>();
			_sceneBindings		= sceneBindings;
			
			createPasses();
		}
		
		private function onWatchedPropertyChange(sceneBindings	: DataBindings, 
												 propertyName	: String, 
												 newValue		: Object) : void
		{
			resetPasses();
			createPasses();
		}
		
		private function resetPasses() : void
		{
			while (_watchedProperties.length != 0)
				_sceneBindings.getPropertyChangedSignal(_watchedProperties.pop()).remove(onWatchedPropertyChange);
			
			while (numPasses != 0)
				removePass(getPass());
		}
		
		private function createPasses() : void
		{
			var shader			: Shader;
			var renderTarget	: RenderTarget;
			
			for (var lightId : uint = 0;; ++lightId)
			{
				var shadowCastingPropertyName : String = LightingProperties.getNameFor(lightId, 'shadowCastingType');
				
				_watchedProperties.push(shadowCastingPropertyName);
				_sceneBindings.getPropertyChangedSignal(shadowCastingPropertyName)
							  .add(onWatchedPropertyChange);
				
				if (!_sceneBindings.propertyExists(shadowCastingPropertyName))
					break;
				
				SHADOW_FACTORIES[_sceneBindings.getProperty(shadowCastingPropertyName)](lightId);
			}
			
			addPass(_renderingPass);
		}
		
		private function manageNoShadowing(lightId : uint) : void
		{
			// nothing to do here, no extra rendering is necessary
		}
		
		private function manageMatrixShadowing(lightId : uint) : void
		{
			var textureResource : TextureResource	= getLightProperty(lightId, 'shadowMap');
			var renderTarget	: RenderTarget		= 
				new RenderTarget(textureResource.width, textureResource.height, textureResource, 0, 0xffffff);
			
			addPass(new MatrixShadowMapShader(lightId, lightId + 1, renderTarget));
		}
		
		private function manageDualParaboloidShadowing(lightId : uint) : void
		{
			var frontTextureResource : TextureResource	= getLightProperty(lightId, 'shadowMapDPFront');
			var backTextureResource	 : TextureResource	= getLightProperty(lightId, 'shadowMapDPBack');
			var size				 : uint				= frontTextureResource.width;
			var frontRenderTarget	 : RenderTarget		= new RenderTarget(size, size, frontTextureResource, 0, 0xffffff);
			var backRenderTarget	 : RenderTarget		= new RenderTarget(size, size, backTextureResource, 0, 0xffffff);
			
			addPass(new ParaboloidShadowMapShader(lightId, true, lightId + 0.5, frontRenderTarget));
			addPass(new ParaboloidShadowMapShader(lightId, false, lightId + 1, backRenderTarget));
		}
		
		private function manageCubicShadowing(lightId : uint) : void
		{
			var textureResource	: CubeTextureResource	= getLightProperty(lightId, 'shadowMapCube');
			var size			: uint					= textureResource.size;
			var renderTarget0	: RenderTarget			= new RenderTarget(size, size, textureResource, 0, 0xffffff);
			var renderTarget1	: RenderTarget			= new RenderTarget(size, size, textureResource, 1, 0xffffff);
			var renderTarget2	: RenderTarget			= new RenderTarget(size, size, textureResource, 2, 0xffffff);
			var renderTarget3	: RenderTarget			= new RenderTarget(size, size, textureResource, 3, 0xffffff);
			var renderTarget4	: RenderTarget			= new RenderTarget(size, size, textureResource, 4, 0xffffff);
			var renderTarget5	: RenderTarget			= new RenderTarget(size, size, textureResource, 5, 0xffffff);
			
			addPass(new CubeShadowMapShader(lightId, 0, lightId + 0.1, renderTarget0));
			addPass(new CubeShadowMapShader(lightId, 1, lightId + 0.2, renderTarget1));
			addPass(new CubeShadowMapShader(lightId, 2, lightId + 0.3, renderTarget2));
			addPass(new CubeShadowMapShader(lightId, 3, lightId + 0.4, renderTarget3));
			addPass(new CubeShadowMapShader(lightId, 4, lightId + 0.5, renderTarget4));
			addPass(new CubeShadowMapShader(lightId, 5, lightId + 0.6, renderTarget5));
		}
		
		private function getLightProperty(lightId : uint, propertyName : String) : *
		{
			return _sceneBindings.getProperty(LightingProperties.getNameFor(lightId, propertyName));
		}
	}
}
