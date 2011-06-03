package aerys.minko.render.effect.lighting
{
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.effect.IEffectPass;
	import aerys.minko.render.effect.basic.BasicStyle;
	import aerys.minko.render.effect.fog.FogStyle;
	import aerys.minko.render.effect.light.LightingStyle;
	import aerys.minko.render.effect.reflection.ReflectionStyle;
	import aerys.minko.render.renderer.state.Blending;
	import aerys.minko.render.renderer.state.RendererState;
	import aerys.minko.render.renderer.state.TriangleCulling;
	import aerys.minko.render.ressource.TextureRessource;
	import aerys.minko.render.shader.DynamicShader;
	import aerys.minko.render.shader.node.INode;
	import aerys.minko.render.shader.node.common.ClipspacePosition;
	import aerys.minko.render.shader.node.common.DiffuseMapTexture;
	import aerys.minko.render.shader.node.fog.Fog;
	import aerys.minko.render.shader.node.light.LightsNode;
	import aerys.minko.render.shader.node.operation.manipulation.Blend;
	import aerys.minko.render.shader.node.operation.manipulation.MultiplyColor;
	import aerys.minko.render.shader.node.reflection.ReflectionNode;
	import aerys.minko.scene.visitor.data.LightData;
	import aerys.minko.scene.visitor.data.LocalData;
	import aerys.minko.scene.visitor.data.StyleStack;
	import aerys.minko.scene.visitor.data.ViewportData;
	import aerys.minko.scene.visitor.data.WorldDataList;
	
	import flash.utils.Dictionary;
	
	public class LightingPass implements IEffectPass
	{
		protected static const _SHADERS : Object = new Object();
		
		protected var _lightDepthIds		: Vector.<int>;
		protected var _lightDepthRessources	: Vector.<TextureRessource>;
		protected var _priority				: Number;
		protected var _renderTarget			: RenderTarget;
		
		public function LightingPass(lightDepthIds		: Vector.<int>,
									 lightDepthRessources	: Vector.<TextureRessource>,
									 priority				: Number			= 0,
									 renderTarget			: RenderTarget		= null)
		{
			_lightDepthIds			= lightDepthIds;
			_lightDepthRessources	= lightDepthRessources;
			_priority				= priority;
			_renderTarget			= renderTarget;
		}
		
		public function fillRenderState(state		: RendererState,
										styleStack	: StyleStack, 
										local		: LocalData, 
										world		: Dictionary) : Boolean
		{
			var triangleCulling		: uint		= styleStack.get(BasicStyle.TRIANGLE_CULLING, TriangleCulling.BACK) as uint;
			var normalMultiplier	: Number	= triangleCulling == TriangleCulling.BACK ? 1 : -1;
			
			styleStack.set(BasicStyle.NORMAL_MULTIPLIER, normalMultiplier);
			if (styleStack.get(LightingStyle.RECEIVE_SHADOWS, false))
			{
				var castingShadowLightsCount : uint = _lightDepthRessources.length;
				
				for (var i : int = 0; i < castingShadowLightsCount; ++i)
				{
					var lightDepthId		: int				= _lightDepthIds[i];
					var lightDepthRessource	: TextureRessource	= _lightDepthRessources[i];
					
					styleStack.set(lightDepthId, lightDepthRessource);
				}
			}
			
			state.blending			= styleStack.get(BasicStyle.BLENDING, Blending.NORMAL) as uint;
			state.priority			= state.blending == Blending.ALPHA ? _priority : _priority + 0.5;
			state.renderTarget		= _renderTarget || world[ViewportData].renderTarget;
			state.triangleCulling	= triangleCulling;
			
			getShader(styleStack, world, _lightDepthIds).fillRenderState(state, styleStack, local, world);
			
			return true;
		}
		
		protected static function getShader(styleStack		: StyleStack, 
											worldData		: Dictionary,
											lightDepthIds	: Vector.<int>) : DynamicShader
		{
			var hash : String = computeShaderHash(styleStack, worldData, lightDepthIds);
			
			if (_SHADERS[hash] == undefined)
				_SHADERS[hash] = createShader(styleStack, worldData, lightDepthIds);
			
			return _SHADERS[hash];
		}
		
		protected static function computeShaderHash(styleStack		: StyleStack,
													worldData		: Dictionary,
													lightDepthIds	: Vector.<int>) : String
		{
			var hash : String = '';
			
			if (styleStack.get(LightingStyle.LIGHT_ENABLED, false))
			{
				hash += '_light';
				
				var lightDatas : WorldDataList = worldData[LightData];
				var lightCount : uint = lightDatas ? lightDatas.length : 0;
				
				for (var i : int = 0; i < lightCount; ++i)
				{
					var type : uint = LightData(lightDatas.getItem(i)).type;
					hash += String.fromCharCode(
						33 + (type & 0xF), 
						33 + ((type & 0xF0) >>> 4), 
						33 + ((type & 0xF00) >>> 8));
				}
			}
			
			if (styleStack.get(ReflectionStyle.REFLECTION_ENABLED, false))
			{
				var blending : uint = styleStack.get(ReflectionStyle.BLENDING, aerys.minko.render.renderer.state.Blending.NORMAL)
									  as uint;
				
				hash += '_reflection' + String.fromCharCode(
					33 + (blending & 0xF), 33 + ((blending & 0xF0) >>> 4), 
					33 + ((blending & 0xF00) >>> 8), 33 + ((blending & 0xF000) >>> 12),
					33 + ((blending & 0xF0000) >>> 16), 33 + ((blending & 0xF00000) >>> 20),
					33 + ((blending & 0xF000000) >>> 24), 33 + ((blending & 0xF0000000) >>> 28)
				);
			}
			
			if (styleStack.get(LightingStyle.RECEIVE_SHADOWS, false))
				hash += '_shadowcasting';
			
			if (styleStack.get(FogStyle.FOG_ENABLED, false))
				hash += '_fog';
			
			return hash;
		}
		
		protected static function createShader(styleStack	: StyleStack, 
											   worldData	: Dictionary,
											   lightDepthIds	: Vector.<int>) : DynamicShader
		{
			var clipspacePosition	: INode = new ClipspacePosition();
			var pixelColor			: INode;
			
			pixelColor = new DiffuseMapTexture();
			
			if (styleStack.get(ReflectionStyle.REFLECTION_ENABLED, false))
			{
				pixelColor = new Blend(
					new ReflectionNode(),
					pixelColor, 
					styleStack.get(ReflectionStyle.BLENDING, Blending.ALPHA) as uint
				);
			}
			
			if (styleStack.get(LightingStyle.LIGHT_ENABLED, false))
			{
				pixelColor = new MultiplyColor(
					pixelColor,
					new LightsNode(styleStack, worldData, lightDepthIds)
				);
			}
			
			if (styleStack.get(FogStyle.FOG_ENABLED, false))
			{
				pixelColor = new Blend(new Fog(), pixelColor, Blending.NORMAL);
			}
			
			return DynamicShader.create(clipspacePosition, pixelColor);
		}
	}
}
