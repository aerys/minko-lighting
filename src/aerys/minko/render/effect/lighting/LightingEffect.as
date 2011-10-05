package aerys.minko.render.effect.lighting
{
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.effect.IEffectPass;
	import aerys.minko.render.effect.IRenderingEffect;
	import aerys.minko.render.effect.Style;
	import aerys.minko.render.resource.Texture3DResource;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	import aerys.minko.scene.data.ViewportData;
	import aerys.minko.scene.data.WorldDataList;
	
	import flash.utils.Dictionary;
	
	[StyleParameter(name="basic diffuse map", type="texture")]
	[StyleParameter(name="light enabled", type="boolean")]
	
	public class LightingEffect implements IRenderingEffect
	{
		private var _passes			: Object;
		private var _renderTarget	: RenderTarget;
		
		public function LightingEffect(renderTarget	: RenderTarget	= null)
		{
			super();
			
			_passes = new Object();
			_renderTarget = renderTarget;
		}
		
		public function getPasses(styleStack	: StyleData, 
								  local			: TransformData, 
								  world			: Dictionary) : Vector.<IEffectPass>
		{
			var hash : String = computePassListHash(styleStack, local, world);
			
			if (_passes[hash] == undefined)
				_passes[hash] = createPassList(styleStack, local, world);
			
			return _passes[hash];
		}
		
		protected function computePassListHash(styleStack	: StyleData, 
											   local		: TransformData, 
											   world		: Dictionary) : String
		{
			var hash				: String					= '';
			
			var lightDatas			: WorldDataList				= world[LightData];
			var lightDatasLength	: uint						= lightDatas ? lightDatas.length : 0;
			
			for (var i : int = 0; i < lightDatasLength; ++i)
			{
				var lightData : LightData = lightDatas.getItem(i) as LightData;
				
				hash += lightData.castShadows ? '1' : '0';
			}
			
			return hash;
		}
		
		protected function createPassList(styleStack	: StyleData, 
										  local			: TransformData, 
										  world			: Dictionary) : Vector.<IEffectPass>
		{
			var passList			: Vector.<IEffectPass>		= new Vector.<IEffectPass>();
			
			var textureResource		: Texture3DResource;
			var renderTarget		: RenderTarget;
			
			var lightDatas			: WorldDataList				= world[LightData];
			var lightDatasLength	: uint						= lightDatas ? lightDatas.length : 0;
			
			var targetIds			: Vector.<int>				= new Vector.<int>();
			var targetResources		: Vector.<Texture3DResource>	= new Vector.<Texture3DResource>();
			
			for (var i : int = 0; i < lightDatasLength; ++i)
			{
				var lightData : LightData = lightDatas.getItem(i) as LightData;
				
				if (lightData.castShadows)
				{
					renderTarget = new RenderTarget(
						RenderTarget.TEXTURE, lightData.shadowMapSize, 
						lightData.shadowMapSize, 0, true, 0);
					
					textureResource	= renderTarget.textureResource;
					
					targetIds.push(Style.getStyleId('light depthMap' + i));
					targetResources.push(textureResource);
					
					var priority	: Number = lightDatasLength + 2 - i;
					
					passList.push(new LightDepthPass(i, priority, renderTarget));
				}
			}
			
			passList.push(new LightingPass(targetIds, targetResources, 0, _renderTarget));
			
			return passList;
		}
	}
}
