package aerys.minko.render.effect.lighting.onscreen
{
	import aerys.minko.render.effect.IEffectPass;
	import aerys.minko.render.effect.SinglePassRenderingEffect;
	import aerys.minko.render.effect.Style;
	import aerys.minko.render.effect.lighting.LightingStyle;
	import aerys.minko.render.renderer.RendererState;
	import aerys.minko.render.resource.IResource;
	import aerys.minko.render.target.AbstractRenderTarget;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	import aerys.minko.scene.data.WorldDataList;
	import aerys.minko.scene.node.light.ConstDirectionalLight;
	import aerys.minko.scene.node.light.ConstPointLight;
	import aerys.minko.scene.node.light.ConstSpotLight;
	import aerys.minko.type.math.Vector4;
	
	import flash.utils.Dictionary;
	
	public class LightingPass extends SinglePassRenderingEffect
	{
		private static const TMP_VECTOR	: Vector4			= new Vector4();
		private static const SHADER		: LightingShader	= new LightingShader();
		
		protected var _lightDepthResources	: Vector.<IResource>;
		
		public function LightingPass(lightDepthResources	: Vector.<IResource>,
									 priority				: Number				= 0,
									 renderTarget			: AbstractRenderTarget	= null)
		{
			super(SHADER, priority, renderTarget);
			
			_lightDepthResources = lightDepthResources;
		}
		
		override public function fillRenderState(state			: RendererState,
												 styleData		: StyleData, 
												 transformData	: TransformData,
												 worldData		: Dictionary) : Boolean
		{
			// set depthmaps
			if (styleData.get(LightingStyle.RECEIVE_SHADOWS, false))
			{
				var lightDatas		: WorldDataList = worldData[LightData];
				var lightDataCount	: uint			= lightDatas ? lightDatas.length : 0;
				
				var textureId		: uint			= 0;
				for (var lightId : int = 0; lightId < lightDataCount; ++lightId)
				{
					var lightData : LightData = LightData(lightDatas.getItem(lightId));
					if (!lightData.castShadows)
						continue;
					
					if (lightData.type == ConstSpotLight.TYPE || lightData.type == ConstDirectionalLight.TYPE)
						styleData.set(Style.getStyleId('lighting matrixDepthMap' + lightId), _lightDepthResources[textureId++]);
					else if (lightData.type == ConstPointLight.TYPE)
					{
						if (lightData.useParaboloidShadows)
						{
							styleData.set(Style.getStyleId('lighting frontParaboloidDepthMap' + lightId), _lightDepthResources[textureId++]);
							styleData.set(Style.getStyleId('lighting backParaboloidDepthMap' + lightId), _lightDepthResources[textureId++]);
						}
						else
							styleData.set(Style.getStyleId('lighting cubeDepthMap' + lightId), _lightDepthResources[textureId++]);
					}
				}
			}
			
			return super.fillRenderState(state, styleData, transformData, worldData);
		}
		
		override public function getPasses(styleStack		: StyleData, 
										   transformData	: TransformData, 
										   worldData		: Dictionary) : Vector.<IEffectPass>
		{
			throw new Error("This class should never be used as an Effect. Use LightingEffect instead.");
		}
	}
}
