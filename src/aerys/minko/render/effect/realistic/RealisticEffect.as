package aerys.minko.render.effect.realistic
{
	import aerys.minko.render.effect.Effect;
	import aerys.minko.scene.node.Scene;
	
	public class RealisticEffect extends Effect
	{
		private var _scene : Scene;
		
		public function RealisticEffect(scene : Scene)
		{
			super(new RealisticPass());
			
			_scene = scene;
		}
	}
}