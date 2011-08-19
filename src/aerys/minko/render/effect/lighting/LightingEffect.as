package aerys.minko.render.effect.lighting
{
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.effect.IEffect;
	import aerys.minko.render.effect.IEffectPass;
	import aerys.minko.render.effect.Style;
	import aerys.minko.render.resource.TextureResource;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.LocalData;
	import aerys.minko.scene.data.StyleStack;
	import aerys.minko.scene.data.WorldDataList;
	
	import flash.utils.Dictionary;
	
	[StyleParameter(name="basic diffuse map", type="texture")]
	[StyleParameter(name="light enabled", type="boolean")]
	
	public class LightingEffect implements IEffect
	{
		private var _passes	: Object;
		
		public function LightingEffect()
		{
			super();
			
			_passes = new Object();
		}
		
		public function getPasses(styleStack	: StyleStack, 
								  local			: LocalData, 
								  world			: Dictionary) : Vector.<IEffectPass>
		{
			var hash : String = computePassListHash(styleStack, local, world);
			
			if (_passes[hash] == undefined)
				_passes[hash] = createPassList(styleStack, local, world);
			
			return _passes[hash];
		}
		
		protected function computePassListHash(styleStack	: StyleStack, 
											   local		: LocalData, 
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
		
		protected function createPassList(styleStack	: StyleStack, 
										  local			: LocalData, 
										  world			: Dictionary) : Vector.<IEffectPass>
		{
			var passList			: Vector.<IEffectPass>		= new Vector.<IEffectPass>();
			
			var textureRessource	: TextureResource;
			var renderTarget		: RenderTarget;
			
			var lightDatas			: WorldDataList				= world[LightData];
			var lightDatasLength	: uint						= lightDatas ? lightDatas.length : 0;
			
			var targetIds			: Vector.<int>				= new Vector.<int>();
			var targetRessources	: Vector.<TextureResource>	= new Vector.<TextureResource>();
			
			for (var i : int = 0; i < lightDatasLength; ++i)
			{
				var lightData : LightData = lightDatas.getItem(i) as LightData;
				
				if (lightData.castShadows)
				{
					renderTarget = new RenderTarget(
						RenderTarget.TEXTURE, lightData.shadowMapSize, 
						lightData.shadowMapSize, 0, true, 0);
					
					textureRessource	= renderTarget.textureRessource;
					
					targetIds.push(Style.getStyleId('light depthMap' + i));
					targetRessources.push(textureRessource);
					
					var priority	: Number = lightDatasLength + 2 - i;
					
					passList.push(new LightDepthPass(i, priority, renderTarget));
				}
			}
			
			passList.push(new LightingPass(targetIds, targetRessources, 0));
			
			return passList;
		}
	}
}
