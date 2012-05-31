package aerys.minko.render.effect.lighting
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.Viewport;
	import aerys.minko.render.effect.Effect;
	import aerys.minko.render.effect.lighting.offscreen.CubeShadowMapShader;
	import aerys.minko.render.effect.lighting.offscreen.MatrixShadowMapShader;
	import aerys.minko.render.effect.lighting.offscreen.ParaboloidShadowMapShader;
	import aerys.minko.render.effect.lighting.onscreen.LightingShader;
	import aerys.minko.render.resource.texture.CubeTextureResource;
	import aerys.minko.render.resource.texture.TextureResource;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.scene.node.Scene;
	import aerys.minko.type.data.DataBindings;
	
	import flash.display.BitmapData;
	
	public class LightingEffect extends Effect
	{
		use namespace minko_lighting;
		
		private const SHADOW_FACTORIES : Vector.<Function> = new <Function>[
			manageNoShadowing,				// 0: ShadowMappingType.NONE
			manageMatrixShadowing,			// 1: ShadowMappingType.MATRIX
			manageDualParaboloidShadowing,	// 2: ShadowMappingType.DUAL_PARABOLOID
			manageCubicShadowing			// 3: ShadowMappingType.CUBIC
		];
		
		private var _scene				: Scene;
		private var _renderingPass		: LightingShader;
		private var _watchedProperties	: Vector.<String>;
		
		private var _updatePasses		: Boolean;
		
		public function LightingEffect(scene : Scene)
		{
			_renderingPass		= new LightingShader();
			_watchedProperties	= new Vector.<String>();
			_scene				= scene;
			_updatePasses		= true;
			
			scene.enterFrame.add(onSceneEnterFrame);
		}
		
		private function onSceneEnterFrame(scene		: Scene,
										   viewport		: Viewport,
										   destination	: BitmapData, 
										   timer		: uint) : void
		{
			if (_updatePasses)
			{
				updatePasses();
				_updatePasses = false;
			}
		}
		
		private function onWatchedPropertyChange(sceneBindings	: DataBindings, 
												 propertyName	: String, 
												 newValue		: Object) : void
		{
			_updatePasses = true;
		}
		
		private function updatePasses() : void
		{
			while (_watchedProperties.length != 0)
				sceneBindings.removeCallback(_watchedProperties.pop(), onWatchedPropertyChange);
			
			var passes			: Vector.<Shader>	= new Vector.<Shader>;
			var sceneBindings	: DataBindings		= _scene.bindings;
			var shader			: Shader;
			var renderTarget	: RenderTarget;
			
			for (var lightId : uint = 0;; ++lightId)
			{
				var shadowCastingPropertyName : String = LightingProperties.getNameFor(lightId, 'shadowCastingType');
				
				_watchedProperties.push(shadowCastingPropertyName);
				sceneBindings.addCallback(shadowCastingPropertyName, onWatchedPropertyChange);
				
				if (!sceneBindings.propertyExists(shadowCastingPropertyName))
					break;
				
				SHADOW_FACTORIES[sceneBindings.getProperty(shadowCastingPropertyName)](lightId, passes);
			}
			
			passes.push(_renderingPass);
			
			changePasses(passes);
		}
		
		private function manageNoShadowing(lightId : uint, passes : Vector.<Shader>) : void
		{
			// nothing to do here, no extra rendering is necessary
		}
		
		private function manageMatrixShadowing(lightId : uint, passes : Vector.<Shader>) : void
		{
			var textureResource : TextureResource	= getLightProperty(lightId, 'shadowMap');
			var renderTarget	: RenderTarget		= //null;
				new RenderTarget(textureResource.width, textureResource.height, textureResource, 0, 0xffffffff);
			
			passes.push(new MatrixShadowMapShader(lightId, lightId + 1, renderTarget));
		}
		
		private function manageDualParaboloidShadowing(lightId : uint, passes : Vector.<Shader>) : void
		{
			var frontTextureResource : TextureResource	= getLightProperty(lightId, 'shadowMapDPFront');
			var backTextureResource	 : TextureResource	= getLightProperty(lightId, 'shadowMapDPBack');
			var size				 : uint				= frontTextureResource.width;
			var frontRenderTarget	 : RenderTarget		= new RenderTarget(size, size, frontTextureResource, 0, 0xffffffff);
			var backRenderTarget	 : RenderTarget		= new RenderTarget(size, size, backTextureResource, 0, 0xffffffff);
			
			passes.push(
				new ParaboloidShadowMapShader(lightId, true, lightId + 0.5, frontRenderTarget),
				new ParaboloidShadowMapShader(lightId, false, lightId + 1, backRenderTarget)
			);
		}
		
		private function manageCubicShadowing(lightId : uint, passes : Vector.<Shader>) : void
		{
			var textureResource	: CubeTextureResource	= getLightProperty(lightId, 'shadowMapCube');
			var size			: uint					= textureResource.size;
			var renderTarget0	: RenderTarget			= new RenderTarget(size, size, textureResource, 0, 0xffffffff);
			var renderTarget1	: RenderTarget			= new RenderTarget(size, size, textureResource, 1, 0xffffffff);
			var renderTarget2	: RenderTarget			= new RenderTarget(size, size, textureResource, 2, 0xffffffff);
			var renderTarget3	: RenderTarget			= new RenderTarget(size, size, textureResource, 3, 0xffffffff);
			var renderTarget4	: RenderTarget			= new RenderTarget(size, size, textureResource, 4, 0xffffffff);
			var renderTarget5	: RenderTarget			= new RenderTarget(size, size, textureResource, 5, 0xffffffff);
			
			passes.push(
				new CubeShadowMapShader(lightId, 0, lightId + 0.1, renderTarget0),
				new CubeShadowMapShader(lightId, 1, lightId + 0.2, renderTarget1),
				new CubeShadowMapShader(lightId, 2, lightId + 0.3, renderTarget2),
				new CubeShadowMapShader(lightId, 3, lightId + 0.4, renderTarget3),
				new CubeShadowMapShader(lightId, 4, lightId + 0.5, renderTarget4),
				new CubeShadowMapShader(lightId, 5, lightId + 0.6, renderTarget5)
			);
		}
		
		private function getLightProperty(lightId : uint, propertyName : String) : *
		{
			return _scene.bindings.getProperty(LightingProperties.getNameFor(lightId, propertyName));
		}
	}
}
