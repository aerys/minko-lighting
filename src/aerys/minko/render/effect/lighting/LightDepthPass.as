package aerys.minko.render.effect.lighting
{
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.effect.IEffectPass;
	import aerys.minko.render.effect.animation.AnimationStyle;
	import aerys.minko.render.effect.basic.BasicStyle;
	import aerys.minko.render.renderer.RendererState;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.node.INode;
	import aerys.minko.render.shader.node.light.ClipspacePositionFromLight;
	import aerys.minko.render.shader.node.light.PackedDepthFromLight;
	import aerys.minko.scene.data.LightData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	import aerys.minko.scene.data.ViewportData;
	import aerys.minko.scene.data.WorldDataList;
	import aerys.minko.type.animation.AnimationMethod;
	import aerys.minko.type.enum.Blending;
	import aerys.minko.type.enum.CompareMode;
	import aerys.minko.type.enum.TriangleCulling;
	
	import flash.utils.Dictionary;
	
	public class LightDepthPass implements IEffectPass
	{
		private static const _SHADERS	: Array	= new Array();
		
		protected var _shader		: Shader;		
		protected var _lightIndex	: uint;
		protected var _priority		: Number;
		protected var _renderTarget	: RenderTarget;
		
		public function LightDepthPass(lightIndex	: uint			= 0,
									   priority		: Number		= 0,
									   renderTarget	: RenderTarget	= null)
		{
			_lightIndex			= lightIndex;
			_priority			= priority;
			_renderTarget		= renderTarget;
//			_shader				= createShader(lightIndex);
		}
		
		protected function createShader(styleData : StyleData, lightIndex : uint) : Shader
		{
			var clipspacePosition	: INode	= new ClipspacePositionFromLight(styleData, _lightIndex);
			var pixelColor			: INode	= new PackedDepthFromLight(_lightIndex);
			
			return Shader.create("light depth pass", clipspacePosition, pixelColor);
		}
		
		public function fillRenderState(state			: RendererState,
										styleData		: StyleData, 
										transformData	: TransformData,
										worldData		: Dictionary) : Boolean
		{
			if (!styleData.get(LightingStyle.CAST_SHADOWS, false))
				return false;
			
			getShader(styleData, worldData).fillRenderState(state, styleData, transformData, worldData);
			
			state.blending			= Blending.NORMAL;
			state.depthTest			= CompareMode.LESS
			state.priority			= _priority;
			state.renderTarget		= _renderTarget || worldData[ViewportData].renderTarget;
//			state.program			= _shader.resource;
			state.triangleCulling	= styleData.get(BasicStyle.TRIANGLE_CULLING, TriangleCulling.BACK) as uint;
			
			return true;
		}
		
		protected function getShader(styleData	: StyleData, 
									 worldData	: Dictionary) : Shader
		{
			var shader : Shader;
			
			try
			{
				shader = searchIntoTree(styleData, worldData);
			}
			catch (e : Error)
			{
				shader = createShader(styleData, _lightIndex);
				addIntoTree(shader, styleData, worldData);
			}
			
			return shader;
		}
		
		protected function addIntoTree(shader		: Shader,
									   styleData	: StyleData,
									   worldData	: Dictionary) : void
		{
			var currentStage	: Array = _SHADERS;
			var currentStyle	: int;
			
			// skinning
			currentStyle = int(styleData.get(AnimationStyle.METHOD, AnimationMethod.DISABLED));
			if (!currentStage[currentStyle])
				currentStage[currentStyle] = new Array();
			currentStage = currentStage[currentStyle];
			
			if (currentStyle != AnimationMethod.DISABLED)
			{
				currentStyle = styleData.get(AnimationStyle.MAX_INFLUENCES, 0) as int;
				if (!currentStage[currentStyle])
					currentStage[currentStyle] = new Array();
				currentStage = currentStage[currentStyle];
				
				currentStyle = styleData.get(AnimationStyle.NUM_BONES, 0) as int;
				if (!currentStage[currentStyle])
					currentStage[currentStyle] = new Array();
				currentStage = currentStage[currentStyle];
			}
			
			// light group
			currentStyle = int(styleData.get(LightingStyle.GROUP, 0));
			if (!currentStage[currentStyle])
				currentStage[currentStyle] = new Array();
			currentStage = currentStage[currentStyle];
			
			var lightDatas : WorldDataList		= worldData[LightData];
			var lightCount : int = currentStyle	= lightDatas ? lightDatas.length : 0;
			
			// there are lightCount lights
			if (!currentStage[currentStyle])
				currentStage[currentStyle] = new Array();
			currentStage = currentStage[currentStyle];
			
			for (var i : int = 0; i < lightCount; ++i)
			{
				var lightData : LightData = LightData(lightDatas.getItem(i));
				var lightGroup	: uint = lightData.group;
				var lightType	: uint = lightData.type;
				
				currentStyle = (lightGroup << 16) | lightType;
				if (!currentStage[currentStyle])
					currentStage[currentStyle] = new Array();
				currentStage = currentStage[currentStyle];
			}
			
			currentStage[0] = shader;
		}
		
		protected function searchIntoTree(styleData	: StyleData,
										  worldData	: Dictionary) : Shader
		{
			var currentStage	: Array = _SHADERS;
			var currentStyle	: int;
			
			// skinning
			currentStyle = int(styleData.get(AnimationStyle.METHOD, AnimationMethod.DISABLED));
			currentStage = currentStage[currentStyle];
			
			if (currentStyle != AnimationMethod.DISABLED)
			{
				currentStyle = int(styleData.get(AnimationStyle.MAX_INFLUENCES, 0));
				currentStage = currentStage[currentStyle];
				
				currentStyle = int(styleData.get(AnimationStyle.NUM_BONES, 0));
				currentStage = currentStage[currentStyle];
			}
			
			// light group
			currentStyle = int(styleData.get(LightingStyle.GROUP, 0));
			currentStage = currentStage[currentStyle];
			
			var lightDatas : WorldDataList		= worldData[LightData];
			var lightCount : int = currentStyle	= lightDatas ? lightDatas.length : 0;
			
			// there are lightCount lights
			currentStage = currentStage[currentStyle];
			
			for (var i : int = 0; i < lightCount; ++i)
			{
				var lightData : LightData = LightData(lightDatas.getItem(i));
				var lightGroup	: uint = lightData.group;
				var lightType	: uint = lightData.type;
				
				currentStyle = (lightGroup << 16) | lightType;
				currentStage = currentStage[currentStyle];
			}
			
			return Shader(currentStage[0]);
		}
	}
}