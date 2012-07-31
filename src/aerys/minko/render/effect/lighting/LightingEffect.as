package aerys.minko.render.effect.lighting
{
	import aerys.minko.render.effect.lighting.onscreen.LightingShader;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.scene.node.Scene;
	import aerys.minko.render.effect.AbstractShadowingEffect;
	
	public class LightingEffect extends AbstractShadowingEffect
	{
		public function LightingEffect(scene : Scene)
		{
			super(scene, new LightingShader());
		}
	}
}