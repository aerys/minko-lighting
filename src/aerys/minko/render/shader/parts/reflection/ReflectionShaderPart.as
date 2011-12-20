package aerys.minko.render.shader.parts.reflection
{
	import aerys.minko.render.effect.reflection.ReflectionStyle;
	import aerys.minko.render.effect.reflection.ReflectionType;
	import aerys.minko.render.shader.ActionScriptShader;
	import aerys.minko.render.shader.ActionScriptShaderPart;
	import aerys.minko.render.shader.SValue;
	import aerys.minko.render.shader.node.leaf.Sampler;
	import aerys.minko.render.shader.parts.math.projection.BlinnNewellProjectionShaderPart;
	import aerys.minko.render.shader.parts.math.projection.ProbeProjectionShaderPart;
	import aerys.minko.scene.data.CameraData;
	import aerys.minko.scene.data.ReflectionData;
	import aerys.minko.scene.data.StyleData;
	import aerys.minko.scene.data.TransformData;
	import aerys.minko.scene.data.WorldDataList;
	
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	public class ReflectionShaderPart extends ActionScriptShaderPart
	{
		private var _blinnNewellProjectionPart	: BlinnNewellProjectionShaderPart;
		private var _probeProjectionPart		: ProbeProjectionShaderPart;
		
		
		
		public function ReflectionShaderPart(main : ActionScriptShader)
		{
			super(main);
			
			_blinnNewellProjectionPart = new BlinnNewellProjectionShaderPart(main);
			_probeProjectionPart = new ProbeProjectionShaderPart(main);
		}
		
		public function getReflectionColor(reflectionId		: int,
										   reflectionDatas	: WorldDataList,
										   position			: SValue,
										   normal			: SValue) : SValue
		{
			var uv : SValue;
			
			if (reflectionId == ReflectionType.NONE)
				return null;
			else if (reflectionId == ReflectionType.PLANAR)
				throw new Error('This reflection type is only supported ' +
					'for dynamic reflections. You should insert a ' +
					'ReflectionSurface node into your scene');
			else if (reflectionId == ReflectionType.PROBE || reflectionId == ReflectionType.BLINN_NEWELL || reflectionId == ReflectionType.CUBE)
			{
				// wrong, we should do the substration of cameraPosition in worldspace to save the matrix calculation
				var cameraLocalPosition	: SValue = getWorldParameter(3, CameraData, CameraData.LOCAL_POSITION)
				var vertexToCam			: SValue = normalize(subtract(cameraLocalPosition, position));
				var reflected			: SValue = reflect(vertexToCam, normalize(interpolate(vertexNormal)));
				reflected = interpolate(normalize(multiply3x3(reflected, localToWorldMatrix)));
				
				if (reflectionId == ReflectionType.PROBE)
				{
					uv = _probeProjectionPart.projectVector(reflected, new Rectangle(0, 0, 1, 1));
					return sampleTexture(ReflectionStyle.MAP, uv, Sampler.FILTER_LINEAR, Sampler.MIPMAP_LINEAR, Sampler.WRAPPING_CLAMP);
				}
				else if (reflectionId == ReflectionType.BLINN_NEWELL)
				{
					uv = _blinnNewellProjectionPart.projectVector(reflected, new Rectangle(0, 0, 1, 1));
					return sampleTexture(ReflectionStyle.MAP, uv, Sampler.FILTER_LINEAR, Sampler.MIPMAP_LINEAR, Sampler.WRAPPING_CLAMP);
				}
				else
					return sampleTexture(ReflectionStyle.MAP, reflected, Sampler.FILTER_LINEAR, Sampler.MIPMAP_DISABLE, Sampler.WRAPPING_CLAMP, Sampler.DIMENSION_CUBE);
			}
			else if (reflectionId >= 0)
			{
				var reflectionData : ReflectionData = ReflectionData(reflectionDatas.getItem(reflectionId));
				
				if (reflectionData.type == ReflectionType.PLANAR)
				{
					var localToUv	: SValue = getWorldParameter(16, ReflectionData, ReflectionData.LOCAL_TO_SCREEN, reflectionId);
					uv = multiply4x4(interpolate(position), localToUv);
					uv = divide(uv, uv.w);
					uv.scaleBy(float2(1/2, -1/2));
					uv.incrementBy(1/2);
					
					return sampleTexture(ReflectionStyle.MAP, uv, Sampler.FILTER_LINEAR, Sampler.MIPMAP_DISABLE, Sampler.WRAPPING_CLAMP);
				}
				else
					return getReflectionColor(reflectionData.type, null, position, normal);
			}
			
			throw new Error('Invalid reflection type and|or id');
		}
		
		override public function getDataHash(styleData		: StyleData, 
											 transformData	: TransformData, 
											 worldData		: Dictionary) : String
		{
			throw new Error('implement me');
		}
	}
}