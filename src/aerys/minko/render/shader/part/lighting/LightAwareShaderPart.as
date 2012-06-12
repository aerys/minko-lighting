package aerys.minko.render.shader.part.lighting
{
	import aerys.minko.ns.minko_lighting;
	import aerys.minko.render.effect.basic.BasicProperties;
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.part.ParallaxMappingShaderPart;
	import aerys.minko.render.shader.part.ShaderPart;
	import aerys.minko.render.shader.part.animation.VertexAnimationShaderPart;
	import aerys.minko.type.enum.NormalMappingType;
	import aerys.minko.type.enum.SamplerFiltering;
	import aerys.minko.type.enum.SamplerMipMapping;
	import aerys.minko.type.enum.TriangleCulling;
	import aerys.minko.type.stream.format.VertexComponent;
	
	public class LightAwareShaderPart extends ShaderPart
	{
		use namespace minko_lighting;
		
		private var _vertexAnimationShaderPart	: VertexAnimationShaderPart;
		private var _parallaxMappingShaderPart	: ParallaxMappingShaderPart;
		
		private function get vertexAnimationShaderPart() : VertexAnimationShaderPart
		{
			_vertexAnimationShaderPart ||= new VertexAnimationShaderPart(main);
			return _vertexAnimationShaderPart;
		}
		
		private function get parallaxMappingShaderPart() : ParallaxMappingShaderPart
		{
			_parallaxMappingShaderPart ||= new ParallaxMappingShaderPart(main);
			return _parallaxMappingShaderPart;
		}
		
		protected function get vsLocalPosition() : SFloat
		{
			return vertexAnimationShaderPart.getAnimatedVertexPosition();
		}
		
		protected function get fsUV() : SFloat
		{
			var normalMappingType : uint = meshBindings.getConstant(LightingProperties.NORMAL_MAPPING_TYPE, NormalMappingType.NONE);
			
			switch (normalMappingType)
			{
				case NormalMappingType.NONE:
				case NormalMappingType.NORMAL:
					return interpolate(getVertexAttribute(VertexComponent.UV));
				
				case NormalMappingType.PARALLAX:
					return parallaxMappingShaderPart.getSteepParallaxMappedUV();
					
				default:
					throw new Error('Unknown normal mapping type.');
			}
		}
		
		protected function get vsWorldPosition() : SFloat
		{
			return localToWorld(vsLocalPosition);
		}
		
		protected function get fsWorldPosition() : SFloat
		{
			return interpolate(vsWorldPosition);
		}
		
		protected function get vsLocalNormal() : SFloat
		{
			var vertexNormal : SFloat = vertexAnimationShaderPart.getAnimatedVertexNormal();
			
			if (meshBindings.getConstant(BasicProperties.TRIANGLE_CULLING, TriangleCulling.BACK) != TriangleCulling.BACK)
				vertexNormal.negate();
			
			return vertexNormal;
		}
		
		protected function get vsWorldNormal() : SFloat
		{
			var v : SFloat = deltaLocalToWorld(vsLocalNormal);
			return normalize(v.xyz);
		}
		
		protected function get fsLocalNormal() : SFloat
		{
			return normalize(interpolate(vsLocalNormal));
		}
		
		protected function get fsWorldNormal() : SFloat
		{
			return normalize(interpolate(localToWorld(vsLocalNormal)));
		}
		
		protected function get vsLocalTangent() : SFloat
		{
			var vertexTangent : SFloat = vertexAnimationShaderPart.getAnimatedVertexTangent();
			
			if (meshBindings.getConstant(BasicProperties.TRIANGLE_CULLING, TriangleCulling.BACK) != TriangleCulling.BACK)
				vertexTangent.negate();
			
			return vertexTangent;
		}
		
		protected function get fsLocalTangent() : SFloat
		{
			return interpolate(fsLocalTangent);
		}
		
		protected function get fsTangentNormal() : SFloat
		{
			var normalMappingType : uint = 
				meshBindings.getConstant(LightingProperties.NORMAL_MAPPING_TYPE, NormalMappingType.NONE)
			
			switch (normalMappingType)
			{
				case NormalMappingType.NONE:
					return normalize(deltaLocalToTangent(fsLocalNormal));
				
				case NormalMappingType.NORMAL:
				case NormalMappingType.PARALLAX:
					var fsNormalMap	: SFloat = meshBindings.getTextureParameter(LightingProperties.NORMAL_MAP);
					var fsPixel		: SFloat = sampleTexture(fsNormalMap, fsUV).scaleBy(2).decrementBy(1);
					
					return normalize(fsPixel.rgb);
					
				default:
					throw new Error('Invalid normap mapping type value');
			}
		}
		
		public function LightAwareShaderPart(main : Shader)
		{
			super(main);
		}
		
		protected function deltaLocalToTangent(v : SFloat) : SFloat
		{
			var vsLocalNormal	: SFloat = this.vsLocalNormal;
			var vsLocalTangent	: SFloat = this.vsLocalTangent;
			var vsLocalBinormal	: SFloat = crossProduct(vsLocalNormal, vsLocalTangent);
			
			return float3(
				dotProduct3(v, vsLocalTangent),
				dotProduct3(v, vsLocalBinormal),
				dotProduct3(v, vsLocalNormal)
			);
		}
		
		protected function deltaWorldToTangent(v : SFloat) : SFloat
		{
			return deltaLocalToTangent(deltaWorldToLocal(v));
		}
		
		protected function lightPropertyExists(lightId : uint, name : String) : Boolean
		{
			var parameterName : String = LightingProperties.getNameFor(lightId, name);
			return sceneBindings.propertyExists(parameterName);
		}
		
		protected function getLightConstant(lightId : uint, name : String, defaultValue : Object = null) : *
		{
			var parameterName : String = LightingProperties.getNameFor(lightId, name);
			return sceneBindings.getConstant(parameterName, defaultValue);
		}
		
		protected function getLightParameter(lightId : uint, name : String, size : uint) : SFloat
		{
			var parameterName : String = LightingProperties.getNameFor(lightId, name);
			return sceneBindings.getParameter(parameterName, size);
		}
		
		protected function getLightTextureParameter(lightId		: uint,
													name		: String, 
													filter		: uint = 1, 
													mipmap		: uint = 0, 
													wrapping	: uint = 1, 
													dimension	: uint = 0) : SFloat
		{
			var parameterName : String = LightingProperties.getNameFor(lightId, name);
			return sceneBindings.getTextureParameter(parameterName, filter, mipmap, wrapping, dimension);
		}
		
	}
}
