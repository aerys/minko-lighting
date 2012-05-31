package aerys.minko.render.effect.realistic
{
	import aerys.minko.render.effect.AbstractShadowingEffect;
	import aerys.minko.render.effect.Effect;
	import aerys.minko.scene.node.Scene;
	
	public class RealisticEffect extends AbstractShadowingEffect
	{
		public function RealisticEffect(scene : Scene)
		{
			super(scene, new RealisticPass());
		}
	}
}