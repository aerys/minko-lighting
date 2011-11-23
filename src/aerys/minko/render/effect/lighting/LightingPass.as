package aerys.minko.render.effect.lighting
{
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.effect.IEffectPass;
	import aerys.minko.render.effect.animation.AnimationStyle;
	import aerys.minko.render.effect.basic.BasicStyle;
	import aerys.minko.render.effect.reflection.ReflectionStyle;
	import aerys.minko.render.renderer.RendererState;
	import aerys.minko.render.resource.TextureResource;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.node.Components;
	import aerys.minko.render.shader.node.INode;
	import aerys.minko.render.shader.node.animation.AnimatedPosition;
	import aerys.minko.render.shader.node.common.DiffuseMapTexture;
	import aerys.minko.render.shader.node.leaf.Attribute;
	import aerys.minko.render.shader.node.leaf.Constant;
	import aerys.minko.render.shader.node.leaf.StyleParameter;
	import aerys.minko.render.shader.node.leaf.TransformParameter;
	import aerys.minko.render.shader.node.light.LightsNode;
	import aerys.minko.render.shader.node.operation.builtin.Multiply4x4;
	import aerys.minko.render.shader.node.operation.manipulation.Blend;
	import aerys.minko.render.shader.node.operation.manipulation.Combine;
	import aerys.minko.render.shader.node.operation.manipulation.Copy;
	import aerys.minko.render.shader.node.operation.manipulation.Extract;
	import aerys.minko.render.shader.node.operation.manipulation.Interpolate;
	import aerys.minko.render.shader.node.operation.manipulation.MultiplyColor;
	import aerys.minko.render.shader.node.reflection.ReflectionNode;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	import aerys.minko.scene.data.ViewportData;
	import aerys.minko.scene.data.WorldDataList;
	import aerys.minko.type.animation.AnimationMethod;
	import aerys.minko.type.enum.Blending;
	import aerys.minko.type.enum.CompareMode;
	import aerys.minko.type.enum.TriangleCulling;
	import aerys.minko.type.math.Vector4;
	import aerys.minko.type.stream.format.VertexComponent;
	
	import flash.utils.Dictionary;
	
	public class LightingPass implements IEffectPass
	{
		protected static const _SHADERS : Object = new Object();
		
		protected var _lightDepthIds		: Vector.<int>;
		protected var _lightDepthResources	: Vector.<TextureResource>;
		protected var _priority				: Number;
		protected var _renderTarget			: RenderTarget;
		
		public function LightingPass(lightDepthIds			: Vector.<int>,
									 lightDepthResources	: Vector.<TextureResource>,
									 priority				: Number			= 0,
									 renderTarget			: RenderTarget		= null)
		{
			_lightDepthIds			= lightDepthIds;
			_lightDepthResources	= lightDepthResources;
			_priority				= priority;
			_renderTarget			= renderTarget;
		}
		
		public function fillRenderState(state		: RendererState,
										styleStack	: StyleData, 
										local		: TransformData,
										world		: Dictionary) : Boolean
		{
			var triangleCulling	: uint	= styleStack.get(BasicStyle.TRIANGLE_CULLING, TriangleCulling.BACK) as uint;
			
			if (!styleStack.isSet(BasicStyle.NORMAL_MULTIPLIER))
			{
				var normalMultiplier	: Number	= triangleCulling == TriangleCulling.BACK ? 1 : -1;
				
				styleStack.set(BasicStyle.NORMAL_MULTIPLIER, normalMultiplier);
			}
			
			if (styleStack.get(LightingStyle.RECEIVE_SHADOWS, false))
			{
				var castingShadowLightsCount : uint = _lightDepthResources.length;
				
				for (var i : int = 0; i < castingShadowLightsCount; ++i)
				{
					var lightDepthId		: int				= _lightDepthIds[i];
					var lightDepthResource	: TextureResource	= _lightDepthResources[i];
					
					styleStack.set(lightDepthId, lightDepthResource);
				}
			}
			
			state.blending			= styleStack.get(BasicStyle.BLENDING, Blending.NORMAL) as uint;
			state.priority			= state.blending == Blending.ALPHA ? _priority : _priority + 0.5;
			state.rectangle			= null;
			state.renderTarget		= _renderTarget || world[ViewportData].renderTarget;
			state.triangleCulling	= triangleCulling;
			state.depthTest			= CompareMode.LESS;
			
			getShader(styleStack, world, _lightDepthIds).fillRenderState(state, styleStack, local, world);
			
			return true;
		}
		
		protected static function getShader(styleStack		: StyleData, 
											worldData		: Dictionary,
											lightDepthIds	: Vector.<int>) : Shader
		{
			var hash : String = computeShaderHash(styleStack, worldData, lightDepthIds);
			
			if (_SHADERS[hash] == undefined)
				_SHADERS[hash] = createShader(styleStack, worldData, lightDepthIds);
			
			return _SHADERS[hash];
		}
		
		protected static function computeShaderHash(styleStack		: StyleData,
													worldData		: Dictionary,
													lightDepthIds	: Vector.<int>) : String
		{
			var hash : String = '';
			
			// diffuse color source
			var diffuseStyleValue	: Object = styleStack.isSet(BasicStyle.DIFFUSE) ?
				styleStack.get(BasicStyle.DIFFUSE) :
				null;
			
			if (diffuseStyleValue == null)
				hash += '_colorFromVertex';
			else if (diffuseStyleValue is uint || diffuseStyleValue is Vector4)
				hash += '_colorFromConstant';
			else if (diffuseStyleValue is TextureResource)
				hash += '_colorFromTexture';
			else
				throw new Error('Invalid BasicStyle.DIFFUSE value');
			
			// skinning status
			if (styleStack.get(AnimationStyle.METHOD, AnimationMethod.DISABLED) != AnimationMethod.DISABLED)
			{
				hash += "_animation(";
				hash += "method=" + styleStack.get(AnimationStyle.METHOD);
				hash += ",maxInfluences=" + styleStack.get(AnimationStyle.MAX_INFLUENCES, 0);
				hash += ",numBones=" + styleStack.get(AnimationStyle.NUM_BONES, 0);
				hash += ")";
			}
			
			// lighting status
			if (styleStack.get(LightingStyle.LIGHTS_ENABLED, false))
			{
				hash += '_light';
				
				var lightDatas : WorldDataList = worldData[LightData];
				var lightCount : uint = lightDatas ? lightDatas.length : 0;
				
				for (var i : int = 0; i < lightCount; ++i)
				{
					var type : uint = LightData(lightDatas.getItem(i)).type;
					var group : uint = LightData(lightDatas.getItem(i)).group;
					hash += type + '|' + group;
				}
			}
			
			// reflections
			if (styleStack.get(ReflectionStyle.REFLECTION_ENABLED, false))
			{
				var blending : uint = styleStack.get(ReflectionStyle.BLENDING, Blending.NORMAL)
									  as uint;
				
				hash += '_reflection' + String.fromCharCode(
					33 + (blending & 0xF), 33 + ((blending & 0xF0) >>> 4), 
					33 + ((blending & 0xF00) >>> 8), 33 + ((blending & 0xF000) >>> 12),
					33 + ((blending & 0xF0000) >>> 16), 33 + ((blending & 0xF00000) >>> 20),
					33 + ((blending & 0xF000000) >>> 24), 33 + ((blending & 0xF0000000) >>> 28)
				);
			}
			
			// shadowing
			if (styleStack.get(LightingStyle.RECEIVE_SHADOWS, false))
				hash += '_shadowcasting';
			
			return hash;
		}
		
		protected static function createShader(styleStack		: StyleData, 
											   worldData		: Dictionary,
											   lightDepthIds	: Vector.<int>) : Shader
		{
			var clipspacePosition	: INode = getOutputPosition(styleStack);//new ClipspacePosition();
			var pixelColor			: INode;
			
			var diffuseStyleValue	: Object = styleStack.isSet(BasicStyle.DIFFUSE)
											   ? styleStack.get(BasicStyle.DIFFUSE)
											   : null;
			
			if (diffuseStyleValue == null)
			{
				pixelColor = new Interpolate(
					new Combine(
						new Extract(new Attribute(VertexComponent.RGB), Components.RGB),
						new Constant(1)
					)
				);
			}
			else if (diffuseStyleValue is uint || diffuseStyleValue is Vector4)
				pixelColor = new Copy(new StyleParameter(4, BasicStyle.DIFFUSE));
			else if (diffuseStyleValue is TextureResource)
				pixelColor = new DiffuseMapTexture();
			else
				throw new Error('Invalid BasicStyle.DIFFUSE value');
			
			if (styleStack.get(ReflectionStyle.REFLECTION_ENABLED, false))
			{
				pixelColor = new Blend(
					new ReflectionNode(),
					pixelColor, 
					styleStack.get(ReflectionStyle.BLENDING, Blending.ALPHA) as uint
				);
			}
			
			if (styleStack.get(LightingStyle.LIGHTS_ENABLED, false))
			{
				pixelColor = new MultiplyColor(
					pixelColor,
					new LightsNode(styleStack, worldData, lightDepthIds)
				);
			}
						
			return Shader.create("lighting pass", clipspacePosition, pixelColor);
		}
		
		protected static function getOutputPosition(styleStack : StyleData) : INode
		{
			var localToScreen	: INode = new TransformParameter(16, TransformData.LOCAL_TO_SCREEN);
			var position		: INode	= new AnimatedPosition(
				styleStack.get(AnimationStyle.METHOD, AnimationMethod.DISABLED) as uint,
				styleStack.get(AnimationStyle.MAX_INFLUENCES, 0) as uint,
				styleStack.get(AnimationStyle.NUM_BONES, 0) as uint
			);
			
			return new Multiply4x4(position, localToScreen);
		}
	}
}
