package aerys.minko.render.effect.lighting.compositing
{
	import aerys.minko.render.effect.IEffectPass;
	import aerys.minko.render.effect.Style;
	import aerys.minko.render.effect.basic.BasicStyle;
	import aerys.minko.render.effect.lighting.LightingStyle;
	import aerys.minko.render.renderer.RendererState;
	import aerys.minko.render.resource.IResource;
	import aerys.minko.render.target.AbstractRenderTarget;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	import aerys.minko.scene.data.ViewportData;
	import aerys.minko.scene.data.WorldDataList;
	import aerys.minko.scene.node.light.DirectionalLight;
	import aerys.minko.scene.node.light.PointLight;
	import aerys.minko.scene.node.light.SpotLight;
	import aerys.minko.type.enum.Blending;
	import aerys.minko.type.enum.CompareMode;
	import aerys.minko.type.enum.TriangleCulling;
	import aerys.minko.type.math.Vector4;
	
	import flash.utils.Dictionary;
	
	public class LightingPass implements IEffectPass
	{
		private static const TMP_VECTOR	: Vector4			= new Vector4();
		private static const SHADER		: LightingShader	= new LightingShader();
		
		protected var _lightDepthResources	: Vector.<IResource>;
		protected var _priority				: Number;
		protected var _renderTarget			: AbstractRenderTarget;
		
		public function LightingPass(lightDepthResources	: Vector.<IResource>,
									 priority				: Number				= 0,
									 renderTarget			: AbstractRenderTarget	= null)
		{
			_lightDepthResources	= lightDepthResources;
			_priority				= priority;
			_renderTarget			= renderTarget;
		}
		
		public function fillRenderState(state			: RendererState,
										styleStack		: StyleData, 
										transformData	: TransformData,
										worldData		: Dictionary) : Boolean
		{
			// Set triangleCulling, and normal multiplier
			var triangleCulling	: uint = uint(styleStack.get(BasicStyle.TRIANGLE_CULLING, TriangleCulling.BACK));
			
			state.triangleCulling = triangleCulling;
			if (!styleStack.isSet(BasicStyle.NORMAL_MULTIPLIER))
			{
				var normalMultiplier : Number = triangleCulling == TriangleCulling.BACK ? 1 : -1;
				styleStack.set(BasicStyle.NORMAL_MULTIPLIER, normalMultiplier);
			}
			
			// set blending, and alpha sorting
			var blending		: uint = uint(styleStack.get(BasicStyle.BLENDING, Blending.NORMAL));
			state.blending = blending;
			
			var priorityMod : Number = 0;
			if (blending == Blending.ALPHA)
			{
				TMP_VECTOR.set(0, 0, 0, 1);
				transformData.localToScreen.projectVector(TMP_VECTOR, TMP_VECTOR);
				priorityMod = 1 - TMP_VECTOR.z;
				priorityMod = Math.max(Number.MIN_VALUE, priorityMod);
				priorityMod = Math.min(1 - Number.MIN_VALUE, priorityMod);
			}
			state.priority = _priority - priorityMod;
			
			// set depthmaps
			if (styleStack.get(LightingStyle.RECEIVE_SHADOWS, false))
			{
				var lightDatas		: WorldDataList = worldData[LightData];
				var lightDataCount	: uint			= lightDatas.length;
				
				var textureId		: uint			= 0;
				for (var lightId : int = 0; lightId < lightDataCount; ++lightId)
				{
					var lightData : LightData = LightData(lightDatas.getItem(lightId));
					if (!lightData.castShadows)
						continue;
					
					if (lightData.type == SpotLight.TYPE || lightData.type == DirectionalLight.TYPE)
					{
						styleStack.set(Style.getStyleId('lighting matrixDepthMap' + lightId), _lightDepthResources[textureId++]);
					}
					else if (lightData.type == PointLight.TYPE)
					{
						if (lightData.useParaboloidShadows)
						{
							styleStack.set(Style.getStyleId('lighting frontParaboloidDepthMap' + lightId), _lightDepthResources[textureId++]);
							styleStack.set(Style.getStyleId('lighting backParaboloidDepthMap' + lightId), _lightDepthResources[textureId++]);
						}
						else
						{
							styleStack.set(Style.getStyleId('lighting cubeDepthMap' + lightId), _lightDepthResources[textureId++]);
						}
					}
				}
			}
			
			state.rectangle		= null;
			state.renderTarget	= _renderTarget || worldData[ViewportData].renderTarget;
			state.depthTest		= CompareMode.LESS;
			
			SHADER.fillRenderState(state, styleStack, transformData, worldData);
			
			return true;
		}
	}
}
