package aerys.minko.render.effect.lighting.offscreen
{
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.effect.lighting.LightingProperties;
	import aerys.minko.render.shader.PassConfig;
	import aerys.minko.render.shader.PassInstance;
	import aerys.minko.render.shader.PassTemplate;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.part.animation.VertexAnimationShaderPart;
	import aerys.minko.render.shader.part.projection.IProjectionShaderPart;
	import aerys.minko.render.shader.part.projection.ParaboloidProjectionShaderPart;
	import aerys.minko.type.enum.Blending;
	
	import flash.geom.Rectangle;
	
	public class ParaboloidShadowMapPass extends PassTemplate
	{
		private static const PROJECTION_RECTANGLE : Rectangle = new Rectangle(-1, 1, 2, -2);
		
		private var _vertexAnimationPart	: VertexAnimationShaderPart;
		private var _projectorPart			: IProjectionShaderPart;
		
		private var _lightId				: uint;
		private var _priority				: Number;
		private var _renderTarget			: RenderTarget;
		
		private var _lightSpacePosition		: SFloat;
		
		public function ParaboloidShadowMapPass(lightId	: uint,
												  front		: Boolean,
												  priority	: Number,
												  target	: RenderTarget)
		{
			_lightId				= lightId;	
			_vertexAnimationPart	= new VertexAnimationShaderPart(this);
			_projectorPart			= new ParaboloidProjectionShaderPart(this, front);
		}
		
		override protected function configurePass(passConfig : PassConfig) : void
		{
			passConfig.blending		= Blending.NORMAL;
			passConfig.priority		= _priority;
			passConfig.renderTarget	= _renderTarget;
			
			passConfig.enabled = 
				meshBindings.getPropertyOrFallback(LightingProperties.CAST_SHADOWS, true);
		}
		
		override protected function getVertexPosition() : SFloat
		{
			var worldToLight		: SFloat = sceneBindings.getParameter('lightWorldToLight' + _lightId, 16);
			var position			: SFloat = _vertexAnimationPart.getAnimatedVertexPosition();
			var worldPosition		: SFloat = localToWorld(position);
			var lightPosition		: SFloat = multiply4x4(worldPosition, worldToLight);
			var clipspacePosition	: SFloat = _projectorPart.projectVector(lightPosition, PROJECTION_RECTANGLE, 0, 50);
			
			_lightSpacePosition = interpolate(lightPosition);
			
			return float4(clipspacePosition, 1);
		}
		
		override protected function getPixelColor() : SFloat
		{
			var clipspacePosition	: SFloat = _projectorPart.projectVector(_lightSpacePosition, PROJECTION_RECTANGLE, 0, 50);
			
			return float4(clipspacePosition.zzz, 1);
		}
	}
}
