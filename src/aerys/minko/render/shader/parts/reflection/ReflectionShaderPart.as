package aerys.minko.render.shader.parts.reflection
{
	import aerys.minko.render.effect.reflection.ReflectionProperties;
	import aerys.minko.render.shader.PassTemplate;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.part.ShaderPart;
	import aerys.minko.render.shader.part.projection.BlinnNewellProjectionShaderPart;
	import aerys.minko.render.shader.part.projection.ProbeProjectionShaderPart;
	import aerys.minko.type.enum.ReflectionType;
	
	import flash.geom.Rectangle;
	
	public class ReflectionShaderPart extends ShaderPart
	{
		private var _blinnNewellProjectionPart	: BlinnNewellProjectionShaderPart;
		private var _probeProjectionPart		: ProbeProjectionShaderPart;
		
		public function ReflectionShaderPart(main : PassTemplate)
		{
			super(main);
			
			_blinnNewellProjectionPart	= new BlinnNewellProjectionShaderPart(main);
			_probeProjectionPart		= new ProbeProjectionShaderPart(main);
		}
		
		public function getReflectionColor(position	: SFloat,
										   uv		: SFloat,
										   normal	: SFloat) : SFloat
		{
			// compute reflected vector
			var worldPosition		: SFloat = localToWorld(position);
			var worldNormal			: SFloat = normalize(deltaLocalToWorld(normal))
			
			var cameraWorldPosition : SFloat = sceneBindings.getParameter("cameraWorldPosition", 3)
			var vertexToCamera		: SFloat = normalize(subtract(cameraWorldPosition, worldPosition));
			var reflected			: SFloat = normalize(interpolate(reflect(vertexToCamera.xyzz, worldNormal.xyzz)));
			
			var reflectionType 		: int	 = meshBindings.getProperty(ReflectionProperties.TYPE);
			
			// retrieve reflection color from reflection map
			var reflectionMap		: SFloat;
			var reflectionMapUV		: SFloat;
			var reflectionColor		: SFloat;
			
			switch (reflectionType)
			{
				case ReflectionType.NONE:
					reflectionColor = float4(0, 0, 0, 0);
					break;
				
				case ReflectionType.PROBE:
					reflectionMap	= meshBindings.getTextureParameter(ReflectionProperties.MAP);
					reflectionMapUV = _probeProjectionPart.projectVector(reflected, new Rectangle(0, 0, 1, 1));
					reflectionColor = sampleTexture(reflectionMap, reflectionMapUV);
					break;
				
				case ReflectionType.BLINN_NEWELL:
					reflectionMap	= meshBindings.getTextureParameter(ReflectionProperties.MAP);
					reflectionMapUV = _blinnNewellProjectionPart.projectVector(reflected, new Rectangle(0, 0, 1, 1));
					reflectionColor = sampleTexture(reflectionMap, reflectionMapUV);
					break;
				
				case ReflectionType.CUBE:
					reflectionMap	= meshBindings.getTextureParameter(ReflectionProperties.MAP);
					reflectionMapUV = _blinnNewellProjectionPart.projectVector(reflected, new Rectangle(0, 0, 1, 1));
					reflectionColor = sampleTexture(reflectionMap, reflectionMapUV);
					break
				
				default:
					throw new Error('Unsupported reflection type');
			}
			
			// modifify alpha color
			if (meshBindings.propertyExists(ReflectionProperties.ALPHA_MULTIPLIER))
			{
				var alphaModifier : SFloat = meshBindings.getParameter(ReflectionProperties.ALPHA_MULTIPLIER, 1);
				
				reflectionColor = float4(reflectionColor.xyz, multiply(reflectionColor.w, alphaModifier));
			}
			
			return reflectionColor;
		}
	}
}
